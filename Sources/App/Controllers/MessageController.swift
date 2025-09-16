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
		tokenAuthGroup.get(":clientId", "paginate", use: getPaginatedMessages)
		tokenAuthGroup.get("paginate", use: getPaginatedMessages)
        // Delete
        tokenAuthGroup.delete(":messageID", use: delete)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> Message {
        try Message.Input.validate(content: req)
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

	func getPaginatedMessages(req: Request) async throws -> Message.PaginatedOutput {
		// Read query params with defaults
		let page = max((try? req.query.get(Int.self, at: "page")) ?? 1, 1)
		var perPage = (try? req.query.get(Int.self, at: "perPage")) ?? 20

		// Clamp perPage to avoid overload
		let maxPerPage = 100
		if perPage < 1 { perPage = 20 } // fallback if < 1
		if perPage > maxPerPage { perPage = maxPerPage }

		// Perform database query with Fluent pagination
		let paginatedResult = try await Message.query(on: req.db)
			.sort(\.$dateSent, .descending)
			.paginate(PageRequest(page: page, per: perPage))

		// Wrap result in your custom PaginatedOutput
		return Message.PaginatedOutput(
			messages: paginatedResult.items,
			pageCount: paginatedResult.metadata.pageCount
		)
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
