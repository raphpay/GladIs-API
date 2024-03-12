//
//  PendingUser+Ext.swift
//  
//
//  Created by Raphaël Payet on 13/02/2024.
//

import Foundation
import Fluent
import Vapor

extension PendingUser {
    func convertToUser() -> User {
        let user = User(firstName: self.firstName, lastName: self.lastName,
                        phoneNumber: self.phoneNumber,
                        username: "", password: "",
                        email: self.email, firstConnection: true, userType: .client,
                        companyName: self.companyName, products: self.products,
                        numberOfEmployees: self.numberOfEmployees, numberOfUsers: self.numberOfUsers,
                        salesAmount: self.salesAmount)
        // TODO: Generate and send a password
        return user
    }
    
    static func verifyUniqueEmail(_ email: String, on req: Request) async throws -> String {
        let pendingUser = try await PendingUser.query(on: req.db)
            .filter(\.$email == email)
            .first()
        
        guard pendingUser == nil else {
            // If a user with the email already exists, throw an error
            throw Abort(.badRequest, reason: "Email already exists")
        }
        // If the email is unique, return it
        return email
    }
}
