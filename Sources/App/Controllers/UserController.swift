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
        // Delete
        tokenAuthGroup.delete(use: remove)
        tokenAuthGroup.delete("removeAll", use: removeAll)
    }
    
    // MARK: - Create
    func createWithoutToken(req: Request) throws -> EventLoopFuture<User.Public> {
        let userData = try req.content.decode(UserCreateData.self)
        
        guard !userData.password.isEmpty else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }
        
        do {
            try PasswordValidation().validatePassword(userData.password)
        } catch {
            throw error
        }
        let password = try Bcrypt.hash(userData.password)
        
        return User
            .generateUniqueUsername(firstName: userData.firstName, lastName: userData.lastName, on: req)
            .flatMap { username in
                let user = User(firstName: userData.firstName, lastName: userData.lastName, phoneNumber: userData.phoneNumber,
                                companyName: userData.companyName, email: userData.email, products: userData.products,
                                numberOfEmployees: userData.numberOfEmployees, numberOfUsers: userData.numberOfUsers,
                                salesAmount: userData.salesAmount,
                                username: username, password: password,
                                firstConnection: true, userType: userData.userType)
                
                return user
                    .save(on: req.db)
                    .map { user.convertToPublic() }
            }
    }
    
    func create(req: Request) throws -> EventLoopFuture<User.Public> {
        let userData = try req.content.decode(UserCreateData.self)
        let adminUser = try req.auth.require(User.self)
        
        guard !userData.password.isEmpty else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }
        
        guard adminUser.userType == .admin else {
            throw Abort(.badRequest, reason: "User should be admin to create another user")
        }
        
        do {
            try PasswordValidation().validatePassword(userData.password)
        } catch {
            throw error
        }
        let password = try Bcrypt.hash(userData.password)
        
        return User
            .generateUniqueUsername(firstName: userData.firstName, lastName: userData.lastName, on: req)
            .flatMap { username in
                let user = User(firstName: userData.firstName, lastName: userData.lastName, phoneNumber: userData.phoneNumber,
                                companyName: userData.companyName, email: userData.email, products: userData.products,
                                numberOfEmployees: userData.numberOfEmployees, numberOfUsers: userData.numberOfUsers,
                                salesAmount: userData.salesAmount,
                                username: username, password: password,
                                firstConnection: true, userType: userData.userType)
                
                return user
                    .save(on: req.db)
                    .map { user.convertToPublic() }
            }
    }
    
    
    func addModule(req: Request) throws -> EventLoopFuture<Module> {
        let userQuery = User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        let moduleQuery = Module
            .find(req.parameters.get("moduleID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return userQuery.and(moduleQuery)
            .flatMap { user, module in
                user
                    .$modules
                    .attach(module, on: req.db)
                    .map { module }
            }
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
    func getAll(req: Request) throws -> EventLoopFuture<[User.Public]> {
        User
            .query(on: req.db)
            .all()
            .convertToPublic()
    }
    
    func getUser(req: Request) throws -> EventLoopFuture<User.Public> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .map { user in
                return user.convertToPublic()
            }
    }
    
    func getModules(req: Request) throws -> EventLoopFuture<[Module]> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user
                    .$modules
                    .query(on: req.db)
                    .all()
            }
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
