//
//  PotentialEmployeeController.swift
//
//
//  Created by Raphaël Payet on 06/03/2024.
//

import Fluent
import Vapor

struct PotentialEmployeeController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let employees = routes.grouped("api", "potentialEmployees")
        employees.post(use: create)
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = employees.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(":employeeID", "convertToUser", use: convertToUser)
        // Read
        tokenAuthGroup.get(use: getAll)
        // Delete
        tokenAuthGroup.delete(":company", use: removeByCompany)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> PotentialEmployee {
        try PotentialEmployee.Input.validate(content: req)
        let input = try req.content.decode(PotentialEmployee.Input.self)
        let employee = PotentialEmployee(firstName: input.firstName,
                                         lastName: input.lastName,
                                         companyName: input.companyName,
                                         phoneNumber: input.phoneNumber,
                                         email: input.email,
                                         pendingUserID: input.pendingUserID)
        
        try await employee.save(on: req.db)
        return employee
    }
    
    func convertToUser(req: Request) async throws -> User.Public {
        guard let potentialEmployee = try await PotentialEmployee.find(req.parameters.get("employeeID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.employee")
        }

        let input = try req.content.decode(PotentialEmployee.ConvertInput.self)
        
        let newEmployee = potentialEmployee.convertToEmployee()
        
        let givenPassword = input.password;
        do {
            try PasswordValidation().validatePassword(givenPassword)
        } catch {
            throw error
        }
        let passwordHash = try Bcrypt.hash(givenPassword)
        
        let username = try await User.generateUniqueUsername(firstName: newEmployee.firstName,
                                                             lastName: newEmployee.lastName, on: req)
        
        newEmployee.password = passwordHash
        newEmployee.username = username
        
        try await newEmployee.save(on: req.db)
        try await potentialEmployee.delete(force: true, on: req.db)
        return newEmployee.convertToPublic()
    }
    
    // MARK: - Read
    func getAll(req: Request) async throws -> [PotentialEmployee] {
        try await PotentialEmployee
            .query(on: req.db)
            .all()
    }
    
    // MARK: - Delete
    func removeByCompany(req: Request) async throws -> HTTPResponseStatus {
        guard let company = req.parameters.get("company") else {
            throw Abort(.badRequest, reason: "badRequest.company")
        }
        
        try await PotentialEmployee
            .query(on: req.db)
            .filter(\.$companyName == company)
            .all()
            .delete(force: true, on: req.db)
        
        return .noContent
    }
}
