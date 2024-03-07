//
//  Employee.swift
//
//
//  Created by Raphaël Payet on 07/03/2024.
//

import Vapor
import Fluent

final class Employee: Model, Content {
    static let schema = Employee.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: Employee.v20240207.firstName)
    var firstName: String
    
    @Field(key: Employee.v20240207.lastName)
    var lastName: String
    
    @Field(key: Employee.v20240207.username)
    var username: String
    
    @Field(key: Employee.v20240207.password)
    var password: String

    @Parent(key: Employee.v20240207.userID)
    var user: User

    init() {}

    init(id: UUID? = nil, firstName: String, lastName: String,
         username: String, password: String, userID: User.IDValue) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.password = password
        self.$user.id = userID
    }
    
    struct Input: Content {
        let firstName: String
        let lastName: String
        let password: String
        let userID: User.IDValue
    }
    
    struct Public: Content {
        let id: Employee.IDValue?
        let firstName: String
        let lastName: String
        let username: String
        let user: UserID
    }
    
    struct UserID: Content {
        let id: User.IDValue
    }
}

extension Employee {
    enum v20240207 {
        static let schemaName = "employees"
        static let id = FieldKey(stringLiteral: "id")
        static let firstName = FieldKey(stringLiteral: "firstName")
        static let lastName = FieldKey(stringLiteral: "lastName")
        static let username = FieldKey(stringLiteral: "username")
        static let password = FieldKey(stringLiteral: "password")
        static let userID = FieldKey(stringLiteral: "userID")
    }
}

extension Employee {
    func convertToPublic() -> Employee.Public {
        Employee.Public(id: id, firstName: firstName, lastName: lastName, username: username, user: UserID(id: $user.id))
    }
}

extension EventLoopFuture where Value: Employee {
    func convertToPublic() -> EventLoopFuture<Employee.Public> {
        return self.map { user in
            return user.convertToPublic()
        }
    }
}


extension Collection where Element: Employee {
    func convertToPublic() -> [Employee.Public] {
        return self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<Employee> {
    func convertToPublic() -> EventLoopFuture<[Employee.Public]> {
        return self.map { $0.convertToPublic() }
    }
}
