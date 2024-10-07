//
//  EmailMiddleware.swift
//  Medscope
//
//  Created by Raphaël Payet on 30/09/2024.
//

import Vapor
import SendGridKit

struct EmailMiddleware {
    func validate(tos: [String], from: String) throws {
        for email in tos {
            guard email.isValidEmail()  else {
                throw Abort(.badRequest, reason: "badRequest.invalidToEmail")
            }
        }
        
        guard from.isValidEmail() else {
            throw Abort(.badRequest, reason: "badRequest.invalidFromEmail")
        }
    }
    
    func createToArray(tos: [String]) -> [EmailAddress] {
        tos.map { EmailAddress(email: $0) }
    }
}
