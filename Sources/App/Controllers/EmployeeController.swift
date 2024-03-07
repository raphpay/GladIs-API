//
//  EmployeeController.swift
//
//
//  Created by Raphaël Payet on 07/03/2024.
//

import Fluent
import Vapor

struct EmployeeController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let employees = routes.grouped("api", "employees")
        employees.post(use: create)
        employees.get(use: getAll)
        employees.get(":employeeID", "company", use: getUsersCompany)
    }
    
    
    // MARK: - CREATE
    func create(req: Request) async throws -> Employee.Public {
        let input = try req.content.decode(Employee.Input.self)
        
        guard !input.password.isEmpty else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }
        
        do {
            try PasswordValidation().validatePassword(input.password)
        } catch {
            throw error
        }
        let passwordHash = try Bcrypt.hash(input.password)
        
        let username = try await Employee.generateUniqueUsername(firstName: input.firstName, lastName: input.lastName, req: req)
        
        let employee = Employee(firstName: input.firstName, lastName: input.lastName, username: username, password: passwordHash, userID: input.userID)
        try await employee.save(on: req.db)
        return employee.convertToPublic()
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [Employee] {
        try await Employee.query(on: req.db).all()
    }
    
    func getUsersCompany(req: Request) async throws -> String {
        guard let employee = try await Employee.find(req.parameters.get("employeeID"), on: req.db),
              let user = try await User.find(employee.$user.id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return user.companyName ?? "No company"
    }
    
    func getUser(req: Request) async throws -> User.Public {
        guard let employee = try await Employee.find(req.parameters.get("employeeID"), on: req.db),
              let user = try await User.find(employee.$user.id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return user.convertToPublic()
    }
}


