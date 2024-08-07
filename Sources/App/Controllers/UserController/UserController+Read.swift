//
//  File.swift
//  
//
//  Created by Raphaël Payet on 07/08/2024.
//

import Fluent
import Vapor

// MARK: - Read
extension UserController {
    func getAll(req: Request) async throws -> [User.Public] {
        try await User
            .query(on: req.db)
            .all()
            .convertToPublic()
    }
    
    func getAllClients(req: Request) async throws -> [User.Public] {
        try await User
            .query(on: req.db)
            .filter(\.$userType == .client)
            .all()
            .convertToPublic()
    }
    
    func getAdmins(req: Request) async throws -> [User.Public] {
        try await User
            .query(on: req.db)
            .filter(\.$userType == .admin)
            .all()
            .convertToPublic()
    }
    
    func getUser(req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        return user.convertToPublic()
    }
    
    func getModules(req: Request) async throws -> [Module] {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }

        var usersModules: [Module] = []

        if let modules = user.modules {
            usersModules = modules
        }
        
        return usersModules
    }
    
    func getTechnicalDocumentationTabs(req: Request) async throws -> [TechnicalDocumentationTab] {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        return try await user.$technicalDocumentationTabs.query(on: req.db).all()
    }
    
    func getManager(req: Request) async throws -> User.Public {
        guard let employee = try await User.find(req.parameters.get("userID"), on: req.db),
              let managerID = employee.managerID,
              let manager = try await User.find(UUID(uuidString: managerID), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        return manager.convertToPublic()
    }
    
    func getEmployees(req: Request) async throws -> [User.Public] {
        guard let manager = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        var employees: [User.Public] = []
        if let employeesIDs = manager.employeesIDs {
            for employeeID in employeesIDs {
                guard let id = UUID(uuidString: employeeID) else {
                    throw Abort(.notFound, reason: "notFound.user")
                }
                
                guard let employee = try await User
                    .query(on: req.db)
                    .filter(\.$id == id)
                    .first() else {
                    throw Abort(.notFound, reason: "notFound.user")
                }
                
                employees.append(employee.convertToPublic())
            }
        }
        
        return employees
    }
    
    func getToken(req: Request) async throws -> Token {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db),
              let token = try await user.$tokens.query(on: req.db).first() else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        return token
    }
    
    func getResetTokensForClient(req: Request) async throws -> PasswordResetToken {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db),
              let resetToken = try await user.$resetTokens.query(on: req.db).first() else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        let authUser = try req.auth.require(User.self)
        
        guard authUser.userType == .admin else {
            throw Abort(.forbidden, reason: "forbidden.userShouldBeAdmin")
        }
        
        return resetToken
    }
    
    func getUserByMail(req: Request) async throws -> User.Public {
        try User.EmailInput.validate(content: req)
        
        let input = try req.content.decode(User.EmailInput.self)
        
        guard let user = try await User
            .query(on: req.db)
            .filter(\.$email == input.email)
            .first() else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        return user.convertToPublic()
    }
    
    func getUserByUsername(req: Request) async throws -> User.Public {
        let input = try req.content.decode(User.UsernameInput.self)
        
        guard let user = try await User
            .query(on: req.db)
            .filter(\.$username == input.username)
            .first() else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        return user.convertToPublic()
    }
    
    func getSentMessages(req: Request) async throws -> [Message] {
        guard let userID = req.parameters.get("userID"),
              let uuid = UUID(uuidString: userID) else {
            throw Abort(.badRequest, reason: "badRequest.emptyUserID")
        }
        
        let messages = try await Message
            .query(on: req.db)
            .filter(\.$sender.$id == uuid)
            .sort(\.$dateSent, .ascending)
            .all()
        
        return messages
    }
    
    func getReceivedMessages(req: Request) async throws -> [Message] {
        guard let userID = req.parameters.get("userID"),
              let uuid = UUID(uuidString: userID) else {
            throw Abort(.badRequest, reason: "badRequest.emptyUserID")
        }
        
        let messages = try await Message
            .query(on: req.db)
            .filter(\.$receiver.$id == uuid)
            .sort(\.$dateSent, .ascending)
            .all()
        
        return messages
    }
    
    func getUserMessages(req: Request) async throws -> [Message] {
        let sentMessages = try await getSentMessages(req: req)
        let receivedMessages = try await getReceivedMessages(req: req)
        
        let overallMessages = sentMessages + receivedMessages
        
        var seenIds = Set<UUID>()
        let uniqueMessages = overallMessages.filter { message in
            guard let id = message.id, !seenIds.contains(id) else { return false }
            seenIds.insert(id)
            return true
        }

        let sortedMessages = uniqueMessages.sorted(by: { $0.dateSent < $1.dateSent })
        
        return sortedMessages
    }

    func getUserLoginTryOutput(req: Request) async throws -> User.LoginTryOutput {
        let username = try req.content.decode(User.UsernameInput.self).username

        guard let user = try await User
            .query(on: req.db)
            .filter(\.$username == username)
            .first() else {
            throw Abort(.notFound, reason: "notFound.user")
        }

        return user.convertToLoginTryOutput()
    }
    
    func getSystemQualityFolders(req: Request) async throws -> [Process] {
        guard let userID = req.parameters.get("userID", as: User.IDValue.self) else {
            throw Abort(.badRequest, reason: "badRequest.emptyUserID")
        }
        
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        return user.systemQualityFolders  ?? []
    }
    
    func getRecordsFolders(req: Request) async throws -> [Process] {
        guard let userID = req.parameters.get("userID", as: User.IDValue.self) else {
            throw Abort(.badRequest, reason: "badRequest.emptyUserID")
        }
        
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        return user.recordsFolders ?? []
    }
}
