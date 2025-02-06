//
//  File.swift
//  
//
//  Created by Raphaël Payet on 07/08/2024.
//

import Fluent
import Vapor

// MARK: - Delete
extension UserController {
    func remove(req: Request) async throws -> HTTPStatus {
        let userID = try await getUserID(on: req)
        let user = try await getUser(with: userID, on: req.db)
        try await user.delete(force: true, on: req.db)
        
        let questionnaireRecipients = try await user.$questionnaireRecipients.get(on: req.db)
        for questionnaireRecipient in questionnaireRecipients {
            let id = try questionnaireRecipient.requireID()
            let _ = try await QuestionnaireRecipientController().remove(req: req, id: id)
        }
        
        return .noContent
    }
    
    func removeAll(req: Request) async throws -> HTTPStatus {
        try await User
            .query(on: req.db)
            .all()
            .delete(force: true, on: req.db)
        return .noContent
    }
}
