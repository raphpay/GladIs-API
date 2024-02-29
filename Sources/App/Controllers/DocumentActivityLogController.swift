//
//  DocumentActivityLogController.swift
//
//
//  Created by Raphaël Payet on 29/02/2024.
//

import Fluent
import Vapor

struct DocumentActivityLogController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let logs = routes.grouped("api", "documentActivityLogs")
        // Create
        logs.post("user", ":actorID", "document", ":documentID", use: create)
        // Read
        logs.get(use: getAll)
        logs.get("clientID", use: getLogsForClient)
        // Delete
        logs.delete(use: removeAll)
    }
    
    
    // MARK: - CREATE
    func create(req: Request) async throws -> DocumentActivityLog {
        let logInput = try req.content.decode(DocumentActivityLog.Input.self)
        
        guard let docQuery = try await Document.find(logInput.documentID, on: req.db) else {
            throw Abort(.notFound, reason: "Document not found")
        }
        
        guard let userQuery = try await User.find(req.parameters.get("actorID"), on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        let docID = try docQuery.requireID()
        let log = DocumentActivityLog(name: docQuery.name,
                                      actorUsername: userQuery.username,
                                      action: logInput.action,
                                      actionDate: Date.now,
                                      documentID: docID,
                                      clientID: logInput.clientID)
        try await log.save(on: req.db)
        return log
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [DocumentActivityLog] {
        try await DocumentActivityLog.query(on: req.db).all()
    }
    
    func getLogsForClient(req: Request) throws -> EventLoopFuture<[DocumentActivityLog]> {
        guard let clientID = req.parameters.get("clientID"),
              let uuid = UUID(uuidString: clientID) else {
            throw Abort(.badRequest)
        }
        
        return DocumentActivityLog
            .query(on: req.db)
            .filter(\.$client.$id == uuid)
            .all()
    }
    
    // MARK: - DELETE
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        try await DocumentActivityLog
            .query(on: req.db)
            .all()
            .delete(force: true, on: req.db)
        
        return .noContent
    }
}


