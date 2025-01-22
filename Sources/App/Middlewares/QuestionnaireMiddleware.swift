//
//  QuestionnaireMiddleware.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Vapor
import Fluent

struct QuestionnaireMiddleware {
    func validate(questionnaireInput: Questionnaire.Input, on database: Database) async throws {
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
