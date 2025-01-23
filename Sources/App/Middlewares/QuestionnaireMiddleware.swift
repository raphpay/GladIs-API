//
//  QuestionnaireMiddleware.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Vapor
import Fluent

struct QuestionnaireMiddleware {
    func validate(_ questionnaireInput: Questionnaire.Input, on database: Database) async throws {
        guard let user = try await User.find(questionnaireInput.adminID, on: database),
              user.userType == .admin else {
            throw Abort(.badRequest, reason: "badRequest.userNotAdmin")
        }
        
        var indexes = [Int]()
            
        // Extract indexes from fields
        for field in questionnaireInput.fields {
            indexes.append(field.index)
        }
        
        // Check for duplicates using a Set
        let uniqueIndexes = Set(indexes)
        if indexes.count != uniqueIndexes.count {
            throw Abort(.badRequest, reason: "badRequest.duplicateFieldIndexes")
        }
    }
}

struct QuestionnaireRecipientMiddleware {
    func validate(_ recipientInput: QuestionnaireRecipient.Input, on database: Database) async throws {
        guard let client = try await User.find(recipientInput.clientID, on: database),
              client.userType == .client
        else {
            throw Abort(.badRequest, reason: "badRequest.userNotClient")
        }
    }
    
    func validateFields(_ input: QuestionnaireRecipient.UpdateInput,
                        with questionnaire: Questionnaire,
                        on database: Database) async throws {
        guard questionnaire.fields.count == input.fields.count else {
            throw Abort(.badRequest, reason: "badRequest.missingFields")
        }
        
        // Sort both arrays by `index` for consistent comparison
        let sortedQFields = questionnaire.fields.sorted(by: { $0.index < $1.index })
        let sortedQRFields = input.fields.sorted(by: { $0.index < $1.index })
        
        // Compare each field pair
        for (questionnaire, recipient) in zip(sortedQFields, sortedQRFields) {
            if questionnaire.key != recipient.key || questionnaire.index != recipient.index {
                throw Abort(.badRequest, reason: "badRequest.incorrectFields")
            }
        }
    }
}
