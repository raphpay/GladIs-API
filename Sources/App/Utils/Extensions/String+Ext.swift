//
//  String.swift
//
//
//  Created by Raphaël Payet on 09/09/2024.
//

import Vapor

extension String {
    func removeAccents() -> String {
        let decomposed = self.decomposedStringWithCanonicalMapping
        return decomposed.components(separatedBy: CharacterSet.nonBaseCharacters).joined()
    }
    
    func removeWhitespaces(with string: String = "") -> String {
        self.replacingOccurrences(of: " ", with: string)
    }
    
    func validateEmail() throws {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let isValid = NSPredicate { input, _ in
            guard let input = input as? String else {
                return false
            }
            
            return input.range(of: regex, options: .regularExpression) != nil
        }.evaluate(with: self)
        
        guard isValid else {
            throw Abort(.badRequest, reason: "badRequest.email.invalid")
        }
    }
    
    func validatePhoneNumber() throws {
        let regex = #"^(0|\+33|0033)[1-9]([-. ]?[0-9]{2}){4}$"#
        let isValid = NSPredicate { input, _ in
            guard let input = input as? String else {
                return false
            }
            return input.range(of: regex, options: .regularExpression) != nil
        }.evaluate(with: self)
        
        guard isValid else {
            throw Abort(.badRequest, reason: "badRequest.phoneNumber.invalid")
        }
    }
    
    func isValidEmail() -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let isValid = NSPredicate { input, _ in
            guard let input = input as? String else {
                return false
            }
            
            return input.range(of: regex, options: .regularExpression) != nil
        }.evaluate(with: self)
        
        return isValid
    }
}
