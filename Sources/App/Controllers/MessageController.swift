//
//  MessageController.swift
//
//
//  Created by Raphaël Payet on 29/03/2024.
//


import Fluent
import Vapor

struct MessageController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let messages = routes.grouped("api", "messages")
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = messages.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get(use: getAll)
        // Delete
        tokenAuthGroup.delete(":messageID", use: delete)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> Message {
        do {
            try Message.Input.validate(content: req)
        } catch {
            throw Abort(.badRequest, reason: "badRequest.message.contentLength")
        }
        
        let input = try req.content.decode(Message.Input.self)
        
        guard input.senderID != input.receiverID else {
            throw Abort(.badRequest, reason: "badRequest.message.senderAndReceiverSame")
        }
        
        let message = Message(title: input.title, content: input.content,
                              dateSent: .now,
                              senderID: input.senderID, senderMail: input.senderMail,
                              receiverID: input.receiverID, receiverMail: input.receiverMail)
        
        
        try await message.save(on: req.db)
        return message
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [Message] {
        try await Message.query(on: req.db).all()
    }
    
    // MARK: - Delete
    func delete(req: Request) async throws -> HTTPResponseStatus {
        let authUser = try req.auth.require(User.self)
        
        guard authUser.userType == .admin else {
            throw Abort(.badRequest, reason: "badRequest.userShouldBeAdmin")
        }
        
        guard let message = try await Message.find(req.parameters.get("messageID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.message")
        }
        
        try await message.delete(force: true, on: req.db)
        
        return .noContent
    }
    
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        let adminUser = try req.auth.require(User.self)
        
        guard adminUser.userType == .admin else {
            throw Abort(.badRequest, reason: "badRequest.userShouldBeAdmin")
        }
        
        try await Message
            .query(on: req.db)
            .all()
            .delete(force: true, on: req.db)
        
        return .noContent
    }
}
