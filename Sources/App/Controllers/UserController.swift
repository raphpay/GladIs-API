//
//  UserController.swift
//
//
//  Created by Raphaël Payet on 07/02/2024.
//


import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let users = routes.grouped("api", "users")
        users.post("noToken", use: createWithoutToken)
        users.post("byUsername", use: getUserByUsername)
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = users.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        tokenAuthGroup.post(":userID", "technicalDocumentationTabs", ":tabID", use: addTechnicalDocTab)
        tokenAuthGroup.post(":userID", "verifyPassword", use: verifyPassword)
        tokenAuthGroup.post("byMail", use: getUserByMail)
        // Read
        tokenAuthGroup.get(use: getAll)
        tokenAuthGroup.get("clients", use: getAllClients)
        tokenAuthGroup.get("admins", use: getAdmins)
        tokenAuthGroup.get(":userID", use: getUser)
        tokenAuthGroup.get(":userID", "modules", use: getModules)
        tokenAuthGroup.get(":userID", "technicalDocumentationTabs", use: getTechnicalDocumentationTabs)
        tokenAuthGroup.get(":userID", "manager", use: getManager)
        tokenAuthGroup.get(":userID", "employees", use: getEmployees)
        tokenAuthGroup.get(":userID", "token", use: getToken)
        tokenAuthGroup.get(":userID", "resetToken", use: getResetTokensForClient)
        tokenAuthGroup.get(":userID", "messages", "all", use: getUserMessages)
        tokenAuthGroup.get(":userID", "messages", "received", use: getReceivedMessages)
        tokenAuthGroup.get(":userID", "messages", "sent", use: getSentMessages)
        // Update
        tokenAuthGroup.put(":userID", "setFirstConnectionToFalse", use: setUserFirstConnectionToFalse)
        tokenAuthGroup.put(":userID", "changePassword", use: changePassword)
        tokenAuthGroup.put(":userID", "addManager", ":managerID", use: addManager)
        tokenAuthGroup.put(":userID", "block", use: blockUser)
        tokenAuthGroup.put(":userID", "unblock", use: unblockUser)
        tokenAuthGroup.put(":userID", "updateInfos", use: updateUserInfos)
        tokenAuthGroup.put(":userID", "remove", ":employeeID", use: removeEmployee)
        tokenAuthGroup.put(":userID", "modules", use: updateModules)
        // Delete
        tokenAuthGroup.delete(":userID", use: remove)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    // MARK: - Create
    func createWithoutToken(req: Request) async throws -> User.Public {
        let input = try req.content.decode(User.Input.self)
        
        guard let inputPassword = input.password,
            !inputPassword.isEmpty else {
            throw Abort(.badRequest, reason: "badRequest.password")
        }
        
        try PasswordValidation().validatePassword(inputPassword)
        let passwordHash = try Bcrypt.hash(inputPassword)
        
        let username = try await User.generateUniqueUsername(firstName: input.firstName, lastName: input.lastName, on: req)
        let uniqueEmail = try await User.verifyUniqueEmail(input.email, on: req)
        let user = User(firstName: input.firstName, lastName: input.lastName,
                        phoneNumber: input.phoneNumber, username: username, password: passwordHash,
                        email: uniqueEmail, firstConnection: true, userType: input.userType,
                        companyName: input.companyName, products: input.products,
                        numberOfEmployees: input.numberOfEmployees, numberOfUsers: input.numberOfUsers,
                        salesAmount: input.salesAmount, employeesIDs: input.employeesIDs,
                        managerID: input.managerID)
        try await user.save(on: req.db)
        return user.convertToPublic()
    }
    
    func create(req: Request) async throws -> User.Public {
        try User.Input.validate(content: req)
        let input = try req.content.decode(User.Input.self)
        let adminUser = try req.auth.require(User.self)
        
        guard let inputPassword = input.password,
              !inputPassword.isEmpty else {
            throw Abort(.badRequest, reason: "badRequest.password")
        }
        
        guard adminUser.userType == .admin else {
            throw Abort(.forbidden, reason: "forbidden.userShouldBeAdmin")
        }
        

        try PasswordValidation().validatePassword(inputPassword)
        let passwordHash = try Bcrypt.hash(inputPassword)
        
        let username = try await User.generateUniqueUsername(firstName: input.firstName, lastName: input.lastName, on: req)
        let uniqueEmail = try await User.verifyUniqueEmail(input.email, on: req)
        
        let user = User(firstName: input.firstName, lastName: input.lastName,
                        phoneNumber: input.phoneNumber, username: username, password: passwordHash,
                        email: uniqueEmail, firstConnection: true, userType: input.userType,
                        companyName: input.companyName, products: input.products,
                        numberOfEmployees: input.numberOfEmployees, numberOfUsers: input.numberOfUsers,
                        salesAmount: input.salesAmount, employeesIDs: input.employeesIDs,
                        managerID: input.managerID)
        
        try await user.save(on: req.db)
        return user.convertToPublic()
    }
    
    func addTechnicalDocTab(req: Request) async throws -> TechnicalDocumentationTab {
        guard let userQuery = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
                
          guard let tabQuery = try await TechnicalDocumentationTab.find(req.parameters.get("tabID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.technicalTab")
        }
        
        try await userQuery.$technicalDocumentationTabs.attach(tabQuery, on: req.db)
        return tabQuery
    }
    
    func verifyPassword(req: Request) async throws -> HTTPResponseStatus {
        let user = try req.auth.require(User.self)
        let userId = try req.parameters.require("userID", as: UUID.self)
        
        guard user.id == userId else {
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
    
    // MARK: - Read
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
    
    // MARK: - Update
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
    
    func updateUserInfos(req: Request) async throws -> User.Public {
        try User.Input.validate(content: req)
        
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        let updatedUser = try req.content.decode(User.Input.self)
        
        user.firstName = updatedUser.firstName
        user.lastName = updatedUser.lastName
        user.email = updatedUser.email
        user.phoneNumber = updatedUser.phoneNumber
        
        try await user.update(on: req.db)
        
        return user.convertToPublic()
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

    // MARK: - Delete
    func remove(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        try await user.delete(force: true, on: req.db)
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
