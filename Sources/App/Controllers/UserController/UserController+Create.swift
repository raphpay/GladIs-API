//
//  File.swift
//  
//
//  Created by Raphaël Payet on 07/08/2024.
//

import Fluent
import Vapor

// MARK: - Create
extension UserController {
    func createWithoutToken(req: Request) async throws -> User.Public {
        let input = try req.content.decode(User.Input.self)
        let user = try await create(input, on: req)
        return user
    }
    
    func create(req: Request) async throws -> User.Public {
        try User.Input.validate(content: req)
        let input = try req.content.decode(User.Input.self)
        let adminUser = try req.auth.require(User.self)
        
        guard adminUser.userType == .admin else {
            throw Abort(.forbidden, reason: "forbidden.userShouldBeAdmin")
        }
        
        let user = try await create(input, on: req)
        
        return user
    }
    
    func addTechnicalDocTab(req: Request) async throws -> TechnicalDocumentationTab {
        let userID = try await getUserID(on: req)
        let user = try await getUser(with: userID, on: req.db)
                
        let tabID = try await TechnicalDocumentationTabController().getTabID(on: req)
        let tab = try await TechnicalDocumentationTabController().getTab(with: tabID, on: req.db)
        
        try await user.$technicalDocumentationTabs.attach(tab, on: req.db)
        return tab
    }
    
    func verifyPassword(req: Request) async throws -> HTTPResponseStatus {
        let user = try req.auth.require(User.self)
        let userID = try await getUserID(on: req)
        
        guard user.id == userID else {
            throw Abort(.forbidden, reason: "forbidden.access")
        }
        
        // Decode the request body containing the new password
        let passwordValidationRequest = try req.content.decode(PasswordValidationRequest.self)
        
        // Verify that the current password matches the one stored in the database
        let isCurrentPasswordValid = try Bcrypt.verify(passwordValidationRequest.currentPassword,
                                                       created: user.password)
        guard isCurrentPasswordValid else {
            throw Abort(.unauthorized, reason: "unauthorized.password.invalidCurrent")
        }
        
        return .ok
    }
}
