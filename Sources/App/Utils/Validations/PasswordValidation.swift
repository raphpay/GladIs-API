//
//  PasswordValidation.swift
//
//
//  Created by Raphaël Payet on 14/02/2024.
//

import Vapor

struct PasswordValidation {
    func validatePassword(_ password: String) throws {
        // Check the password length
        guard password.count >= 12 else {
            throw Abort(.unauthorized, reason: "unauthorized.password.invalidLength")
        }
        
        // Check an uppercase presence
        let uppercaseRegex = ".*[A-Z]+.*"
//        guard NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: password) else {
//            throw Abort(.unauthorized, reason: "unauthorized.password.missingUppercase")
//        }
        
        let uppercasePredicate = NSPredicate { input, _ in
            guard let input = input as? String else {
                return false
            }
            return input.range(of: uppercaseRegex, options: .regularExpression) != nil
        }

        guard uppercasePredicate.evaluate(with: password) else {
            throw Abort(.unauthorized, reason: "unauthorized.password.missingUppercase")
        }
        
        // Check a digit presence
        let digitRegex = ".*[0-9]+.*"
//        guard NSPredicate(format: "SELF MATCHES %@", digitRegex).evaluate(with: password) else {
//            throw Abort(.unauthorized, reason: "unauthorized.password.missingDigit")
//        }
        let digitPredicate = NSPredicate { input, _ in
            guard let input = input as? String else {
                return false
            }
            return input.range(of: digitRegex, options: .regularExpression) != nil
        }

        guard digitPredicate.evaluate(with: password) else {
            throw Abort(.unauthorized, reason: "unauthorized.password.missingDigit")
        }
        
        // Check a special character presence
        let specialCharRegex = ".*[!@#$%^&*()]+.*"
//        guard NSPredicate(format: "SELF MATCHES %@", specialCharRegex).evaluate(with: password) else {
//            throw Abort(.unauthorized, reason: "unauthorized.password.missingSpecialCharacter")
//        }
        let specialCharPredicate = NSPredicate { input, _ in
            guard let input = input as? String else {
                return false
            }
            return input.range(of: specialCharRegex, options: .regularExpression) != nil
        }

        guard specialCharPredicate.evaluate(with: password) else {
            throw Abort(.unauthorized, reason: "unauthorized.password.missingSpecialCharacter")
        }
    }

    enum ValidationError: Error {
        case invalidLength(String)
        case missingUppercase(String)
        case missingDigit(String)
        case missingSpecialCharacter(String)
    }
}
