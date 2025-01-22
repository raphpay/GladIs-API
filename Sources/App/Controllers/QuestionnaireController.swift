//
//  QuestionnaireController.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Fluent
import Vapor

struct QuestionnaireController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let questionnaires = routes.grouped("api", "questionnaires")
        questionnaires.post(use: create)
        questionnaires.get(use: getAll)
        questionnaires.delete("all", use: deleteAll)
        // TODO: Use token protected routes
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = questionnaires.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Post
//        tokenAuthGroup.post(":pendingUserID", "convertToUser", use: convertToUser)
//        // Read
//        tokenAuthGroup.get(use: getAll)
//        tokenAuthGroup.get(":pendingUserID", use: getAll)
//        tokenAuthGroup.get(":pendingUserID", "employees", use: getEmployees)
//        // Update
//        tokenAuthGroup.put(":pendingUserID", "status", use: updateStatus)
//        // Delete
//        tokenAuthGroup.delete(":pendingUserID", use: remove)
    }
    
    // MARK: - CREATE
    func create(req: Request) async throws -> Questionnaire {
        // TODO: Verify input ( admin, field indexes )
        let input = try req.content.decode(Questionnaire.Input.self)
        let questionnaire = input.toModel()
        try await questionnaire.save(on: req.db)
        
        return questionnaire
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [Questionnaire] {
        try await Questionnaire.query(on: req.db).all()
    }
    
    // TODO: Add more routes
    
    // MARK: - UPDATE
    
    // MARK: - DELETE
    func deleteAll(req: Request) async throws -> HTTPResponseStatus {
        let questionnaires = try await Questionnaire.query(on: req.db).all()
        try await questionnaires.delete(force: true, on: req.db)
        return .noContent
    }
}
