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
    
    struct NumberOfEmployees: ValidatorResult {
        let isValid: Bool
        
        var isFailure: Bool {
            !isValid
        }
        
        var successDescription: String? {
            "numberOfEmployees.valid"
        }
        
        var failureDescription: String? {
            "numberOfEmployees.invalid"
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
            "numberOfUsers.invalid"
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
            "salesAmount.invalid"
        }
    }
}

extension Validator where T == String {
    static var frenchPhoneNumber: Validator<T> {
        .init { input in
            let regex = #"^(0|\+33|0033)[1-9]([-. ]?[0-9]{2}){4}$"#
            do {
                let regex = try NSRegularExpression(pattern: regex)
                let range = NSRange(input.startIndex..., in: input)
                let match = regex.firstMatch(in: input, options: [], range: range)
                
                if match != nil {
                    return ValidatorResults.FrenchPhoneNumber(isValid: true)
                } else {
                    return ValidatorResults.FrenchPhoneNumber(isValid: false)
                }
            } catch {
                // Handle regex pattern error
                print("Regex pattern is invalid: \(error.localizedDescription)")
                return ValidatorResults.FrenchPhoneNumber(isValid: false)
            }
        }
    }
    
    static var customEmail: Validator<T> {
        .init { input in
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

            do {
                let regex = try NSRegularExpression(pattern: regex)
                let range = NSRange(input.startIndex..., in: input)
                let match = regex.firstMatch(in: input, options: [], range: range)
                
                if match != nil {
                    return ValidatorResults.CustomEmail(isValid: true)
                } else {
                    return ValidatorResults.CustomEmail(isValid: false)
                }
            } catch {
                // Handle regex pattern error
                print("Regex pattern is invalid: \(error.localizedDescription)")
                return ValidatorResults.CustomEmail(isValid: false)
            }
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
