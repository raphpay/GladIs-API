//
//  File.swift
//  
//
//  Created by Raphaël Payet on 07/03/2024.
//


import Fluent
import Vapor

struct AdminUserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let admins = routes.grouped("api", "adminUsers")
        admins.post("noToken", use: createWithoutToken)
        admins.get(use: getAll)
    }
    
    // MARK: - CREATE
    func createWithoutToken(req: Request) async throws -> AdminUser.Public {
        try AdminUser.Input.validate(content: req)
        let input = try req.content.decode(AdminUser.Input.self)
        
        guard !input.password.isEmpty else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }
        
        do {
            try PasswordValidation().validatePassword(input.password)
        } catch {
            throw error
        }
        let passwordHash = try Bcrypt.hash(input.password)
        
        let username = try await AdminUser.generateUniqueUsername(firstName: input.firstName, lastName: input.lastName, on: req)
        
        let admin = AdminUser(firstName: input.firstName, lastName: input.lastName,
                              phoneNumber: input.phoneNumber, username: username,
                              password: passwordHash, email: input.email, firstConnection: true)
     
        try await admin.save(on: req.db)
        return admin.convertToPublic()
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [AdminUser.Public] {
        try await AdminUser.query(on: req.db)
            .all()
            .convertToPublic()
    }
}
