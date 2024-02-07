//
//  File.swift
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
    
    @Field(key: User.v20240207.identifier)
    var identifier: String
    
    @Field(key: User.v20240207.password)
    var password: String
    
    @Enum(key: "userType")
    var userType: UserType
    
    init() {}
    
    init(id: UUID? = nil,
         firstName: String, lastName: String,
         email: String, identifier: String,
         password: String, userType: UserType = .client) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.identifier = identifier
        self.password = password
        self.userType = userType
    }
    
    final class Public: Content {
        var id: UUID?
        var firstName: String
        var lastName: String
        var email: String
        var identifier: String
        var userType: UserType
        
        init(id: UUID?,
             firstName: String, lastName: String,
             email: String, identifier: String, userType: UserType = .client) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.identifier = identifier
            self.userType = userType
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        User.Public(id: id,
                    firstName: firstName, lastName: lastName,
                    email: email, identifier: identifier,
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
    static let usernameKey = \User.$identifier
    static let passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
