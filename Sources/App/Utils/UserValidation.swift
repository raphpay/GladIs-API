//
//  File.swift
//  
//
//  Created by Raphaël Payet on 04/03/2024.
//

import Vapor

extension ValidatorResults {
    struct FrenchPhoneNumber: ValidatorResult {
        let isValid: Bool
        
        var isFailure: Bool {
            !isValid
        }
        
        var successDescription: String? {
            "phoneNumber.valid"
        }
        
        var failureDescription: String? {
            "phoneNumber.invalid"
        }
    }
    
    struct CustomEmail: ValidatorResult {
        let isValid: Bool
        
        var isFailure: Bool {
            !isValid
        }
        
        var successDescription: String? {
            "email.valid"
        }
        
        var failureDescription: String? {
            "email.invalid"
        }
    }
}

extension Validator where T == String {
    static var frenchPhoneNumber: Validator<T> {
        .init { input in
            let regex = #"^(0|\+33|0033)[1-9]([-. ]?[0-9]{2}){4}$"#
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            guard predicate.evaluate(with: input) else {
                return ValidatorResults.FrenchPhoneNumber(isValid: false)
            }
            return ValidatorResults.FrenchPhoneNumber(isValid: true)
        }
    }
    
    static var customEmail: Validator<T> {
        .init { input in
            let regex = #"^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$"#
            let isValid = NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: input)
            guard isValid else {
                return ValidatorResults.CustomEmail(isValid: false)
            }
            return ValidatorResults.CustomEmail(isValid: true)
        }
    }
}

extension UserCreateData: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .customEmail)
        validations.add("phoneNumber", as: String.self, is: .frenchPhoneNumber)
    }
}

extension PendingUser: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .customEmail)
        validations.add("phoneNumber", as: String.self, is: .frenchPhoneNumber)
        // TODO: Add employee, sales number and potential users
    }
}
