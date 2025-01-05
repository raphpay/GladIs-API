//
//  VersionLog.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

import Fluent
import Vapor

final class VersionLog: Model, Content {
    static let schema: String = VersionLog.v20241227.schemaName
    
    @ID
    var id: UUID?
    
    @Field(key: VersionLog.v20241227.currentVersion)
    var currentVersion: String
    
    @Field(key: VersionLog.v20241227.minimumClientVersion)
    var minimumClientVersion: String
    
    init() {}
    
    init(id: UUID? = nil,
         currentVersion: String,
         minimumClientVersion: String) {
        self.id = id
        self.currentVersion = currentVersion
        self.minimumClientVersion = minimumClientVersion
    }
}
