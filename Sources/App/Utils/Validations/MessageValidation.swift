//
//  MessageValidation.swift
//  
//
//  Created by Raphaël Payet on 29/03/2024.
//

import Vapor

extension Message.Input: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("content", as: String.self, is: .count(...300))
    }
}

