//
//  UserValidation.swift
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
            "badRequest.phoneNumber.invalid"
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
            "badRequest.email.invalid"
        }
    }
    
    struct NumberOfEmployees: ValidatorResult {
        let isValid: Bool
        
        var isFailure: Bool {
            !isValid
        }
        
        var successDescription: String? {
            "numberOfEmployees.valid"
        }
        
        var failureDescription: String? {
            "badRequest.numberOfEmployees.invalid"
        }
    }
    
    struct NumberOfUsers: ValidatorResult {
        let isValid: Bool
        
        var isFailure: Bool {
            !isValid
        }
        
        var successDescription: String? {
            "numberOfUsers.valid"
        }
        
        var failureDescription: String? {
            "badRequest.numberOfUsers.invalid"
        }
    }
    
    struct SalesAmount: ValidatorResult {
        let isValid: Bool
        
        var isFailure: Bool {
            !isValid
        }
        
        var successDescription: String? {
            "salesAmount.valid"
        }
        
        var failureDescription: String? {
            "badRequest.salesAmount.invalid"
        }
    }
}

extension Validator where T == String {
    static var frenchPhoneNumber: Validator<T> {
        .init { input in
            let regex = #"^(0|\+33|0033)[1-9]([-. ]?[0-9]{2}){4}$"#
//            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
//            guard predicate.evaluate(with: input) else {
//                return ValidatorResults.FrenchPhoneNumber(isValid: false)
//            }
            let regexPredicate = NSPredicate { input, _ in
                guard let input = input as? String else {
                    return false
                }
                return input.range(of: regex, options: .regularExpression) != nil
            }

            guard regexPredicate.evaluate(with: input) else {
                return ValidatorResults.FrenchPhoneNumber(isValid: false)
            }
            return ValidatorResults.FrenchPhoneNumber(isValid: true)
        }
    }
    
    static var customEmail: Validator<T> {
        .init { input in
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//            let isValid = NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: input)
            let isValid = NSPredicate { input, _ in
                guard let input = input as? String else {
                    return false
                }
                
                return input.range(of: regex, options: .regularExpression) != nil
            }.evaluate(with: input)

            guard isValid else {
                return ValidatorResults.CustomEmail(isValid: false)
            }
            return ValidatorResults.CustomEmail(isValid: true)
        }
    }
}

extension Validator where T == Int {
    static var numberOfEmployees: Validator<T> {
        .init { input in
            guard input > 0 else {
                return ValidatorResults.NumberOfEmployees(isValid: false)
            }
            return ValidatorResults.NumberOfEmployees(isValid: true)
        }
    }
    
    static var numberOfUsers: Validator<T> {
        .init { input in
            guard input > 0 else {
                return ValidatorResults.NumberOfUsers(isValid: false)
            }
            return ValidatorResults.NumberOfUsers(isValid: true)
        }
    }
    
    static var salesAmount: Validator<T> {
        .init { input in
            guard input >= 0 else {
                return ValidatorResults.SalesAmount(isValid: false)
            }
            return ValidatorResults.SalesAmount(isValid: true)
        }
    }
}

extension User.Input: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .customEmail)
        validations.add("phoneNumber", as: String.self, is: .frenchPhoneNumber)
    }
}

extension User.EmailInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .customEmail)
    }
}

extension PendingUser.Input: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .customEmail)
        validations.add("phoneNumber", as: String.self, is: .frenchPhoneNumber)
        validations.add("numberOfEmployees", as: Int.self, is: .numberOfEmployees)
        validations.add("numberOfUsers", as: Int.self, is: .numberOfUsers)
        validations.add("salesAmount", as: Int.self, is: .salesAmount)
    }
}


extension PotentialEmployee.Input: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .customEmail)
        validations.add("phoneNumber", as: String.self, is: .frenchPhoneNumber)
    }
}
