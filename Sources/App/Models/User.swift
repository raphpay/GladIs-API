//
//  User.swift
//  
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema: String = User.v20240207.schemaName
    
    @ID
    var id: UUID?
    
    @Field(key: User.v20240207.firstName)
    var firstName: String
    
    @Field(key: User.v20240207.lastName)
    var lastName: String
    
    @Field(key: User.v20240207.email)
    var email: String
    
    @Field(key: User.v20240207.username)
    var username: String
    
    @Field(key: User.v20240207.password)
    var password: String
    
    @OptionalField(key: User.v20240207.phoneNumber)
    var phoneNumber: String?
    
    @Enum(key: "userType")
    var userType: UserType
    
    init() {}
    
    init(id: UUID? = nil,
         firstName: String, lastName: String,
         email: String, username: String,
         password: String, userType: UserType = .client,
         phoneNumber: String = ""
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.username = username
        self.password = password
        self.userType = userType
        self.phoneNumber = phoneNumber
    }
    
    final class Public: Content {
        var id: UUID?
        var firstName: String
        var lastName: String
        var email: String
        var username: String
        var userType: UserType
        
        init(id: UUID?,
             firstName: String, lastName: String,
             email: String, username: String, userType: UserType = .client) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.username = username
            self.userType = userType
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        User.Public(id: id,
                    firstName: firstName, lastName: lastName,
                    email: email, username: username,
                    userType: userType)
    }
}

extension EventLoopFuture where Value: User {
    func convertToPublic() -> EventLoopFuture<User.Public> {
        return self.map { user in
            return user.convertToPublic()
        }
    }
}


extension Collection where Element: User {
    func convertToPublic() -> [User.Public] {
        return self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<User> {
    func convertToPublic() -> EventLoopFuture<[User.Public]> {
        return self.map { $0.convertToPublic() }
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
