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
            throw Abort(.unauthorized, reason: "password.invalidLength")
        }
        
        // Check an uppercase presence
        let uppercaseRegex = ".*[A-Z]+.*"
    
        do {
            let regex = try NSRegularExpression(pattern: uppercaseRegex)
            let range = NSRange(location: 0, length: password.utf16.count)
            if regex.firstMatch(in: password, options: [], range: range) == nil {
                throw Abort(.unauthorized, reason: "password.missingUppercase")
            }
        } catch {
            throw Abort(.unauthorized, reason: "password.missingUppercase")
        }
        
        // Check a digit presence
        let digitRegex = ".*[0-9]+.*"
        do {
            let regex = try NSRegularExpression(pattern: digitRegex)
            let range = NSRange(location: 0, length: password.utf16.count)
            if regex.firstMatch(in: password, options: [], range: range) == nil {
                throw Abort(.unauthorized, reason: "password.missingDigit")
            }
        } catch {
            throw Abort(.unauthorized, reason: "password.missingDigit")
        }
        
        // Check a special character presence
        let specialCharRegex = ".*[!@#$%^&*()]+.*"
        do {
            let regex = try NSRegularExpression(pattern: specialCharRegex)
            let range = NSRange(location: 0, length: password.utf16.count)
            if regex.firstMatch(in: password, options: [], range: range) == nil {
                throw Abort(.unauthorized, reason: "password.missingSpecialCharacter")
            }
        } catch {
            throw Abort(.unauthorized, reason: "password.missingSpecialCharacter")
        }
    }

    enum ValidationError: Error {
        case invalidLength(String)
        case missingUppercase(String)
        case missingDigit(String)
        case missingSpecialCharacter(String)
    }
}
