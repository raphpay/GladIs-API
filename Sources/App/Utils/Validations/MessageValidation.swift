//
//  MessageValidation.swift
//  
//
//  Created by Raphaël Payet on 29/03/2024.
//

import Vapor

extension ValidatorResults {
    struct CustomTitleLength: ValidatorResult {
        let isValid: Bool
        
        var isFailure: Bool {
            !isValid
        }
        
        var successDescription: String? {
            "title.valid"
        }
        
        var failureDescription: String? {
            "badRequest.title.invalid"
        }
    }
    
    struct CustomContentLength: ValidatorResult {
        let isValid: Bool
        
        var isFailure: Bool {
            !isValid
        }
        
        var successDescription: String? {
            "content.valid"
        }
        
        var failureDescription: String? {
            "badRequest.content.invalid"
        }
    }
}

extension Validator where T == String {
    static var customTitleLength: Validator<T> {
        .init { input in
            guard input.count <= 60 else {
                return ValidatorResults.CustomTitleLength(isValid: false)
            }
            
            return ValidatorResults.CustomTitleLength(isValid: true)
        }
    }
    
    static var customContentLength: Validator<T> {
        .init { input in
            guard input.count <= 60 else {
                return ValidatorResults.CustomTitleLength(isValid: false)
            }
            
            return ValidatorResults.CustomTitleLength(isValid: true)
        }
    }
}

extension Message.Input: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: .customTitleLength)
        validations.add("content", as: String.self, is: .customContentLength)
    }
}

