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
        events.post("maxLogin", use: createMaxLoginEvent)
        // Token Authentification
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = events.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get(use: getAll)
        tokenAuthGroup.get("archived", use: getArchivedEvents)
        tokenAuthGroup.get("client", ":clientID", use: getAllForClient)
        tokenAuthGroup.get("client", "archived", ":clientID", use: getArchivedEventsForClient)
        // Update
        tokenAuthGroup.put(":eventID", use: update)
        // Delete
        tokenAuthGroup.delete(":eventID", use: remove)
        tokenAuthGroup.delete("archive", ":eventID", use: archive)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> Event {
        let user = try req.auth.require(User.self)
        
        guard user.userType != .employee else {
            throw Abort(.unauthorized, reason: "unauthorized.event.employee")
        }
        
        if user.userType == .client {
            let clientEvents = try await Event.query(on: req.db)
                .filter(\.$client.$id == user.requireID())
                .all()
            if clientEvents.count >= 5 {
                throw Abort(.forbidden, reason: "forbidden.event.tooManyEvents")
            }
        }
        
        let input = try req.content.decode(Event.Input.self)
        let event = Event(name: input.name, date: input.date, clientID: input.clientID)
        
        try await event.save(on: req.db)
        
        return event 
    }
    
    func createMaxLoginEvent(req: Request) async throws -> Event {
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
            throw Abort(.badRequest, reason: "badRequest.uuid")
        }
        
        return try await Event
            .query(on: req.db)
            .filter(\.$client.$id == uuid)
            .all()
    }

    func getArchivedEvents(req: Request) async throws -> [Event] {
        try await Event
            .query(on: req.db)
            .withDeleted()
            .filter(\.$deletedAt != nil)
            .all()
    }

    func getArchivedEventsForClient(req: Request) async throws -> [Event] {
        guard let clientID = req.parameters.get("clientID"),
            let uuid = UUID(uuidString: clientID) else {
            throw Abort(.badRequest, reason: "badRequest.uuid")
        }
        
        return try await Event
            .query(on: req.db)
            .withDeleted()
            .filter(\.$client.$id == uuid)
            .filter(\.$deletedAt != nil)
            .all()
    }
    
    // MARK: - Update
    func update(req: Request) async throws -> Event {
        guard let event = try await Event.find(req.parameters.get("eventID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.event")
        }
        
        let input = try req.content.decode(Event.Input.self)
        
        event.name = input.name
        event.date = input.date
        event.$client.id = input.clientID
        
        try await event.update(on: req.db)
        
        return event
    }
    
    // MARK: - Delete
    func archive(req: Request) async throws -> HTTPResponseStatus {
        guard let event = try await Event.find(req.parameters.get("eventID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.event")
        }
        try await event.delete(force: false, on: req.db)
        return .noContent
    }


    func remove(req: Request) async throws -> HTTPResponseStatus {
        guard let event = try await Event.find(req.parameters.get("eventID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.event")
        }
        
        try await event.delete(force: true, on: req.db)
        
        return .noContent
    }

    func removeAll(req: Request) async throws -> HTTPResponseStatus {        
        try await Event.query(on: req.db).all().delete(force: true, on: req.db)
        return .noContent
    }
}
