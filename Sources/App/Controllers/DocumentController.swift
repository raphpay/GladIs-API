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
        documents.post("image", "data", use: uploadImageData)
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = documents.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: upload)
        tokenAuthGroup.post("data", use: uploadViaBase64Data)
        // Read
        tokenAuthGroup.get(use: getAllDocuments)
        tokenAuthGroup.get(":documentID", use: getDocument)
        tokenAuthGroup.get("download", ":documentID", use: dowloadDocument)
        tokenAuthGroup.post("getDocumentsAtPath", use: getDocumentsAtPath)
        tokenAuthGroup.post("paginated", "path", use: getPaginatedDocumentsAtPath)
        // Update
        tokenAuthGroup.put(":documentID", use: changeDocumentStatus)
        // Delete
        tokenAuthGroup.delete(":documentID", use: remove)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    
    // MARK: - CREATE
    // TODO: Refactor the upload methods
    func upload(req: Request) async throws -> Document {
        let input = try req.content.decode(Document.FormDataInput.self)
        let uploadDirectory = req.application.directory.resourcesDirectory + input.path
        
        let document = try await uploadFile(input: input, uploadDirectory: uploadDirectory, on: req)

        return document
    }

    func uploadViaBase64Data(req: Request) async throws -> Document {
        let input = try req.content.decode(Document.Input.self)
        let uploadDirectory = req.application.directory.resourcesDirectory + input.path
        
        let fileName = try await createUniqueFileName(input: input, on: req)

        // Ensure the directory exists
        if !FileManager.default.fileExists(atPath: uploadDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: uploadDirectory, withIntermediateDirectories: true)
            } catch {
                throw Abort(.internalServerError, reason: "internalServerError.failedToCreateDirectory")
            }
        }

        // Write the file to the directory with the unique fileName
        try await req.fileio.writeFile(input.file.data, at: uploadDirectory + fileName)

        // Save the document with the unique name to the database
        let document = Document(name: fileName, path: input.path, status: .none)
        try await document.save(on: req.db)
        
        return document
    }

    func uploadImage(req: Request) async throws -> Document {
        let input = try req.content.decode(Document.FormDataInput.self)
        let uploadDirectory = req.application.directory.resourcesDirectory + input.path
        return try await uploadFile(input: input, uploadDirectory: uploadDirectory, on: req)
    }

    func uploadImageData(req: Request) async throws -> Document {
        let input = try req.content.decode(Document.Input.self)
        let uploadDirectory = req.application.directory.resourcesDirectory + input.path

        let fileName = try await createUniqueFileName(input: input, on: req)

        // Ensure the directory exists
        if !FileManager.default.fileExists(atPath: uploadDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: uploadDirectory, withIntermediateDirectories: true)
            } catch {
                throw Abort(.internalServerError, reason: "internalServerError.failedToCreateDirectory")
            }
        }

        // Write the file to the directory with the unique fileName
        try await req.fileio.writeFile(input.file.data, at: uploadDirectory + fileName)

        // Save the document with the unique name to the database
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
        let baseInput = input.toBaseInput(file: file)
        let fileName = try await createUniqueFileName(input: baseInput, on: req)
        
        let destinationFilePath = uploadDirectory + fileName
        
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
    
    func createUniqueFileName(input: Document.Input, on req: Request) async throws -> String {
        // Extract the base name and extension
        let baseName = (input.name as NSString).deletingPathExtension
        let fileExtension = (input.name as NSString).pathExtension
        
        var fileName = input.name // start with the original name
        var suffix = 1
        
        // Check if a document with the same name and path exists and add suffix if necessary
        while try await Document.query(on: req.db)
            .filter(\.$name == fileName)
            .filter(\.$path == input.path)
            .first() != nil {
                fileName = "\(baseName)-\(suffix).\(fileExtension)"
                suffix += 1
        }
        
        return fileName
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
