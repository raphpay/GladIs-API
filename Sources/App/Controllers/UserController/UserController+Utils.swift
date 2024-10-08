//
//  File.swift
//  
//
//  Created by Raphaël Payet on 07/08/2024.
//

import Fluent
import Vapor

extension UserController {
    func create(_ input: User.Input, on req: Request) async throws -> User.Public {
        guard let inputPassword = input.password,
              !inputPassword.isEmpty else {
            throw Abort(.badRequest, reason: "badRequest.password")
        }
        
        try PasswordValidation().validatePassword(inputPassword)
        let passwordHash = try Bcrypt.hash(inputPassword)
        
        let username = try await User.generateUniqueUsername(firstName: input.firstName, lastName: input.lastName, on: req)
        let uniqueEmail = try await User.verifyUniqueEmail(input.email, on: req)
        
        let user = User(firstName: input.firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                        lastName: input.lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                        phoneNumber: input.phoneNumber, username: username, password: passwordHash,
                        email: uniqueEmail, firstConnection: true, userType: input.userType,
                        companyName: input.companyName, products: input.products,
                        numberOfEmployees: input.numberOfEmployees, numberOfUsers: input.numberOfUsers,
                        salesAmount: input.salesAmount, employeesIDs: input.employeesIDs,
                        managerID: input.managerID)
        
        try await user.save(on: req.db)
        
        return user.convertToPublic()
    }
    
    func getUserID(on req: Request) async throws -> User.IDValue {
        guard let userID = req.parameters.get("userID", as: User.IDValue.self) else {
            throw Abort(.badRequest, reason: "badRequest.missingOrIncorrectUserID")
        }
        
        return userID
    }
    
    func getUser(with id: User.IDValue, on db: Database) async throws -> User {
        guard let user = try await User.find(id, on: db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        return user
    }
    
    func updateUserSystemQualityFolder(user: User, folder: Folder, on req: Request) async throws {
        if var systemQualityFolders = user.systemQualityFolders {
            if let index = systemQualityFolders.firstIndex(where: { $0.id == folder.id }) {
                systemQualityFolders[index] = folder
            }
            user.systemQualityFolders = systemQualityFolders
        }
        
        try await user.update(on: req.db)
    }
    
    func updateUserRecordsFolder(user: User, folder: Folder, on req: Request) async throws {
        if var recordsFolders = user.recordsFolders {
            if let index = recordsFolders.firstIndex(where: { $0.id == folder.id }) {
                recordsFolders[index] = folder
            }
            user.recordsFolders = recordsFolders
        }
    }
    
    func removeSystemQualityFolder(user: User, folderID: Folder.IDValue, on req: Request) async throws {
        if let index = user.systemQualityFolders?.firstIndex(where: { $0.id == folderID }) {
            user.systemQualityFolders?.remove(at: index)
        }
        
        try await user.update(on: req.db)
    }
    
    func removeRecordFolder(user: User, folderID: Folder.IDValue, on req: Request) async throws {
        if let index = user.recordsFolders?.firstIndex(where: { $0.id == folderID }) {
            user.recordsFolders?.remove(at: index)
        }
        
        try await user.update(on: req.db)
    }
}
