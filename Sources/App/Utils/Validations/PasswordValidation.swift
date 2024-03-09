//
//  PasswordValidation.swift
//
//
//  Created by Raphaël Payet on 14/02/2024.
//

import Foundation

struct PasswordValidation {
    func validatePassword(_ password: String) throws {
        // Check the password length
        guard password.count >= 12 else {
            throw ValidationError.invalidLength("The password should contain at least 12 characters")
        }
        
        // Check an uppercase presence
        let uppercaseRegex = ".*[A-Z]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: password) else {
            throw ValidationError.missingUppercase("The password should contain at least one uppercased letter")
        }
        
        // Check a digit presence
        let digitRegex = ".*[0-9]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", digitRegex).evaluate(with: password) else {
            throw ValidationError.missingDigit("The password should contain at least one digit")
        }
        
        // Check a special character presence
        let specialCharRegex = ".*[!@#$%^&*()]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", specialCharRegex).evaluate(with: password) else {
            throw ValidationError.missingSpecialCharacter("The password should contain at least one character within !@#$%^&*.()")
        }
    }

    enum ValidationError: Error {
        case invalidLength(String)
        case missingUppercase(String)
        case missingDigit(String)
        case missingSpecialCharacter(String)
    }
}
