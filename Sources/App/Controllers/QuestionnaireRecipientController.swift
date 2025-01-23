//
//  QuestionnaireRecipientController.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Vapor
import Fluent

struct QuestionnaireRecipientController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let questionnaireRecipients = routes.grouped("api", "questionnaires", "recipients")
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = questionnaireRecipients.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Read
        tokenAuthGroup.get("all", use: getAll)
        tokenAuthGroup.get("questionnaire", ":questionnaireRecipientID", use: getQuestionnaire)
        // Delete
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    // MARK: - Create
    func create(req: Request, input: QuestionnaireRecipient.Input) async throws -> QuestionnaireRecipient {
        try await QuestionnaireMiddleware().validateRecipient(recipientInput: input, on: req.db)
        let questionnaireRecipient = input.toModel()
        try await questionnaireRecipient.save(on: req.db)
        return questionnaireRecipient
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [QuestionnaireRecipient] {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        return try await QuestionnaireRecipient.query(on: req.db).all()
    }
    
    func getQuestionnaire(req: Request) async throws -> Questionnaire {
        guard let questionnaireRecipient = try await QuestionnaireRecipient.find(req.parameters.get("questionnaireRecipientID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.questionnaireRecipient")
        }
        
        questionnaireRecipient.status = .viewed
        try await questionnaireRecipient.update(on: req.db)
        
        let questionnaire = try await QuestionnaireController().get(req: req, id: questionnaireRecipient.$questionnaire.id)
        return questionnaire
    }
    
    // MARK: - Delete
    func remove(req: Request, id: QuestionnaireRecipient.IDValue) async throws -> HTTPResponseStatus {
        guard let questionnaireRecipient = try await QuestionnaireRecipient.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.questionnaireRecipient")
        }
        
        try await questionnaireRecipient.delete(force: true, on: req.db)
        
        return .noContent
    }
    
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        let questionnaireRecipients = try await QuestionnaireRecipient.query(on: req.db).all()
        try await questionnaireRecipients.delete(force: true, on: req.db)
        return .noContent
    }
}
