//
//  PotentialEmployee+FieldKeys.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 19/02/2025.
//

import Fluent

extension PotentialEmployee {
    enum v20240207 {
        static let schemaName = "potentialEmployees"
        static let id = FieldKey(stringLiteral: "id")
        static let firstName = FieldKey(stringLiteral: "firstName")
        static let lastName = FieldKey(stringLiteral: "lastName")
        static let companyName = FieldKey(stringLiteral: "companyName")
        static let phoneNumber = FieldKey(stringLiteral: "phoneNumber")
        static let email = FieldKey(stringLiteral: "email")
        static let pendingUserID = FieldKey(stringLiteral: "pendingUserID")
    }
}
