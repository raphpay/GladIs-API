//
//  DocumentController.swift
//
//
//  Created by Raphaël Payet on 22/02/2024.
//

import Fluent
import Vapor

struct DocumentController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let documents = routes.grouped("api", "documents")
        documents.post("image", use: uploadImage)
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = documents.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: upload)
        // Read
        tokenAuthGroup.get(use: getAllDocuments)
        tokenAuthGroup.get(":documentID", use: getDocument)
        tokenAuthGroup.get("download", ":documentID", use: dowloadDocument)
        tokenAuthGroup.post("getDocumentsAtPath", use: getDocumentsAtPath)
        tokenAuthGroup.post("paginated", "path", use: getPaginatedDocumentsAtPath)
        tokenAuthGroup.post("pages", "byName", "andPath", use: getDocumentPagesByNameAndPath)
        // Update
        tokenAuthGroup.put(":documentID", use: changeDocumentStatus)
        // Delete
        tokenAuthGroup.delete(":documentID", use: remove)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    
    // MARK: - CREATE
    func upload(req: Request) async throws -> [Document] {
        let input = try req.content.decode(Document.FormDataInput.self)
        let uploadDirectory = req.application.directory.resourcesDirectory + input.path
        
        let originalDocument = try await uploadFile(input: input, uploadDirectory: uploadDirectory, on: req)
        let documents = try await uploadPDPages(input: input, originalDocument: originalDocument, uploadDirectory: uploadDirectory, req: req)
        
        // Remove the complete document for memory usage
        try FileManager.default.removeItem(atPath: uploadDirectory + input.name)

        return documents // Return the list of created documents
    }
    
    func uploadImage(req: Request) async throws -> Document {
        let input = try req.content.decode(Document.FormDataInput.self)
        let uploadDirectory = req.application.directory.resourcesDirectory + input.path
        return try await uploadFile(input: input, uploadDirectory: uploadDirectory, on: req)
    }
    
    // MARK: - READ
    func getAllDocuments(req: Request) async throws -> [Document] {
        return try await Document
            .query(on: req.db)
            .all()
    }
    
    func getDocumentsAtPath(req: Request) async throws -> [Document] {
        struct Path: Codable {
            var value: String
        }
        
        let path = try req.content.decode(Path.self)
        
        return try await Document
            .query(on: req.db)
            .filter(\.$path == path.value)
            .all()
    }

    func getPaginatedDocumentsAtPath(req: Request) async throws -> Document.PaginatedOutput {
        struct Path: Codable {
            var value: String
        }

        let path = try req.content.decode(Path.self)

        // Get the pagination parameters from the query string
        guard let page = req.query[Int.self, at: "page"],
              let perPage = req.query[Int.self, at: "perPage"] else {
            throw Abort(.badRequest, reason: "Missing page or perPage query parameters")
        }

        // Paginate and filter documents by path, excluding documents with '-pX.pdf' in their name
        let paginatedResults = try await Document
            .query(on: req.db)
            .filter(\.$path == path.value)
            .filter(\.$name !~= "-p\\d+\\.pdf") // Filter out names ending with '-pX.pdf'
            .paginate(PageRequest(page: page, per: perPage))

        // Extract the total number of pages
        let pageCount = paginatedResults.metadata.pageCount

        // Create the output with the filtered documents and the page count
        let output = Document.PaginatedOutput(documents: paginatedResults.items, pageCount: pageCount)

        return output
    }
    
    func getDocument(req: Request) async throws -> Document {
        guard let document = try await Document.find(req.parameters.get("documentID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.document")
        }
        
        return document
    }
    
    func getDocumentPagesByNameAndPath(req: Request) async throws -> [Document] {
        // Get the document name and path via the request
        let input = try req.content.decode(Document.SearchInput.self);

        // Construct the search pattern to filter documents
        let searchPattern = "\(input.name)-p\\d+\\.pdf" // Pattern to search files with name-p1.pdf, name-p2.pdf, etc...

        // Search all the corresponding documents
        let documents = try await Document.query(on: req.db)
            .filter(\.$name ~~ searchPattern) // Using regex
            .filter(\.$path == input.path)
            .all()

        return documents
    }
    
    func dowloadDocument(req: Request) async throws -> Response {
        let document = try await getDocument(req: req)
        let filePath = req.application.directory.resourcesDirectory + document.path + document.name
        
        if !FileManager.default.fileExists(atPath: filePath) {
            throw Abort(.notFound, reason: "notFound.file")
        }

        return req.fileio.streamFile(at: filePath)
    }
    
    // MARK: - Update
    func changeDocumentStatus(req: Request) async throws -> Document {
        let input = try req.content.decode(Document.StatusInput.self)
        guard let document = try await Document.find(req.parameters.get("documentID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.document")
        }
        
        document.status = input.status
        try await document.update(on: req.db)
        
        return document
    }
    
    // MARK: - Delete
    func remove(req: Request) async throws -> HTTPResponseStatus {
        let document = try await getDocument(req: req)
        return try await delete(document: document, on: req)
    }
    
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        let documents = try await getAllDocuments(req: req)
        
        for document in documents {
            let _ = try await delete(document: document, on: req)
        }
        
        return .noContent
    }
}


// MARK: - Utils
extension DocumentController {
    // MARK: - Upload
    func uploadFile(input: Document.FormDataInput, uploadDirectory: String, on req: Request) async throws -> Document {
        guard req.headers.contentType == .formData else {
            throw Abort(.unsupportedMediaType)
        }
        
        let file = try req.content.get(File.self, at: "file")
        let destinationFilePath = uploadDirectory + input.name
        
        let fileName = input.name
        
        if !FileManager.default.fileExists(atPath: uploadDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: uploadDirectory, withIntermediateDirectories: true)
            } catch {
                throw Abort(.internalServerError, reason: "internalServerError.failedToCreateDirectory")
            }
        }
        
        try await req.fileio.writeFile(file.data, at: destinationFilePath)
        
        let document = Document(name: fileName, path: input.path, status: .none)
        try await document.save(on: req.db)
        
        return document
    }

    func uploadPDPages(input: Document.FormDataInput, originalDocument: Document, uploadDirectory: String, req: Request) async throws -> [Document] {
        let destinationFilePath = uploadDirectory + input.name
        var documents: [Document] = [originalDocument]

        // Create a unique name pattern for the output files
        let outputPattern = uploadDirectory + "\(input.name.replacingOccurrences(of: ".pdf", with: ""))-%d.pdf"

        // Call `pdfseparate` to split the PDF into individual pages
        let separateProcess = Process()
        // Local path to pdfseparate :
        // let pdfSeparatePath = /opt/homebrew/bin/pdfseparate
        
        // Server path to pdfseparate:
        let pdfSeparatePath = "/usr/bin/pdfseparate"
        separateProcess.executableURL = URL(fileURLWithPath: pdfSeparatePath) // Path to `pdfseparate`
        separateProcess.arguments = [destinationFilePath, outputPattern]

        let pipe = Pipe()
        separateProcess.standardOutput = pipe
        separateProcess.standardError = pipe

        try separateProcess.run()
        separateProcess.waitUntilExit()

        let status = separateProcess.terminationStatus
        if status != 0 {
            throw Abort(.internalServerError, reason: "Failed to split the PDF.")
        }

        // Find all the generated PDF files and save them
        let fileManager = FileManager.default
        let splitPDFs = try fileManager.contentsOfDirectory(atPath: uploadDirectory).filter { $0.hasPrefix(input.name.replacingOccurrences(of: ".pdf", with: "")) && $0.hasSuffix(".pdf")
        }

        for splitPDF in splitPDFs {
            let document = Document(name: splitPDF, path: input.path, status: .none)
            try await document.save(on: req.db)
            documents.append(document)
        }

        return documents
    }
    
    
    // MARK: - Delete
    func delete(document: Document, on req: Request) async throws -> HTTPResponseStatus {
        let baseDirectory = req.application.directory.resourcesDirectory
        let filePath = baseDirectory + document.path + document.name
        if FileManager.default.fileExists(atPath: filePath) {
            try FileManager.default.removeItem(atPath: filePath)
        }
        
        // Delete empty directories
        var currentPath = (filePath as NSString).deletingLastPathComponent
        while currentPath.hasPrefix(baseDirectory) && currentPath != baseDirectory {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: currentPath)
                if contents.isEmpty {
                    try FileManager.default.removeItem(atPath: currentPath)
                } else {
                    break // Directory not empty, stop here
                }
            } catch {
                // Failed to remove directory
                break
            }
            currentPath = (currentPath as NSString).deletingLastPathComponent
        }
        
        try await document.delete(force: true, on: req.db)
        
        return .noContent
    }
}
