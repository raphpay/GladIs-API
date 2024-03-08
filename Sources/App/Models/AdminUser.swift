//
//  AdminUser.swift
//
//
//  Created by Raphaël Payet on 07/03/2024.
//

import Fluent
import Vapor

final class AdminUser: Model, Content {
    static let schema: String = AdminUser.v20240207.schemaName
    
    @ID
    var id: UUID?
    
    @Field(key: AdminUser.v20240207.firstName)
    var firstName: String
    
    @Field(key: AdminUser.v20240207.lastName)
    var lastName: String
    
    @Field(key: AdminUser.v20240207.phoneNumber)
    var phoneNumber: String
    
    @Field(key: AdminUser.v20240207.email)
    var email: String
    
    @Field(key: AdminUser.v20240207.username)
    var username: String
    
    @Field(key: AdminUser.v20240207.password)
    var password: String
    
    @Field(key: AdminUser.v20240207.firstConnection)
    var firstConnection: Bool
    
    init() {}
    
    init(id: UUID? = nil, firstName: String, lastName: String, phoneNumber: String,
         username: String, password: String, email: String, firstConnection: Bool) {
        // Required
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.username = username
        self.password = password
        self.firstConnection = firstConnection
    }
    
    struct Public: Content {
        var id: UUID?
        let firstName: String
        let lastName: String
        let phoneNumber: String
        let email: String
        let username: String
        let firstConnection: Bool
    }
    
    struct Input: Content {
        let firstName: String
        let lastName: String
        let phoneNumber: String
        let email: String
        let password: String
    }

}


extension AdminUser {
    enum v20240207 {
        static let schemaName = "adminUsers"
        static let id = FieldKey(stringLiteral: "id")
        static let firstName = FieldKey(stringLiteral: "firstName")
        static let lastName = FieldKey(stringLiteral: "lastName")
        static let phoneNumber = FieldKey(stringLiteral: "phoneNumber")
        static let email = FieldKey(stringLiteral: "email")
        static let firstConnection = FieldKey(stringLiteral: "firstConnection")
        
        static let username = FieldKey(stringLiteral: "username")
        static let password = FieldKey(stringLiteral: "password")
    }
}

extension AdminUser {
    func convertToPublic() -> AdminUser.Public {
        AdminUser.Public(id: id,
                    firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email,
                    username: username, firstConnection: firstConnection)
    }
}

extension EventLoopFuture where Value: AdminUser {
    func convertToPublic() -> EventLoopFuture<AdminUser.Public> {
        return self.map { user in
            return user.convertToPublic()
        }
    }
}


extension Collection where Element: AdminUser {
    func convertToPublic() -> [AdminUser.Public] {
        return self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<AdminUser> {
    func convertToPublic() -> EventLoopFuture<[AdminUser.Public]> {
        return self.map { $0.convertToPublic() }
    }
}

extension AdminUser: ModelAuthenticatable {
    static let usernameKey = \AdminUser.$username
    static let passwordHashKey = \AdminUser.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
