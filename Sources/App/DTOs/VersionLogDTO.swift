//
//  VersionLogDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

import Fluent
import Vapor

extension VersionLog {
    struct Input: Content {
        let currentVersion: String
        let supportedClientVersions: [String]
        let minimumClientVersion: String
        
        func toModel() -> VersionLog {
            .init(currentVersion: currentVersion,
                  supportedClientVersions: supportedClientVersions,
                  minimumClientVersion: minimumClientVersion)
        }
    }
}
