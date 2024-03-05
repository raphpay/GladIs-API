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
        // TODO: Handle tokens
        // Create
        documents.post(use: upload)
        // Read
        documents.get(use: getAllDocuments)
        documents.get(":documentID", use: getDocument)
        documents.get("download", ":documentID", use: dowloadDocument)
        documents.post("getDocumentsAtPath", use: getDocumentsAtPath)
        // Update
        // Delete
        documents.delete(":documentID", use: remove)
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = documents.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    
    // MARK: - CREATE
    func upload(req: Request) throws -> EventLoopFuture<Document> {
        let document = try req.content.decode(Document.Input.self)

        let uploadDirectory = req.application.directory.publicDirectory + document.path
        let fileName = document.file.filename
        
        if !FileManager.default.fileExists(atPath: uploadDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: uploadDirectory, withIntermediateDirectories: true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to create directory: \(error)")
            }
        }
        
        return req.fileio
            .writeFile(document.file.data, at: uploadDirectory + fileName)
            .flatMapThrowing {
                let document = Document(name: fileName, path: document.path)
                return document
                    .save(on: req.db)
                    .map { document }
            }
            .flatMap { $0 }
    }
    
    // MARK: - READ
    func getAllDocuments(req: Request) throws -> EventLoopFuture<[Document]> {
        Document
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
    
    func getDocument(req: Request) async throws -> Document {
        guard let model = try await Document.find(req.parameters.get("documentID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        return model
    }
    
    func dowloadDocument(req: Request) async throws -> Response {
        let document = try await getDocument(req: req)
        let filePath = req.application.directory.publicDirectory + document.path + document.name
        
        if !FileManager.default.fileExists(atPath: filePath) {
            throw Abort(.notFound, reason: "File not found at \(filePath)")
        }

        return req.fileio.streamFile(at: filePath)
    }
    
    // MARK: - Update
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
        let authUser = try req.auth.require(User.self)
        
        guard authUser.userType == .admin else {
            throw Abort(.badRequest, reason: "User should be admin for this action")
        }
        
        try await Document
            .query(on: req.db)
            .all()
            .delete(force: true, on: req.db)
        
        return .noContent
    }
}


