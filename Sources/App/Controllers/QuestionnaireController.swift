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
        tokenAuthGroup.put(":qID", use: update)
        // Delete
        tokenAuthGroup.delete("all", use: removeAll)
        tokenAuthGroup.delete(":qID", use: remove)
    }
    
    // MARK: - CREATE
    func create(req: Request) async throws -> Questionnaire {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        let input = try req.content.decode(Questionnaire.Input.self)
        try await QuestionnaireMiddleware().validate(input, on: req.db)
        let questionnaire = input.toModel()
        try await questionnaire.save(on: req.db)
        let questionnaireID = try questionnaire.requireID()
        
        for clientID in input.clientIDs {
            let recipientInput = QuestionnaireRecipient.Input(questionnaireID: questionnaireID,
                                                              clientID: clientID,
                                                              status: .sent,
                                                              sentAt: Date()
            )
            let _ = try await QuestionnaireRecipientController().create(req: req, input: recipientInput)
        }
        
        return questionnaire
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [Questionnaire] {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        return try await Questionnaire.query(on: req.db).all()
    }
    
    func get(req: Request, id: Questionnaire.IDValue) async throws -> Questionnaire {
        guard let questionnaire = try await Questionnaire.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.questionnaire")
        }
        
        return questionnaire
    }
    
    // MARK: - UPDATE
    func update(req: Request) async throws -> Questionnaire {
        let questionnaire = try await get(on: req)
        let questionnaireID = try questionnaire.requireID()
        let input = try req.content.decode(Questionnaire.UpdateInput.self)
        
        let updatedQuestionnaire = input.update(questionnaire: questionnaire)
        try await updatedQuestionnaire.update(on: req.db)
        
        // Remove old qRecipients
        let qRecipients = try await QuestionnaireRecipient.query(on: req.db).filter(\.$questionnaire.$id == questionnaireID).all()
        try await qRecipients.delete(force: true, on: req.db)
        
        // Create new qRecipients
        for clientID in input.clientIDs {
            let recipientInput = QuestionnaireRecipient.Input(questionnaireID: questionnaireID,
                                                              clientID: clientID,
                                                              status: .sent,
                                                              sentAt: Date()
            )
            let _ = try await QuestionnaireRecipientController().create(req: req, input: recipientInput)
        }
        
        return updatedQuestionnaire
    }
    
    // MARK: - DELETE
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        let questionnaires = try await Questionnaire.query(on: req.db).all()
        try await questionnaires.delete(force: true, on: req.db)
        
        let _ = try await QuestionnaireRecipientController().removeAll(req: req)
        
        return .noContent
    }
    
    func remove(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        let questionnaire = try await get(on: req)
        try await questionnaire.delete(force: true, on: req.db)
        
        return .noContent
    }
}

extension QuestionnaireController {
    func get(on req: Request) async throws -> Questionnaire {
        guard let questionnaire = try await Questionnaire.find(req.parameters.get("qID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.questionnaire")
        }
        
        return questionnaire
    }
}
