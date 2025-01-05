//
//  DocumentActivityLogDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 05/01/2025.
//

import Fluent
import Vapor

extension DocumentActivityLog {
    struct Input: Content {
        var id: UUID?
        let action: DocumentActivityLog.ActionEnum
        let actorIsAdmin: Bool
        let actorID: UUID
        let documentID: Document.IDValue?
        let formID: Form.IDValue?
        let clientID: User.IDValue
    }

    struct PaginatedOutput: Content {
        let logs: [DocumentActivityLog]
        let pageCount: Int
    }
}
