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
    
    @Field(key: PotentialEmployee.v20240207.phoneNumber)
    var phoneNumber: String
    
    @Field(key: PotentialEmployee.v20240207.email)
    var email: String

    @Parent(key: PotentialEmployee.v20240207.pendingUserID)
    var pendingUser: PendingUser

    init() {}
    
    init(id: UUID? = nil, firstName: String, lastName: String,
         companyName: String, phoneNumber: String,
         email: String, pendingUserID: PendingUser.IDValue) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.companyName = companyName
        self.phoneNumber = phoneNumber
        self.email = email
        self.$pendingUser.id = pendingUserID
    }
}