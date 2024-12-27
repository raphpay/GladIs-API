//
//  Folder+Sleeve.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

import Foundation

extension Folder {
    enum Sleeve: String, Codable {
        case systemQuality, record
    }
    
    enum Category: String, Codable {
        case qualityManual, process, custom
    }
}
