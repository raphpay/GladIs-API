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
        tokenAuthGroup.post(":userID", "technicalDocumentationTabs", ":tabID", use: addTechnicalDocTab)
        // Read
        tokenAuthGroup.get(use: getAll)
        tokenAuthGroup.get(":userID", use: getUser)
        tokenAuthGroup.get(":userID", "modules", use: getModules)
        tokenAuthGroup.get(":userID", "technicalDocumentationTabs", use: getTechnicalDocumentationTabs)
        // Update
        tokenAuthGroup.put(":userID", "setFirstConnectionToFalse", use: setUserFirstConnectionToFalse)
        tokenAuthGroup.put(":userID", "changePassword", use: changePassword)
        tokenAuthGroup.put("addEmployee", ":clientID", ":employeeID", use: linkClientToEmployee)
        tokenAuthGroup.put("addManager", ":employeeID", ":clientID", use: linkEmployeeToClient)
        // Delete
        tokenAuthGroup.delete(use: remove)
        tokenAuthGroup.delete("removeAll", use: removeAll)
    }
    
    // MARK: - Create
    func createWithoutToken(req: Request) async throws -> User.Public {
        let input = try req.content.decode(User.Input.self)
        
        guard !input.password.isEmpty else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }
        
        do {
            try PasswordValidation().validatePassword(input.password)
        } catch {
            throw error
        }
        let passwordHash = try Bcrypt.hash(input.password)
        
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
        
        guard !input.password.isEmpty else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }
        
        guard adminUser.userType == .admin else {
            throw Abort(.badRequest, reason: "User should be admin to create another user")
        }
        
        do {
            try PasswordValidation().validatePassword(input.password)
        } catch {
            throw error
        }
        let passwordHash = try Bcrypt.hash(input.password)
        
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
        guard let userQuery = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let moduleQuery = try await Module.find(req.parameters.get("moduleID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await userQuery.$modules.attach(moduleQuery, on: req.db)
        
        return moduleQuery
    }
    
    func addTechnicalDocTab(req: Request) throws -> EventLoopFuture<TechnicalDocumentationTab> {
        let userQuery = User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        let tabQuery = TechnicalDocumentationTab
            .find(req.parameters.get("tabID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return userQuery.and(tabQuery)
            .flatMap { user, tab in
                user
                    .$technicalDocumentationTabs
                    .attach(tab, on: req.db)
                    .map { tab }
            }
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
    
    // MARK: - Update
    func setUserFirstConnectionToFalse(req: Request) throws -> EventLoopFuture<User.Public> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.firstConnection = false
                return user
                    .save(on: req.db)
                    .map { user.convertToPublic() }
            }
    }
    
    func changePassword(req: Request) throws -> EventLoopFuture<PasswordChangeResponse> {
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
            throw Abort(.unauthorized, reason: "Invalid current password")
        }
        
        do {
            try PasswordValidation().validatePassword(changeRequest.newPassword)
        } catch {
            throw error
        }
        
        // Hash the new password
        let hashedNewPassword = try Bcrypt.hash(changeRequest.newPassword)
        
        // Update the user's password in the database
        return User
            .find(userId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.password = hashedNewPassword
                return user
                    .save(on: req.db)
                    .transform(to: PasswordChangeResponse(message: "Password changed successfully"))
            }
    }
    
    func linkClientToEmployee(req: Request) throws -> EventLoopFuture<User.Public> {
        guard let employeeID = req.parameters.get("employeeID") else {
            throw Abort(.badRequest, reason: "Employee ID is missing in parameters")
        }
        
        return User
            .find(req.parameters.get("clientID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                if user.employeesIDs == nil {
                    user.employeesIDs = [employeeID]
                } else {
                    user.employeesIDs?.append(employeeID)
                }
                
                return user
                    .save(on: req.db)
                    .map { user.convertToPublic() }
            }
    }
    
    func linkEmployeeToClient(req: Request) throws -> EventLoopFuture<User.Public> {
        guard let clientID = req.parameters.get("clientID") else {
            throw Abort(.badRequest, reason: "Client ID is missing in parameters")
        }
        
        return User
            .find(req.parameters.get("employeeID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.managerID = clientID
                
                return user.save(on: req.db)
                    .map { user.convertToPublic() }
            }
    }
    
    // MARK: - Delete
    func remove(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user
                    .delete(force: true, on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func removeAll(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        User
            .query(on: req.db)
            .all()
            .flatMap { user in
                user
                    .delete(force: true, on: req.db)
                    .transform(to: .noContent)
            }
    }
}
