//
//  DocumentController.swift
//
//
//  Created by Raphaël Payet on 22/02/2024.
//

import Fluent
import Vapor
import ZIPFoundation

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
        // Read
        tokenAuthGroup.get(use: getAllDocuments)
        tokenAuthGroup.get(":documentID", use: getDocument)
        tokenAuthGroup.get("download", ":documentID", use: dowloadDocument)
        tokenAuthGroup.get("zip", ":documentID", use: zipDocument)
        tokenAuthGroup.post("zipDirectory", use: zipDirectory)
        tokenAuthGroup.get("unzip", ":documentID", use: unzipDocument)
        tokenAuthGroup.post("unzipDirectory", use: unzipDirectory)
        tokenAuthGroup.post("getDocumentsAtPath", use: getDocumentsAtPath)
        tokenAuthGroup.post("paginated", "path", use: getPaginatedDocumentsAtPath)
        // Update
        tokenAuthGroup.put(":documentID", use: changeDocumentStatus)
        // Delete
        tokenAuthGroup.delete(":documentID", use: remove)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    
    // MARK: - CREATE
    func upload(req: Request) async throws -> Document {
        let input = try req.content.decode(Document.Input.self)
        let uploadDirectory = req.application.directory.publicDirectory + input.path
        
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
    
    
    func uploadLogo(req: Request) async throws -> Document {
        let input = try req.content.decode(Document.Input.self)
        let uploadDirectory = req.application.directory.publicDirectory + input.path
        
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
        try await Document
            .query(on: req.db)
            .all()
    }
    
    func getDocumentsAtPath(req: Request) async throws -> [Document] {
        let path = try req.content.decode(Document.PathInput.self)
        
        return try await Document
            .query(on: req.db)
            .filter(\.$path == path.value)
            .all()
    }
    
    func getPaginatedDocumentsAtPath(req: Request) async throws -> Document.PaginatedOutput {
        let path = try req.content.decode(Document.PathInput.self)
        
        guard let page = req.query[Int.self, at: "page"],
              let perPage = req.query[Int.self, at: "perPage"] else {
            throw Abort(.badRequest, reason: "Missing page or perPage query parameters")
        }
        
        let paginatedResults = try await Document
            .query(on: req.db)
            .filter(\.$path == path.value)
            .paginate(PageRequest(page: page, per: perPage))

        let pageCount = paginatedResults.metadata.pageCount
        
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
        let filePath = req.application.directory.publicDirectory + document.path + document.name
        
        if !FileManager.default.fileExists(atPath: filePath) {
            throw Abort(.notFound, reason: "notFound.file")
        }

        return req.fileio.streamFile(at: filePath)
    }

    // MARK: - Archive
    func zipDocument(req: Request) async throws -> Document {
        let document = try await getDocument(req: req)
        
        let publicDirectory = req.application.directory.publicDirectory
        let sourcePath = publicDirectory +  document.path + document.name
        let destinationZipPath = publicDirectory + document.path + document.name + ".archive.zip"
        
        let sourceURL = URL(fileURLWithPath: sourcePath)
        let destinationZipURL = URL(fileURLWithPath: destinationZipPath)
        
        do {
            try FileManager.default.zipItem(at: sourceURL, to: destinationZipURL)
        } catch {
            throw Abort(.internalServerError, reason: "internalServerError.unableToZipFile")
        }
        
        let updatedDocument = try await updateArchiveStatus(document, isArchived: true, on: req.db)
        
        do {
            try FileManager.default.removeItem(at: sourceURL)
        } catch {
            throw Abort(.internalServerError, reason: "internalServerError.unableToRemoveItem")
        }
        
        return updatedDocument
    }
    
    func unzipDocument(req: Request) async throws -> Document {
        let document = try await getDocument(req: req)
        let publicDirectory = req.application.directory.publicDirectory
        let sourcePath = publicDirectory +  document.path + document.name + ".archive.zip"
        let destinationUnzipPath = publicDirectory + document.path

        if !FileManager.default.fileExists(atPath: destinationUnzipPath) {
            do {
                try FileManager.default.createDirectory(atPath: destinationUnzipPath, withIntermediateDirectories: true)
            } catch {
                throw Abort(.internalServerError, reason: "internalServerError.failedToCreateDirectory")
            }
        }
        
        do {
            let sourceURL = URL(fileURLWithPath: sourcePath)
            let destinationUnzipURL = URL(fileURLWithPath: destinationUnzipPath)
            try FileManager.default.unzipItem(at: sourceURL, to: destinationUnzipURL)
        } catch {
            throw Abort(.internalServerError, reason: "internalServerError.unableToUnzipFile")
        }
        
        let updatedDocument = try await updateArchiveStatus(document, isArchived: false, on: req.db)
        
        do {
            try FileManager.default.removeItem(atPath: sourcePath)
        } catch {
            throw Abort(.internalServerError, reason: "internalServerError.unableToRemoveItem")
        }
        
        return updatedDocument
    }
    
    func zipDirectory(req: Request) async throws -> HTTPResponseStatus {
        let pathInput = try req.content.decode(Document.PathInput.self)
        let publicDirectory = req.application.directory.publicDirectory
        let sourcePath = publicDirectory + pathInput.value
        let destinationZipPath = publicDirectory + pathInput.value + ".archive.zip"
        
        let sourceURL = URL(fileURLWithPath: sourcePath)
        let destinationZipURL = URL(fileURLWithPath: destinationZipPath)
        
        do {
            try FileManager.default.zipItem(at: sourceURL, to: destinationZipURL)
            try FileManager.default.removeItem(at: sourceURL)
            return .ok
        } catch {
            throw Abort(.internalServerError, reason: "internalServerError.unableToZipDirectory")
        }
    }
    
    func unzipDirectory(req: Request) async throws -> HTTPResponseStatus {
        let pathInput = try req.content.decode(Document.PathInput.self)
        let publicDirectory = req.application.directory.publicDirectory
        let sourcePath = publicDirectory + pathInput.value + ".archive.zip"
        
        guard let unzippedDestination = pathInput.unzippedValue else {
            throw Abort(.badRequest, reason: "badRequest.missingUnzippedDestinationParameter")
        }
        
        let unzipPath = publicDirectory + unzippedDestination
        
        let sourceURL = URL(fileURLWithPath: sourcePath)
        let unzipURL = URL(fileURLWithPath: unzipPath)
        
        do {
            try FileManager.default.unzipItem(at: sourceURL, to: unzipURL)
            try FileManager.default.removeItem(at: sourceURL)
            return .ok
        } catch {
            throw Abort(.internalServerError, reason: "internalServerError.unableToUnzipDirectory")
        }
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
        let filePath = req.application.directory.publicDirectory + document.path + document.name
        
        if FileManager.default.fileExists(atPath: filePath) {
            try FileManager.default.removeItem(atPath: filePath)
        }
        
        do {
            try await document.delete(force: true, on: req.db)
            return .noContent
        } catch let error {
            throw Abort(.badRequest, reason: error.localizedDescription)
        }
    }
    
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        let documents = try await getAllDocuments(req: req)
        
        for document in documents {
            let filePath = req.application.directory.publicDirectory + document.path + document.name
            
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }
            
            do {
                try await document.delete(force: true, on: req.db)
            } catch let error {
                throw Abort(.badRequest, reason: error.localizedDescription)
            }
        }
        
        return .noContent
    }
    
    // MARK: - Helper
    private func updateArchiveStatus(_ document: Document, isArchived: Bool, on db: Database) async throws -> Document {
        document.isArchived = isArchived
        try await document.update(on: db)
        return document
    }
}


