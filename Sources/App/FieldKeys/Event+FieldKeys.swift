//
//  Event+FieldKeys.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 10/09/2025.
//

import Fluent

extension Event {
	enum v20240207 {
		static let schemaName = "events"
		static let id = FieldKey(stringLiteral: "id")
		static let name = FieldKey(stringLiteral: "name")
		static let deletedAt = FieldKey(stringLiteral: "deleted_at")
		static let clientID = FieldKey(stringLiteral: "clientID")
		static let date = FieldKey(stringLiteral: "date")
	}

	enum v20250910 {
		static let startTime = FieldKey(stringLiteral: "startTime")
		static let endTime = FieldKey(stringLiteral: "endTime")
	}
}
