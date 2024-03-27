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
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = users.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        tokenAuthGroup.post(":userID", "modules", ":moduleID", use: addModule)
        tokenAuthGroup.post(":userID", "remove", "modules", ":moduleID", use: removeModule)
        tokenAuthGroup.post(":userID", "technicalDocumentationTabs", ":tabID", use: addTechnicalDocTab)
        // Read
        tokenAuthGroup.get(use: getAll)
        tokenAuthGroup.get(":userID", use: getUser)
        tokenAuthGroup.get(":userID", "modules", use: getModules)
        tokenAuthGroup.get(":userID", "technicalDocumentationTabs", use: getTechnicalDocumentationTabs)
        tokenAuthGroup.get(":userID", "manager", use: getManager)
        tokenAuthGroup.get(":userID", "employees", use: getEmployees)
        tokenAuthGroup.get(":userID", "token", use: getToken)
        tokenAuthGroup.get(":userID", "resetToken", use: getToken)
        tokenAuthGroup.get("byMail", use: getUserByMail)
        // Update
        tokenAuthGroup.put(":userID", "setFirstConnectionToFalse", use: setUserFirstConnectionToFalse)
        tokenAuthGroup.put(":userID", "changePassword", use: changePassword)
        tokenAuthGroup.put(":userID", "addManager", ":managerID", use: addManager)
        tokenAuthGroup.put(":userID", "block", use: blockUser)
        tokenAuthGroup.put(":userID", "unblock", use: unblockUser)
        tokenAuthGroup.put(":userID", "updateInfos", use: updateUserInfos)
        tokenAuthGroup.put(":userID", "remove", ":employeeID", use: removeEmployee)
        // Delete
        tokenAuthGroup.delete(":userID", use: remove)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    // MARK: - Create
    func createWithoutToken(req: Request) async throws -> User.Public {
        let input = try req.content.decode(User.Input.self)
        
        guard let inputPassword = input.password,
            !inputPassword.isEmpty else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }
        
        do {
            try PasswordValidation().validatePassword(inputPassword)
        } catch {
            throw error
        }
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
        
        var password = "Passwordlong1("
        
        if let inputPassword = input.password,
            !inputPassword.isEmpty {
            password = inputPassword
        }
        
        guard adminUser.userType == .admin else {
            throw Abort(.badRequest, reason: "User should be admin to create another user")
        }
        
        do {
            try PasswordValidation().validatePassword(password)
        } catch {
            throw error
        }
        let passwordHash = try Bcrypt.hash(password)
        
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
    
    func addModule(req: Request) async throws -> Module {
        guard let userQuery = try await User.find(req.parameters.get("userID"), on: req.db),
              let moduleQuery = try await Module.find(req.parameters.get("moduleID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await userQuery.$modules.attach(moduleQuery, on: req.db)
        return moduleQuery
    }
    
    func removeModule(req: Request) async throws -> [Module] {
        guard let userQuery = try await User.find(req.parameters.get("userID"), on: req.db),
              let moduleQuery = try await Module.find(req.parameters.get("moduleID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await userQuery.$modules.detach(moduleQuery, on: req.db)
        
        return try await userQuery.$modules.query(on: req.db).all()
    }
    
    func addTechnicalDocTab(req: Request) async throws -> TechnicalDocumentationTab {
        guard let userQuery = try await User.find(req.parameters.get("userID"), on: req.db),
              let tabQuery = try await TechnicalDocumentationTab.find(req.parameters.get("tabID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await userQuery.$technicalDocumentationTabs.attach(tabQuery, on: req.db)
        return tabQuery
    }
    
    // MARK: - Read
    func getAll(req: Request) async throws -> [User.Public] {
        try await User
            .query(on: req.db)
            .all()
            .convertToPublic()
    }
    
    func getUser(req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        return user.convertToPublic()
    }
    
    func getModules(req: Request) async throws -> [Module] {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        return try await user.$modules.query(on: req.db).all()
    }
    
    func getTechnicalDocumentationTabs(req: Request) throws -> EventLoopFuture<[TechnicalDocumentationTab]> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user
                    .$technicalDocumentationTabs
                    .query(on: req.db)
                    .all()
            }
    }
    
    func getManager(req: Request) async throws -> User.Public {
        guard let employee = try await User.find(req.parameters.get("userID"), on: req.db),
              let managerID = employee.managerID,
              let manager = try await User.find(UUID(uuidString: managerID), on: req.db) else {
            throw Abort(.notFound)
        }
        
        return manager.convertToPublic()
    }
    
    func getEmployees(req: Request) async throws -> [User.Public] {
        guard let manager = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        var employees: [User.Public] = []
        if let employeesIDs = manager.employeesIDs {
            for employeeID in employeesIDs {
                guard let id = UUID(uuidString: employeeID) else {
                    throw Abort(.notFound)
                }
                
                guard let employee = try await User
                    .query(on: req.db)
                    .filter(\.$id == id)
                    .first() else {
                    throw Abort(.notFound)
                }
                
                employees.append(employee.convertToPublic())
            }
        }
        
        return employees
    }
    
    func getToken(req: Request) async throws -> Token {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db),
              let token = try await user.$tokens.query(on: req.db).first() else {
            throw Abort(.notFound)
        }
        
        return token
    }
    
    func getResetTokens(req: Request) async throws -> PasswordResetToken {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db),
              let resetToken = try await user.$resetTokens.query(on: req.db).first() else {
            throw Abort(.notFound)
        }
        
        return resetToken
    }
    
    func getUserByMail(req: Request) async throws -> User.Public {
        let input = try req.content.decode(User.EmailInput.self)
        
        guard let user = try await User
            .query(on: req.db)
            .filter(\.$email == input.email)
            .first() else {
            throw Abort(.notFound)
        }
        
        return user.convertToPublic()
    }
    
    // MARK: - Update
    func updateUserInfos(req: Request) async throws -> User.Public {
        try User.Input.validate(content: req)
        
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let updatedUser = try req.content.decode(User.Input.self)
        
        user.firstName = updatedUser.firstName
        user.lastName = updatedUser.lastName
        user.email = updatedUser.email
        user.phoneNumber = updatedUser.phoneNumber
        
        try await user.update(on: req.db)
        
        return user.convertToPublic()
    }
    
    func setUserFirstConnectionToFalse(req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        user.firstConnection = false
        try await user.save(on: req.db)
        return user.convertToPublic()
    }
    
    func changePassword(req: Request) async throws -> PasswordChangeResponse {
        let user = try req.auth.require(User.self)
        let userId = try req.parameters.require("userID", as: UUID.self)
        
        guard user.id == userId else {
            throw Abort(.forbidden, reason: "Unauthorized access")
        }
        
        // Decode the request body containing the new password
        let changeRequest = try req.content.decode(PasswordChangeRequest.self)
        
        // Verify that the current password matches the one stored in the database
        let isCurrentPasswordValid = try Bcrypt.verify(changeRequest.currentPassword, created: user.password)
        guard isCurrentPasswordValid else {
            throw Abort(.unauthorized, reason: "password.current.invalid")
        }
        
        do {
            try PasswordValidation().validatePassword(changeRequest.newPassword)
        } catch {
            throw error
        }
        
        // Hash the new password
        let hashedNewPassword = try Bcrypt.hash(changeRequest.newPassword)
        
        // Update the user's password in the database
        
        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        user.password = hashedNewPassword
        try await user.save(on: req.db)
        
        return PasswordChangeResponse(message: "Password changed successfully")
    }
    
    func addManager(req: Request) async throws -> User.Public {
        guard let managerID = req.parameters.get("managerID"),
              let employeeID = req.parameters.get("userID"),
            let manager = try await User.find(UUID(uuidString: managerID), on: req.db),
              let employee = try await User.find(UUID(uuidString: employeeID), on: req.db) else {
            throw Abort(.notFound)
        }
        
        if let managerEmployees = manager.employeesIDs {
            if !managerEmployees.contains(employeeID) {
                manager.employeesIDs?.append(employeeID)
            } else {
                throw Abort(.badRequest, reason: "Manager is already set")
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
            throw Abort(.notFound)
        }
        
        client.isBlocked = true
        try await client.save(on: req.db)
        
        return client.convertToPublic()
    }
    
    func unblockUser(req: Request) async throws -> User.Public {
        guard let client = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        client.isBlocked = false
        try await client.save(on: req.db)
        
        return client.convertToPublic()
    }
    
    func removeEmployee(req: Request) async throws -> User.Public {
        guard let manager = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let employeeID = req.parameters.get("employeeID")
        
        
        
        if let employeesIDs = manager.employeesIDs {
            let newArray = employeesIDs.filter { $0 != employeeID }
            manager.employeesIDs = newArray
        }
        
        try await manager.update(on: req.db)
        
        return manager.convertToPublic()
    }
    
    // MARK: - Delete
    func remove(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
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
