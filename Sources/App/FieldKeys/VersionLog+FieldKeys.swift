//
//  VersionLog+FieldKeys.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

import Fluent

extension VersionLog {
    enum v20241227 {
        static let schemaName = "versionInfo"
        static let currentVersion = FieldKey(stringLiteral: "currentVersion")
        static let supportedClientVersions = FieldKey(stringLiteral: "supportedClientVersions")
        static let minimumClientVersion = FieldKey(stringLiteral: "minimumClientVersion")
    }
}
