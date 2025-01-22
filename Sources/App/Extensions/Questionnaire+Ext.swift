//
//  Questionnair+Ext.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Foundation


extension Questionnaire {
    struct QField: Codable {
        var key: String
        var value: String
        var index: Int
    }
}
