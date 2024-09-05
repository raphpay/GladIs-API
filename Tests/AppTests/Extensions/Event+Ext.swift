//
//  Event+Ext.swift
//  
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension Event {
    static func create(name: String, clientID: UUID = UUID(), on database: Database) async throws -> Event {
        let event = Event(name: name, date: Date.now.timeIntervalSince1970, clientID: clientID)
        try await event.save(on: database)
        return event
    }
    
    static func archive(_ event: Event, on database: Database) async throws {
        try await event.delete(force: false, on: database)
    }
    
    static func deleteAll(on database: Database) async throws {
        try await Event.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
    
    static func get(_ id: UUID, on database: Database) async throws -> Event? {
        let events = try await Event.query(on: database)
            .withDeleted()
            .all()
        
        let filteredEvents = events.filter{ $0.id == id }
        return filteredEvents.first
    }
}
