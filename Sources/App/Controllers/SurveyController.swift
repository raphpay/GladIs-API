//
//  SurveyController.swift
//
//
//  Created by Raphaël Payet on 23/04/2024.
//

import Fluent
import Vapor

struct SurveyController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let surveys = routes.grouped("api", "surveys")
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = surveys.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get(use: getAll)
        // Update
        tokenAuthGroup.put(":surveyID", use: update)
        // Delete
        tokenAuthGroup.delete(":surveyID", use: remove)
        tokenAuthGroup.delete(use: removeAll)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> Survey {
        let input = try req.content.decode(Survey.Input.self)
        let survey = Survey(value: input.value, clientID: input.clientID)
        
        try await survey.save(on: req.db)
        
        return survey
    }
    
    // MARK: - Read
    func getAll(req: Request) async throws -> [Survey] {
        try await Survey
            .query(on: req.db)
            .all()
    }
    
    // MARK: - Update
    func update(req: Request) async throws -> Survey {
        let input = try req.content.decode(Survey.UpdateInput.self)
        guard let survey = try await Survey.find(req.parameters.get("surveyID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.survey")
        }
        
        survey.value = input.value
        
        try await survey.update(on: req.db)
        
        return survey
    }
    
    // MARK: - Delete
    func remove(req: Request) async throws -> HTTPResponseStatus {
        guard let survey = try await Survey.find(req.parameters.get("surveyID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.survey")
        }
        try await survey.delete(force: true, on: req.db)
        return .noContent
    }
    
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        try await Survey
            .query(on: req.db)
            .all()
            .delete(force: true, on: req.db)
        
        return .noContent
    }
}
