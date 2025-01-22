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
//        questionnaireRecipients.post(<#T##path: PathComponent...##PathComponent#>, use: <#T##(Request) async throws -> AsyncResponseEncodable#>)
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = questionnaireRecipients.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Read
        tokenAuthGroup.get("all", use: getAll)
        // Delete
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    let logger = Logger(label: "recipient")
    // MARK: - Create
    func create(req: Request, input: QuestionnaireRecipient.Input) async throws -> QuestionnaireRecipient {
        logger.info("start2")
        logger.info("input2 \(input)")
        try await QuestionnaireMiddleware().validateRecipient(recipientInput: input, on: req.db)
        logger.info("validated")
        let questionnaireRecipient = input.toModel()
        logger.info("recipient \(questionnaireRecipient)")
        try await questionnaireRecipient.save(on: req.db)
        return questionnaireRecipient
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [QuestionnaireRecipient] {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        return try await QuestionnaireRecipient.query(on: req.db).all()
    }
    
    // MARK: - Delete
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        let questionnaireRecipients = try await QuestionnaireRecipient.query(on: req.db).all()
        try await questionnaireRecipients.delete(force: true, on: req.db)
        return .noContent
    }
}
