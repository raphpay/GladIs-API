//
//  PendingUserController.swift
//
//
//  Created by Raphaël Payet on 12/02/2024.
//

import Fluent
import Vapor

struct PendingUserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let pendingUsers = routes.grouped("api", "pendingUsers")
        pendingUsers.post(use: create)
        pendingUsers.get(":pendingUserID", "modules", use: getModules)
        pendingUsers.put(":pendingUserID", "modules", use: updateModules)
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = pendingUsers.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Post
        tokenAuthGroup.post(":pendingUserID", "convertToUser", use: convertToUser)
        // Read
        tokenAuthGroup.get(use: getAll)
        tokenAuthGroup.get(":pendingUserID", use: getAll)
        tokenAuthGroup.get(":pendingUserID", "employees", use: getEmployees)
        // Update
        tokenAuthGroup.put(":pendingUserID", "status", use: updateStatus)
        // Delete
        tokenAuthGroup.delete(":pendingUserID", use: remove)
    }
    
    // MARK: - CREATE
    func create(req: Request) async throws -> PendingUser {
        try PendingUser.Input.validate(content: req)
        let input = try req.content.decode(PendingUser.Input.self)
        let uniqueEmail = try await PendingUser.verifyUniqueEmail(input.email, on: req)
        
        let user = PendingUser(firstName: input.firstName, lastName: input.lastName,
                               phoneNumber: input.phoneNumber, companyName: input.companyName,
                               email: uniqueEmail, products: input.products, numberOfEmployees: input.numberOfEmployees,
                               numberOfUsers: input.numberOfUsers, salesAmount: input.salesAmount)
        
        try await user.save(on: req.db)
        return user
    }

    func updateModules(req: Request) async throws -> PendingUser {
        guard let pendingUser = try await PendingUser.find(req.parameters.get("pendingUserID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.pendingUser")
        }
        
        let moduleInputs = try req.content.decode([Module.Input].self)
        var modules: [Module] = []

        for mod in moduleInputs {
            let module = Module(name: mod.name, index: mod.index)
            modules.append(module)    
        }
        
        pendingUser.modules = modules
        
        try await pendingUser.update(on: req.db)
        
        return pendingUser
    }
    
    func convertToUser(req: Request) async throws -> User.Public {
        let user = try req.auth.require(User.self)
        
        guard user.userType == .admin else {
            throw Abort(.forbidden, reason: "forbidden.userShouldBeAdmin")
        }
        
        guard let pendingUser = try await PendingUser.find(req.parameters.get("pendingUserID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.pendingUser")
        }
        
        let newUser = pendingUser.convertToUser()
        let username = try await User.generateUniqueUsername(firstName: newUser.firstName, lastName: newUser.lastName, on: req)
        let givenPassword = "Passwordlong1("
        do {
            try PasswordValidation().validatePassword(givenPassword)
        } catch {
            throw error
        }
        let passwordHash = try Bcrypt.hash(givenPassword)
        
        newUser.password = passwordHash
        newUser.username = username
        
        try await newUser.save(on: req.db)
        try await pendingUser.delete(force: true, on: req.db)
        return newUser.convertToPublic()
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [PendingUser] {
        let authUser = try req.auth.require(User.self)
        
        guard authUser.userType == .admin else {
            throw Abort(.forbidden, reason: "forbidden.userShouldBeAdmin")
        }
        
        return try await PendingUser
            .query(on: req.db)
            .all()
    }
    
   func getModules(req: Request) async throws -> [Module] {
       guard let pendingUser = try await PendingUser.find(req.parameters.get("pendingUserID"), on: req.db) else {
           throw Abort(.notFound, reason: "notFound.pendingUser")
       }

        var usersModules: [Module] = []

        if let modules = pendingUser.modules {
            usersModules = modules
        }

        return usersModules
   }
    
    func getEmployees(req: Request) async throws -> [PotentialEmployee] {
        guard let pendingUser = try await PendingUser.find(req.parameters.get("pendingUserID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.pendingUser")
        }
        
        let employees = try await pendingUser.$potentialEmployees
            .query(on: req.db)
            .all()
        
        return employees
    }
    
    // MARK: - UPDATE
    func updateStatus(req: Request) async throws -> PendingUser {
        let user = try req.auth.require(User.self)
        
        guard user.userType == .admin else {
            throw Abort(.forbidden, reason: "forbidden.userShouldBeAdmin")
        }
        
        let newStatus = try req.content.decode(PendingUser.StatusInput.self)
        
        guard let pendingUser = try await PendingUser.find(req.parameters.get("pendingUserID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFount.pendingUser")
        }
        
        pendingUser.status = newStatus.type
        try await pendingUser.save(on: req.db)
        return pendingUser
    }
    
    // MARK: - DELETE
    func remove(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        
        guard user.userType == .admin else {
            throw Abort(.forbidden, reason: "forbidden.userShouldBeAdmin")
        }
        
        guard let pendingUser = try await PendingUser.find(req.parameters.get("pendingUserID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.pendingUser")
        }
        
        try await pendingUser.delete(on: req.db)
        
        return .noContent
    }
}
