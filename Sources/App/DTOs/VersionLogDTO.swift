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
        
        func update(_ versionLog: VersionLog) throws -> VersionLog {
            let updatedVersionLog = versionLog
            
            if let currentVersion = currentVersion {
                if isVersionRegressed(current: versionLog.currentVersion, new: currentVersion) {
                    throw Abort(.badRequest, reason: "badRequest.currentVersionRegression")
                } else {
                    updatedVersionLog.currentVersion = currentVersion
                }
            }
            
            if let minimumClientVersion = minimumClientVersion {
                if isVersionRegressed(current: versionLog.minimumClientVersion, new: minimumClientVersion) {
                    throw Abort(.badRequest, reason: "badRequest.minimumClientVersionRegression")
                } else {
                    updatedVersionLog.minimumClientVersion = minimumClientVersion
                }
            }
            
            return updatedVersionLog
        }
        
        private func isVersionRegressed(current: String, new: String) -> Bool {
            let currentComponents = current.split(separator: ".").compactMap { Int($0) }
            let newComponents = new.split(separator: ".").compactMap { Int($0) }
            
            // Compare each version component: major, minor, patch
            for (currentPart, newPart) in zip(currentComponents, newComponents) {
                if newPart > currentPart {
                    return false // No regression
                } else if newPart < currentPart {
                    return true // Regression
                }
            }
            
            // If all parts are equal but `new` has fewer components, it’s considered a regression
            return newComponents.count < currentComponents.count
        }
    }
    
    struct UpdateSupportedClientVersions: Content {
        let supportedClientVersions: [String]
    }
}
