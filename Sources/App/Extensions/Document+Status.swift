//
//  Document+Status.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 26/12/2024.
//

import Foundation

extension Document {
    enum Status: String, Codable {
        case draft, pendingReview, underReview, approved, rejected, archived
        case none
    }
}
