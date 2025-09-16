
//
//  AddStartTimeAndEndTimeToEvent.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 10/09/2025.
//

import Fluent
import Vapor

struct AddStartTimeAndEndTimeToEvent: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await database.schema(Folder.v20240806.schemaName)
			.field(Event.v20250910.startTime, .string)
			.field(Event.v20250910.endTime, .string)
			.update()
	}

	func revert(on database: Database) async throws {
		// Revert the changes by removing the 'category' field.
		try await database.schema(Folder.v20240806.schemaName)
			.deleteField(Event.v20250910.startTime)
			.deleteField(Event.v20250910.endTime)
			.update()
	}
}
