//
//  FormController.swift
//
//
//  Created by Raphaël Payet on 05/05/2024.
//

import Fluent
import Vapor

struct FormController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let forms = routes.grouped("api", "forms")
        // Token Authentification
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = forms.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get(use: getAll)
        // Update
        tokenAuthGroup.put(":formID", use: update)
        // Delete
        tokenAuthGroup.delete(":formID", use: delete)
        tokenAuthGroup.delete("all", use: deleteAll)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> Form {
        let input = try req.content.decode(Form.CreationInput.self)
        let form = Form(title: input.title, createdBy: input.createdBy, value: input.value)
        
        try await form.save(on: req.db)
        return form
    }
    
    // MARK: - Read
    func getAll(req: Request) async throws -> [Form] {
        try await Form.query(on: req.db).all()
    }
    
    // MARK: - Update
    func update(req: Request) async throws -> Form {
        guard let form = try await Form.find(req.parameters.get("formID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.form")
        }
        
        let updateInput = try req.content.decode(Form.UpdateInput.self)
        
        form.updatedBy = updateInput.updatedBy
        form.value = updateInput.value

        try await form.update(on: req.db)

        return form
    }

    // MARK: - Delete
    func delete(req: Request) async throws -> HTTPStatus {
        guard let form = try await Form.find(req.parameters.get("formID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.form")
        }

        try await form.delete(on: req.db)

        return .noContent
    }

    func deleteAll(req: Request) async throws -> HTTPStatus {
        try await Form.query(on: req.db).delete()
        return .noContent
    }
}
