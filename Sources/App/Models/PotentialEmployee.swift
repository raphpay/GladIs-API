//
//  PotentialEmployee.swift
//
//
//  Created by Raphaël Payet on 06/03/2024.
//

import Vapor
import Fluent

final class PotentialEmployee: Model, Content {
    static let schema = PotentialEmployee.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: PotentialEmployee.v20240207.firstName)
    var firstName: String
    
    @Field(key: PotentialEmployee.v20240207.lastName)
    var lastName: String
    
    @Field(key: PotentialEmployee.v20240207.companyName)
    var companyName: String

    @Parent(key: PotentialEmployee.v20240207.pendingUserID)
    var pendingUser: PendingUser

    init() {}
    
    init(id: UUID? = nil, firstName: String, lastName: String,
         companyName: String, pendingUserID: PendingUser.IDValue) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.companyName = companyName
        self.$pendingUser.id = pendingUserID
    }
    
    final class Input: Content {
        var id: UUID?
        var firstName: String
        var lastName: String
        var companyName: String
        var pendingUserID: PendingUser.IDValue
        
        init(id: UUID? = nil, firstName: String, lastName: String, companyName: String, pendingUserID: PendingUser.IDValue) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.companyName = companyName
            self.pendingUserID = pendingUserID
        }
    }
}

extension PotentialEmployee {
    enum v20240207 {
        static let schemaName = "potentialEmployees"
        static let id = FieldKey(stringLiteral: "id")
        static let firstName = FieldKey(stringLiteral: "firstName")
        static let lastName = FieldKey(stringLiteral: "lastName")
        static let companyName = FieldKey(stringLiteral: "companyName")
        static let pendingUserID = FieldKey(stringLiteral: "pendingUserID")
    }
}
