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
    
    @OptionalField(key: User.v20240207.isBlocked)
    var isBlocked: Bool?

    @OptionalField(key: User.v20240207.modules)
    var modules: [Module]?

    @OptionalField(key: User.v20240207.isConnectionBlocked)
    var isConnectionBlocked: Bool?

    @OptionalField(key: User.v20240207.connectionFailedAttempts)
    var connectionFailedAttempts: Int?
    
    @Enum(key: "userType")
    var userType: UserType
    
    @Siblings(through: UserTabPivot.self,
              from: \.$user,
              to: \.$technicalDocumentationTab)
    var technicalDocumentationTabs: [TechnicalDocumentationTab]
    
    @Children(for: \.$user)
    var tokens: [Token]
    
    @Children(for: \.$user)
    var resetTokens: [PasswordResetToken]
    
    @Children(for: \.$sender)
    var sentMessages: [Message]
    
    @Children(for: \.$receiver)
    var receivedMessages: [Message]
    
    init() {}
    
    init(id: UUID? = nil,
         firstName: String, lastName: String, phoneNumber: String,
         username: String, password: String, email: String, firstConnection: Bool,
         userType: UserType,
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
    
    struct Public: Content {
        // Required
        var id: UUID?
        let firstName: String
        let lastName: String
        let phoneNumber: String
        let email: String
        let username: String
        var firstConnection: Bool
        let userType: UserType
        // Optional
        var companyName: String?
        var products: String?
        var numberOfEmployees: Int?
        var numberOfUsers: Int?
        var salesAmount: Double?
        var employeesIDs: [String]?
        var managerID: String?
        var isBlocked: Bool?
        var modules: [Module]?
        var isConnectionBlocked: Bool?
        var connectionFailedAttempts: Int?
    }
    
    
    struct Input: Content {
        // Required
        let firstName: String
        let lastName: String
        let phoneNumber: String
        let email: String
        let password: String?
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
    
    struct EmailInput: Content {
        let email: String
    }
    
    struct UsernameInput: Content {
        let username: String
    }

    struct LoginTryOutput: Content {
        let id: UUID?
        let connectionFailedAttempts: Int?
        let isConnectionBlocked: Bool?
        let email: String?
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
        static let isBlocked = FieldKey(stringLiteral: "isBlocked")
        static let isConnectionBlocked = FieldKey(stringLiteral: "isConnectionBlocked")
        static let connectionFailedAttempts = FieldKey(stringLiteral: "connectionFailedAttempts")
        
        
        static let username = FieldKey(stringLiteral: "username")
        static let password = FieldKey(stringLiteral: "password")
        
        static let userTypeEnum = FieldKey(stringLiteral: "userTypeEnum")
        static let userType = "userType"
        static let admin = "admin"
        static let client = "client"
        static let employee = "employee"
    }
    
    enum UserType: String, Codable {
        case employee, admin, client
    }
}

extension User {
    func convertToPublic() -> User.Public {
        User.Public(id: id,
                    firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email,
                    username: username, firstConnection: firstConnection, userType: userType,
                    companyName: companyName, products: products, numberOfEmployees: numberOfEmployees,
                    numberOfUsers: numberOfUsers, salesAmount: salesAmount, employeesIDs: employeesIDs,
                    managerID: managerID, isBlocked: isBlocked, modules: modules, isConnectionBlocked: isConnectionBlocked, connectionFailedAttempts: connectionFailedAttempts
        )
    }

    func convertToLoginTryOutput() -> User.LoginTryOutput {
        User.LoginTryOutput(id: id,
            connectionFailedAttempts: connectionFailedAttempts,
            isConnectionBlocked: isConnectionBlocked,
            email: email
        )
    }
}

struct PasswordChangeRequest: Content {
    let currentPassword: String
    let newPassword: String
}

struct PasswordValidationRequest: Content {
    let currentPassword: String
}

struct PasswordChangeResponse: Content {
    let message: String
}

struct ResetPasswordRequest: Content {
    let token: String
    let newPassword: String
}
