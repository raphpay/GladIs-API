//
//  Form+Ext.swift
//  
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension Form {
    static func create(
        title: String, value: String,
        clientID: String, path: String,
        on database: Database
    ) async throws -> Form {
        let form = Form(title: title, value: value, clientID: clientID, path: path)
        try await form.save(on: database)
        return form
    }
    
    static func deleteAll(on database: Database) async throws {
        try await Form.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }

    static func approveByAdmin(_ form: Form, on database: Database) async throws {
        form.approvedByAdmin = true
        try await form.update(on: database)
    }

    static func deapproveByAdmin(_ form: Form, on database: Database) async throws {
        form.approvedByAdmin = false
        try await form.update(on: database)
    }

    static func approveByClient(_ form: Form, on database: Database) async throws {
        form.approvedByClient = true
        try await form.update(on: database)
    }

    static func deapproveByClient(_ form: Form, on database: Database) async throws {
        form.approvedByClient = false
        try await form.update(on: database)
    }
}
