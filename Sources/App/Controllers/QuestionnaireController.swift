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
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = questionnaires.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Post
        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get(use: getAll)
        // Update
        // Delete
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    // MARK: - CREATE
    func create(req: Request) async throws -> Questionnaire {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        let input = try req.content.decode(Questionnaire.Input.self)
        try await QuestionnaireMiddleware().validate(questionnaireInput: input, on: req.db)
        let questionnaire = input.toModel()
        try await questionnaire.save(on: req.db)
        let questionnaireID = try questionnaire.requireID()
        
        for clientID in input.clientIDs {
            let recipientInput = QuestionnaireRecipient.Input(questionnaireID: questionnaireID, clientID: clientID, status: .sent, sentAt: Date())
            let _ = try await QuestionnaireRecipientController().create(req: req, input: recipientInput)
        }
        
        return questionnaire
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [Questionnaire] {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        return try await Questionnaire.query(on: req.db).all()
    }
    
    // TODO: Add more routes
    
    // MARK: - UPDATE
    
    // MARK: - DELETE
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        let questionnaires = try await Questionnaire.query(on: req.db).all()
        try await questionnaires.delete(force: true, on: req.db)
        
        let _ = try await QuestionnaireRecipientController().removeAll(req: req)
        
        return .noContent
    }
}
