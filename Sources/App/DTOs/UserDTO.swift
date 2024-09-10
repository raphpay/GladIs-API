//
//  UserDTO.swift
//
//
//  Created by Raphaël Payet on 31/07/2024.
//

import Fluent
import Vapor

// MARK: - Public
extension User {
    struct Public: Content {
        // Required
        var id: UUID?
        let firstName: String
        let lastName: String
        let phoneNumber: String
        let email: String
        let username: String
        var firstConnection: Bool
        let userType: UserType
        // Optional
        var companyName: String?
        var products: String?
        var numberOfEmployees: Int?
        var numberOfUsers: Int?
        var salesAmount: Double?
        var employeesIDs: [String]?
        var managerID: String?
        var isBlocked: Bool?
        var modules: [Module]?
        var isConnectionBlocked: Bool?
        var connectionFailedAttempts: Int?
        var systemQualityFolders: [Folder]?
        var recordsFolders: [Folder]?
    }
    
    func convertToPublic() -> User.Public {
        User.Public(id: id,
                    firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email,
                    username: username, firstConnection: firstConnection, userType: userType,
                    companyName: companyName, products: products, numberOfEmployees: numberOfEmployees,
                    numberOfUsers: numberOfUsers, salesAmount: salesAmount, employeesIDs: employeesIDs,
                    managerID: managerID, isBlocked: isBlocked, modules: modules, isConnectionBlocked: isConnectionBlocked, connectionFailedAttempts: connectionFailedAttempts,
                    systemQualityFolders: systemQualityFolders, recordsFolders: recordsFolders
        )
    }
}

// MARK: - Input
extension User {
    struct Input: Content {
        // Required
        let firstName: String
        let lastName: String
        let phoneNumber: String
        let email: String
        let password: String?
        let userType: UserType
        // Optional
        let companyName: String?
        let products: String?
        let numberOfEmployees: Int?
        let numberOfUsers: Int?
        let salesAmount: Double?
        let employeesIDs: [String]?
        let managerID: String?
    }
    
    struct UpdateInput: Content {
        let firstName: String?
        let lastName: String?
        let phoneNumber: String?
        let email: String?
        let shouldUpdateUsername: Bool?

        func update(_ user: User, on req: Request) async throws -> User {
            let updatedUser = user
            
            if let firstName = firstName {
                updatedUser.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if let lastName = lastName {
                updatedUser.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if let phoneNumber = phoneNumber {
                try phoneNumber.validatePhoneNumber()
                updatedUser.phoneNumber = phoneNumber
            }
            if let email = email {
                try email.validateEmail()
                updatedUser.email = email
            }
            if let value = shouldUpdateUsername, value == true {
                let username = try await User.generateUniqueUsername(firstName: updatedUser.firstName, lastName: updatedUser.lastName, on: req)
                updatedUser.username = username
            }
            
            return updatedUser
        }
    }
    
    struct EmailInput: Content {
        let email: String
    }
    
    struct UsernameInput: Content {
        let username: String
    }
}

// MARK: - Output
extension User {
    struct LoginTryOutput: Content {
        let id: UUID?
        let connectionFailedAttempts: Int?
        let isConnectionBlocked: Bool?
        let email: String
    }
    
    func convertToLoginTryOutput() -> User.LoginTryOutput {
        User.LoginTryOutput(id: id,
            connectionFailedAttempts: connectionFailedAttempts,
            isConnectionBlocked: isConnectionBlocked,
            email: email
        )
    }
}

struct PasswordChangeRequest: Content {
    let currentPassword: String
    let newPassword: String
}

struct PasswordValidationRequest: Content {
    let currentPassword: String
}

struct PasswordChangeResponse: Content {
    let message: String
}

struct ResetPasswordRequest: Content {
    let token: String
    let newPassword: String
}
