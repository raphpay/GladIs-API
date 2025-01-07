//
//  EmailDTO.swift
//  
//
//  Created by Raphaël Payet on 27/08/2024.
//

import Fluent
import Vapor
import SendGridKit

extension Email {
    struct Input: Content {
        let to: [String]
        let fromMail: String
        let fromName: String
        let replyTo: String?
        let subject: String
        let content: String
        var isHTML: Bool = false
    }
}
