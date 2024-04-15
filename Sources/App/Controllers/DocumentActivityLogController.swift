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
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = logs.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get(use: getAll)
        tokenAuthGroup.get(":clientID", use: getLogsForClient)
        tokenAuthGroup.get(":clientID", "paginate", use: getPaginatedLogsForClient)
        // Delete
        tokenAuthGroup.delete(use: removeAll)
    }
    
    
    // MARK: - CREATE
    func create(req: Request) async throws -> DocumentActivityLog {
        let logInput = try req.content.decode(DocumentActivityLog.Input.self)
        
        guard let docQuery = try await Document.find(logInput.documentID, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.document")
        }
        
        guard let userQuery = try await User.find(logInput.actorID, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        let docID = try docQuery.requireID()
        let log = DocumentActivityLog(name: docQuery.name,
                                      actorUsername: userQuery.username,
                                      action: logInput.action,
                                      actionDate: Date.now,
                                      actorIsAdmin: logInput.actorIsAdmin,
                                      documentID: docID,
                                      clientID: logInput.clientID)
        
        try await log.save(on: req.db)
        return log
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [DocumentActivityLog] {
        try await DocumentActivityLog.query(on: req.db).all()
    }
    
    func getLogsForClient(req: Request) async throws -> [DocumentActivityLog] {
        guard let clientID = req.parameters.get("clientID"),
              let uuid = UUID(uuidString: clientID) else {
            throw Abort(.badRequest, reason: "badRequest.clientID")
        }
        
        return try await DocumentActivityLog
            .query(on: req.db)
            .filter(\.$client.$id == uuid)
            .sort(\.$actionDate, .descending)
            .all()
    }
    
    func getPaginatedLogsForClient(req: Request) async throws -> DocumentActivityLog.PaginatedOutput {
        guard let clientID = req.parameters.get("clientID"),
              let uuid = UUID(uuidString: clientID) else {
            throw Abort(.badRequest, reason: "badRequest.clientID")
        }
        
        guard let page = req.query[Int.self, at: "page"] else {
            throw Abort(.badRequest, reason: "badRequest.page")
        }
        
        guard let perPage = req.query[Int.self, at: "perPage"] else {
            throw Abort(.badRequest, reason: "badRequest.perPage")
        }

        let paginatedResult = try await DocumentActivityLog.query(on: req.db)
            .filter(\.$client.$id == uuid)
            .sort(\.$actionDate, .descending)
            .paginate(PageRequest(page: page, per: perPage))

        let output = DocumentActivityLog.PaginatedOutput(logs: paginatedResult.items, pageCount: paginatedResult.metadata.pageCount)

        return output
    }
    
    // MARK: - DELETE
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        let adminUser = try req.auth.require(User.self)
        
        guard adminUser.userType == .admin else {
            throw Abort(.forbidden, reason: "forbidden.userShouldBeAdmin")
        }
        
        try await DocumentActivityLog
            .query(on: req.db)
            .all()
            .delete(force: true, on: req.db)
        
        return .noContent
    }
}
