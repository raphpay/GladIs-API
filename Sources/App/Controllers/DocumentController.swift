//
//  DocumentController.swift
//
//
//  Created by Raphaël Payet on 22/02/2024.
//

import Fluent
import Vapor
import PDFKit

struct DocumentController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let documents = routes.grouped("api", "documents")
        documents.post("logo", use: uploadLogo)
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = documents.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: upload)
        tokenAuthGroup.post("filePart", use: uploadViaFormData)
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
    func upload(req: Request) async throws -> Document {
        let input = try req.content.decode(Document.Input.self)
        let uploadDirectory = req.application.directory.resourcesDirectory + input.path
        
        let fileName = input.name
        
        if !FileManager.default.fileExists(atPath: uploadDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: uploadDirectory, withIntermediateDirectories: true)
            } catch {
                throw Abort(.internalServerError, reason: "internalServerError.failedToCreateDirectory")
            }
        }
        
        try await req.fileio.writeFile(input.file.data, at: uploadDirectory + fileName)
        
        let document = Document(name: fileName, path: input.path, status: .none)
        try await document.save(on: req.db)
        
        return document
    }

    func uploadViaFormData(req: Request) async throws -> [Document] {
        // Ensure the request contains multipart form data
        guard req.headers.contentType == .formData else {
            throw Abort(.unsupportedMediaType)
        }

        // Extract file data using Vapor's content parsing
        // We are looking for the "file" part of the form-data, ensure that the name matches the form field
        let file = try req.content.get(File.self, at: "file")

        // Decode the other form fields (uri, name, path)
        let input = try req.content.decode(Document.FormDataInput.self)

        // Create the upload directory if it doesn't exist
        let uploadDirectory = req.application.directory.resourcesDirectory + input.path
        if !FileManager.default.fileExists(atPath: uploadDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: uploadDirectory, withIntermediateDirectories: true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to create directory.")
            }
        }

        // Save the original PDF file to the upload directory
        let originalFilePath = uploadDirectory + input.name
        try await req.fileio.writeFile(file.data, at: originalFilePath)
        let originalDocument = Document(name: input.name, path: input.path, status: .none)
        try await originalDocument.save(on: req.db)

        // Extract pages from the PDF file
        guard let pdfDocument = PDFDocument(url: URL(fileURLWithPath: originalFilePath)) else {
            throw Abort(.internalServerError, reason: "Failed to open PDF document.")
        }

        var documents: [Document] = [originalDocument]
        
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else {
                continue
            }

            // Create a new PDF document for the page
            let singlePageDocument = PDFDocument()
            singlePageDocument.insert(page, at: 0)

            // Create a unique name for the new PDF file
            let pageFileName = "\(input.name.replacingOccurrences(of: ".pdf", with: ""))-p\(pageIndex + 1).pdf"
            let pageFilePath = uploadDirectory + pageFileName

            // Save the single page PDF document
            if singlePageDocument.write(to: URL(fileURLWithPath: pageFilePath)) {
                // Save document details to the database
                let document = Document(name: pageFileName, path: input.path, status: .none)
                try await document.save(on: req.db)
                documents.append(document)
            } else {
                throw Abort(.internalServerError, reason: "Failed to save page document.")
            }
        }
        
        try FileManager.default.removeItem(atPath: originalFilePath)

        return documents // Return the list of created documents
    }
    
    func uploadLogo(req: Request) async throws -> Document {
        let input = try req.content.decode(Document.Input.self)
        let uploadDirectory = req.application.directory.resourcesDirectory + input.path
        
        let fileName = input.name
        
        if !FileManager.default.fileExists(atPath: uploadDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: uploadDirectory, withIntermediateDirectories: true)
            } catch {
                throw Abort(.internalServerError, reason: "internalServerError.failedToCreateDirectory")
            }
        }
        
        try await req.fileio.writeFile(input.file.data, at: uploadDirectory + fileName)
        
        let document = Document(name: fileName, path: input.path, status: .none)
        try await document.save(on: req.db)
        
        return document
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
