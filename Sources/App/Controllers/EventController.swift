//
//  EventController.swift
//
//
//  Created by Raphaël Payet on 26/03/2024.
//

import Fluent
import Vapor

struct EventController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let events = routes.grouped("api", "events")
        // Token Authentification
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = events.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get(use: getAll)
        tokenAuthGroup.get("client", ":clientID", use: getAllForClient)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> Event {
        let input = try req.content.decode(Event.Input.self)
        
        let event = Event(name: input.name, date: input.date, clientID: input.clientID)
        
        try await event.save(on: req.db)
        
        return event 
    }
    
    // MARK: - Read
    func getAll(req: Request) async throws -> [Event] {
        try await Event
            .query(on: req.db)
            .all()
    }
    
    func getAllForClient(req: Request) async throws -> [Event] {
        guard let clientID = req.parameters.get("clientID"),
            let uuid = UUID(uuidString: clientID) else {
            throw Abort(.badRequest, reason: "Invalid UUID")
        }
        
        return try await Event
            .query(on: req.db)
            .filter(\.$client.$id == uuid)
            .all()
    }
}
