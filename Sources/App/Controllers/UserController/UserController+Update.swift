//
//  File.swift
//  
//
//  Created by Raphaël Payet on 07/08/2024.
//

import Fluent
import Vapor

// MARK: - Update
extension UserController {
    func setUserFirstConnectionToFalse(req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        user.firstConnection = false
        try await user.save(on: req.db)
        return user.convertToPublic()
    }
    
    func changePassword(req: Request) async throws -> PasswordChangeResponse {
        let user = try req.auth.require(User.self)
        let userId = try req.parameters.require("userID", as: UUID.self)
        
        guard user.id == userId else {
            throw Abort(.forbidden, reason: "forbidden.wrongUser")
        }
        
        // Decode the request body containing the new password
        let changeRequest = try req.content.decode(PasswordChangeRequest.self)
        
        // Verify that the current password matches the one stored in the database
        let isCurrentPasswordValid = try Bcrypt.verify(changeRequest.currentPassword,
                                                       created: user.password)
        guard isCurrentPasswordValid else {
            throw Abort(.unauthorized, reason: "unauthorized.password.invalidCurrent")
        }
        
        try PasswordValidation().validatePassword(changeRequest.newPassword)
        
        // Hash the new password
        let hashedNewPassword = try Bcrypt.hash(changeRequest.newPassword)
        
        // Update the user's password in the database
        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        user.password = hashedNewPassword
        try await user.save(on: req.db)
        
        return PasswordChangeResponse(message: "success.passwordChanged")
    }
    
    func addManager(req: Request) async throws -> User.Public {
        guard let managerID = req.parameters.get("managerID"),
              let employeeID = req.parameters.get("userID"),
            let manager = try await User.find(UUID(uuidString: managerID), on: req.db),
              let employee = try await User.find(UUID(uuidString: employeeID), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        if let managerEmployees = manager.employeesIDs {
            if !managerEmployees.contains(employeeID) {
                manager.employeesIDs?.append(employeeID)
            } else {
                throw Abort(.badRequest, reason: "badRequest.managerAlreadySet")
            }
        } else {
            manager.employeesIDs = [employeeID]
        }
        employee.managerID = managerID
        
        try await manager.save(on: req.db)
        try await employee.save(on: req.db)
        
        return employee.convertToPublic()
    }
    
    func blockUser(req: Request) async throws -> User.Public {
        guard let client = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        client.isBlocked = true
        try await client.save(on: req.db)
        
        return client.convertToPublic()
    }
    
    func unblockUser(req: Request) async throws -> User.Public {
        guard let client = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        client.isBlocked = false
        try await client.save(on: req.db)
        
        return client.convertToPublic()
    }

    func blockUserConnection(req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }

        if let connectionFailedAttempts = user.connectionFailedAttempts {
            user.connectionFailedAttempts = connectionFailedAttempts + 1
            if connectionFailedAttempts + 1 >= 5 {
                user.isConnectionBlocked = true
            }
        } else {
            user.connectionFailedAttempts = 1
        }
        
        try await user.update(on: req.db)
        return user.convertToPublic()
    }

    func unblockUserConnection(req: Request) async throws -> User.Public {
        let authUser = try req.auth.require(User.self)
        guard authUser.userType == .admin else {
            throw Abort(.forbidden, reason: "forbidden.userShouldBeAdmin")
        }

        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }

        user.isConnectionBlocked = false
        user.connectionFailedAttempts = 0

        try await user.update(on: req.db)

        return user.convertToPublic()
    }
    
    func updateUserInfos(req: Request) async throws -> User.Public {
        try User.Input.validate(content: req)
        
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        let updatedUserInput = try req.content.decode(User.UpdateInput.self)
        let updatedUser = try await updatedUserInput.update(user, on : req)
        try await updatedUser.update(on: req.db)
        
        return updatedUser.convertToPublic()
    }
    
    func removeEmployee(req: Request) async throws -> User.Public {
        guard let manager = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        let employeeID = req.parameters.get("employeeID")
        
        if let employeesIDs = manager.employeesIDs {
            let newArray = employeesIDs.filter { $0 != employeeID }
            manager.employeesIDs = newArray
        }
        
        try await manager.update(on: req.db)
        
        return manager.convertToPublic()
    }

    func updateModules(req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        let moduleInputs = try req.content.decode([Module.Input].self)
        var modules: [Module] = []

        for mod in moduleInputs {
            let module = Module(name: mod.name, index: mod.index)
            modules.append(module)
        }
        
        user.modules = modules
        
        try await user.update(on: req.db)
        
        return user.convertToPublic()
    }
}
