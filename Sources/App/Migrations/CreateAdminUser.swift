//
//  CreateAdminUser.swift
//  
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Fluent
import Vapor

struct CreateAdminUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let passwordHash: String
        do {
            passwordHash = try Bcrypt.hash("password")
        } catch {
            return database.eventLoop.future(error: error)
        }
        
        let user = User(firstName: "Admin", lastName: "Admin",
                        companyName: "Administration", email: "admin@admin.com",
                        username: "admin.admin", password: passwordHash, firstConnection: true)
        
        return user.save(on: database)
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        User
            .query(on: database)
            .filter(\.$username == "admin.admin")
            .delete()
    }
}
