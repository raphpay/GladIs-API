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
        let userID = try await getUserID(on: req)
        let user = try await getUser(with: userID, on: req.db)
        
        user.firstConnection = false
        try await user.save(on: req.db)
        return user.convertToPublic()
    }
    
    func changePassword(req: Request) async throws -> PasswordChangeResponse {
        let user = try req.auth.require(User.self)
        let userID = try await getUserID(on: req)
        
        guard user.id == userID else {
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
        let userToUpdate = try await getUser(with: userID, on: req.db)
        
        userToUpdate.password = hashedNewPassword
        try await userToUpdate.save(on: req.db)
        
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
        let userID = try await getUserID(on: req)
        let client = try await getUser(with: userID, on: req.db)
        
        client.isBlocked = true
        try await client.save(on: req.db)
        
        return client.convertToPublic()
    }
    
    func unblockUser(req: Request) async throws -> User.Public {
        let userID = try await getUserID(on: req)
        let client = try await getUser(with: userID, on: req.db)
        
        client.isBlocked = false
        try await client.save(on: req.db)
        
        return client.convertToPublic()
    }

    func blockUserConnection(req: Request) async throws -> User.Public {
        let userID = try await getUserID(on: req)
        let user = try await getUser(with: userID, on: req.db)

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
        
        let userID = try await getUserID(on: req)
        let user = try await getUser(with: userID, on: req.db)

        user.isConnectionBlocked = false
        user.connectionFailedAttempts = 0

        try await user.update(on: req.db)

        return user.convertToPublic()
    }
    
    func updateUserInfos(req: Request) async throws -> User.Public {
        try User.Input.validate(content: req)
        
        let userID = try await getUserID(on: req)
        let user = try await getUser(with: userID, on: req.db)
        
        let updatedUserInput = try req.content.decode(User.UpdateInput.self)
        let updatedUser = try await updatedUserInput.update(user, on : req)
        try await updatedUser.update(on: req.db)
        
        return updatedUser.convertToPublic()
    }
    
    func removeEmployee(req: Request) async throws -> User.Public {
        let userID = try await getUserID(on: req)
        let manager = try await getUser(with: userID, on: req.db)
        
        let employeeID = req.parameters.get("employeeID")
        
        if let employeesIDs = manager.employeesIDs {
            let newArray = employeesIDs.filter { $0 != employeeID }
            manager.employeesIDs = newArray
        }
        
        try await manager.update(on: req.db)
        
        return manager.convertToPublic()
    }

    func updateModules(req: Request) async throws -> User.Public {
        let userID = try await getUserID(on: req)
        let user = try await getUser(with: userID, on: req.db)
        
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
