//
//  File.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Foundation

extension QuestionnaireRecipient {
    enum Status: String, Codable {
        case sent, viewed, submitted, exported
    }
}
