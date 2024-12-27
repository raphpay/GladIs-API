//
//  VersionLogDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

import Fluent
import Vapor

// MARK: - Input
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

// MARK: - Update Input
extension VersionLog {
    struct UpdateInput: Content {
        let currentVersion: String?
        let minimumClientVersion: String?
        
        func update(_ versionLog: VersionLog) -> VersionLog {
            let updatedVersionLog = versionLog
            
            if let currentVersion = currentVersion {
                updatedVersionLog.currentVersion = currentVersion
            }
            
            if let minimumClientVersion = minimumClientVersion {
                updatedVersionLog.minimumClientVersion = minimumClientVersion
            }
            
            return updatedVersionLog
        }
    }
    
    struct UpdateSupportedClientVersions: Content {
        let supportedClientVersions: [String]
    }
}
