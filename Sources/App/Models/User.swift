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
    
    @Field(key: User.v20240207.phoneNumber)
    var phoneNumber: String
    
    @Field(key: User.v20240207.companyName)
    var companyName: String
    
    @Field(key: User.v20240207.email)
    var email: String
    
    @OptionalField(key: User.v20240207.products)
    var products: String?
    
    @OptionalField(key: User.v20240207.numberOfEmployees)
    var numberOfEmployees: Int?
    
    @OptionalField(key: User.v20240207.numberOfUsers)
    var numberOfUsers: Int?
    
    @OptionalField(key: User.v20240207.salesAmount)
    var salesAmount: Double?
    
    @Field(key: User.v20240207.username)
    var username: String
    
    @Field(key: User.v20240207.password)
    var password: String
    
    @Field(key: User.v20240207.firstConnection)
    var firstConnection: Bool
    
    @Enum(key: "userType")
    var userType: UserType
    
    @Siblings(through: ModuleUserPivot.self,
              from: \.$user,
              to: \.$module)
    var modules: [Module]
    
    init() {}
    
    init(id: UUID? = nil,
         firstName: String, lastName: String, phoneNumber: String,
         companyName: String, email: String, products: String? = nil,
         numberOfEmployees: Int? = nil, numberOfUsers: Int? = nil, salesAmount: Double? = nil,
         username: String, password: String,
         firstConnection: Bool, userType: UserType = .client
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.companyName = companyName
        self.email = email
        self.products = products
        self.numberOfEmployees = numberOfEmployees
        self.numberOfUsers = numberOfUsers
        self.salesAmount = salesAmount
        self.username = username
        self.password = password
        self.firstConnection = firstConnection
        self.userType = userType
    }
    
    final class Public: Content {
        var id: UUID?
        var firstName: String
        var lastName: String
        var phoneNumber: String
        var companyName: String
        var email: String
        var products: String?
        var numberOfEmployees: Int?
        var numberOfUsers: Int?
        var salesAmount: Double?
        var username: String
        var firstConnection: Bool
        var userType: UserType
        
        init(id: UUID?,
             firstName: String, lastName: String,
             phoneNumber: String, companyName: String,
             email: String, products: String? = nil,
             numberOfEmployees: Int? = nil, numberOfUsers: Int? = nil,
             salesAmount: Double? = nil,
             username: String, firstConnection: Bool,
             userType: UserType = .client) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.phoneNumber = phoneNumber
            self.companyName = companyName
            self.email = email
            self.products = products
            self.numberOfEmployees = numberOfEmployees
            self.numberOfUsers = numberOfUsers
            self.salesAmount = salesAmount
            self.username = username
            self.firstConnection = firstConnection
            self.userType = userType
        }
    }
}


extension User {
    enum v20240207 {
        static let schemaName = "users"
        static let id = FieldKey(stringLiteral: "id")
        static let firstName = FieldKey(stringLiteral: "firstName")
        static let lastName = FieldKey(stringLiteral: "lastName")
        static let phoneNumber = FieldKey(stringLiteral: "phoneNumber")
        static let companyName = FieldKey(stringLiteral: "companyName")
        static let email = FieldKey(stringLiteral: "email")
        static let firstConnection = FieldKey(stringLiteral: "firstConnection")
        static let products = FieldKey(stringLiteral: "products")
        static let modules = FieldKey(stringLiteral: "modules")
        static let numberOfEmployees = FieldKey(stringLiteral: "numberOfEmployees")
        static let numberOfUsers = FieldKey(stringLiteral: "numberOfUsers")
        static let salesAmount = FieldKey(stringLiteral: "salesAmount")
        
        static let username = FieldKey(stringLiteral: "username")
        static let password = FieldKey(stringLiteral: "password")
        
        static let userType = "userType"
        static let admin = "admin"
        static let standard = "standard"
        static let restricted = "restricted"
    }
}

extension User {
    func convertToPublic() -> User.Public {
        User.Public(id: id,
                    firstName: firstName, lastName: lastName,
                    phoneNumber: phoneNumber, companyName: companyName,
                    email: email, products: products,
                    numberOfEmployees: numberOfEmployees, numberOfUsers: numberOfUsers,
                    salesAmount: salesAmount, username: username,
                    firstConnection: firstConnection, userType: userType)
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

struct PasswordChangeRequest: Content {
    let currentPassword: String
    let newPassword: String
}

struct PasswordChangeResponse: Content {
    let message: String
}

struct UserCreateData: Content {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let companyName: String
    let email: String
    let products: String?
    let numberOfEmployees: Int?
    let numberOfUsers: Int?
    let salesAmount: Double?
    let password: String
    let userType: UserType
}
