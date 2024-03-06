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
    
    @Field(key: User.v20240207.email)
    var email: String
    
    @Field(key: User.v20240207.username)
    var username: String
    
    @Field(key: User.v20240207.password)
    var password: String
    
    @Field(key: User.v20240207.firstConnection)
    var firstConnection: Bool
    
    @OptionalField(key: User.v20240207.companyName)
    var companyName: String?
    
    @OptionalField(key: User.v20240207.products)
    var products: String?
    
    @OptionalField(key: User.v20240207.numberOfEmployees)
    var numberOfEmployees: Int?
    
    @OptionalField(key: User.v20240207.numberOfUsers)
    var numberOfUsers: Int?
    
    @OptionalField(key: User.v20240207.salesAmount)
    var salesAmount: Double?
    
    @OptionalField(key: User.v20240207.employeesIDs)
    var employeesIDs: [String]?
    
    @OptionalField(key: User.v20240207.managerID)
    var managerID: String?
    
    @Enum(key: "userType")
    var userType: UserType
    
    @Siblings(through: ModuleUserPivot.self,
              from: \.$user,
              to: \.$module)
    var modules: [Module]
    
    @Siblings(through: UserTabPivot.self,
              from: \.$user,
              to: \.$technicalDocumentationTab)
    var technicalDocumentationTabs: [TechnicalDocumentationTab]
    
    init() {}
    
    init(id: UUID? = nil,
         firstName: String, lastName: String, phoneNumber: String,
         username: String, password: String, email: String, firstConnection: Bool,
         userType: UserType = .client,
         companyName: String? = nil, products: String? = nil,
         numberOfEmployees: Int? = nil, numberOfUsers: Int? = nil,
         salesAmount: Double? = nil, employeesIDs: [String]? = nil, managerID: String? = nil) {
        // Required
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.username = username
        self.password = password
        self.firstConnection = firstConnection
        self.userType = userType
        // Optional
        self.companyName = companyName
        self.products = products
        self.numberOfEmployees = numberOfEmployees
        self.numberOfUsers = numberOfUsers
        self.salesAmount = salesAmount
        self.employeesIDs = employeesIDs
        self.managerID = managerID
    }
    
    final class Public: Content {
        // Required
        var id: UUID?
        var firstName: String
        var lastName: String
        var phoneNumber: String
        var email: String
        var username: String
        var firstConnection: Bool
        var userType: UserType
        // Optional
        var companyName: String?
        var products: String?
        var numberOfEmployees: Int?
        var numberOfUsers: Int?
        var salesAmount: Double?
        var employeesIDs: [String]?
        var managerID: String?
        
        init(id: UUID?,
             firstName: String, lastName: String,
             phoneNumber: String, email: String,
             username: String, firstConnection: Bool, userType: UserType = .client,
             products: String? = nil, companyName: String? = nil,
             numberOfEmployees: Int? = nil, numberOfUsers: Int? = nil,
             salesAmount: Double? = nil, employeesIDs: [String]? = nil,
             managerID: String? = nil) {
            // Required
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.phoneNumber = phoneNumber
            self.email = email
            self.username = username
            self.firstConnection = firstConnection
            self.userType = userType
            // Optional
            self.companyName = companyName
            self.products = products
            self.numberOfEmployees = numberOfEmployees
            self.numberOfUsers = numberOfUsers
            self.salesAmount = salesAmount
            self.employeesIDs = employeesIDs
            self.managerID = managerID
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
        static let technicalDocumentationTabs = FieldKey(stringLiteral: "technicalDocumentationTabs")
        static let numberOfEmployees = FieldKey(stringLiteral: "numberOfEmployees")
        static let numberOfUsers = FieldKey(stringLiteral: "numberOfUsers")
        static let salesAmount = FieldKey(stringLiteral: "salesAmount")
        static let employeesIDs = FieldKey(stringLiteral: "employeesIDs")
        static let managerID = FieldKey(stringLiteral: "managerID")
        
        static let username = FieldKey(stringLiteral: "username")
        static let password = FieldKey(stringLiteral: "password")
        
        static let userType = "userType"
        static let admin = "admin"
        static let client = "client"
        static let employee = "employee"
    }
}

extension User {
    func convertToPublic() -> User.Public {
        User.Public(id: id,
                    firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email,
                    username: username, firstConnection: firstConnection, userType: userType,
                    products: products, companyName: companyName, numberOfEmployees: numberOfEmployees,
                    numberOfUsers: numberOfUsers, salesAmount: salesAmount, employeesIDs: employeesIDs,
                    managerID: managerID
        )
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
    // Required
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let password: String
    let userType: UserType
    // Optional
    let companyName: String?
    let products: String?
    let numberOfEmployees: Int?
    let numberOfUsers: Int?
    let salesAmount: Double?
    let employeesIDs: [String]?
    let managerID: String?
}
