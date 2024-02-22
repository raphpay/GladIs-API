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
        // Create
        documents.post(use: upload)
        // Read
        documents.get(use: getAllDocuments)
        documents.get("single", use: getPdf)
        documents.get("directory", use: getDocumentAtDirectory)
        // Update
        // Delete
        documents.delete(":documentID", use: remove)
    }
    
    
    // MARK: - CREATE
    func upload(req: Request) throws -> EventLoopFuture<Document> {
        let document = try req.content.decode(Document.Input.self)
        let pdfEntity = try req.content.decode(PDFEntity.self)

        let uploadDirectory = req.application.directory.publicDirectory + document.path
        let fileName = document.name + ".pdf"
        
        if !FileManager.default.fileExists(atPath: uploadDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: uploadDirectory, withIntermediateDirectories: true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to create directory: \(error)")
            }
        }
        
        return req.fileio
            .writeFile(pdfEntity.file.data, at: uploadDirectory + fileName)
            .flatMapThrowing {
                let document = Document(name: document.name + ".pdf", path: document.path)
                return document
                    .save(on: req.db)
                    .map { document }
            }
            .flatMap { $0 }
    }
    
    // MARK: - READ
    func getPdf(req: Request) throws -> EventLoopFuture<Response> {
        let document = try req.content.decode(Document.Input.self)
        let filePath = req.application.directory.publicDirectory + document.path + document.name
        
        if !FileManager.default.fileExists(atPath: filePath) {
            throw Abort(.notFound, reason: "File not found at path: \(filePath)")
        }
        
        let fileURL = URL(fileURLWithPath: filePath)
        let fileData = try Data(contentsOf: fileURL)
        
        let response = Response(body: .init(data: fileData))
        response.headers.contentType = .pdf
        
        return req.eventLoop.future(response)
    }
    
    func getAllDocuments(req: Request) throws -> EventLoopFuture<[Document]> {
        Document
            .query(on: req.db)
            .all()
    }
    
    func getDocumentAtDirectory(req: Request) throws -> EventLoopFuture<[Document]> {
        struct DirectoryInput: Codable {
            var path: String
        }
        
        let directory = try req.content.decode(DirectoryInput.self)
        
        return Document
            .query(on: req.db)
            .filter(\.$path == directory.path)
            .all()
    }
    
    
    // MARK: - Update
    // MARK: - Delete
    func remove(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        Document
            .find(req.parameters.get("documentID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { document in
                document
                    .delete(force: true, on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    // TODO: Write a method to delete pdf and its related document
}


