//
//  String.swift
//
//
//  Created by Raphaël Payet on 09/09/2024.
//

import Foundation

extension String {
    func removeAccents() -> String {
        let decomposed = self.decomposedStringWithCanonicalMapping
        return decomposed.components(separatedBy: CharacterSet.nonBaseCharacters).joined()
    }
    
    func removeWhitespaces(with string: String = "") -> String {
        self.replacingOccurrences(of: " ", with: string)
    }
}
