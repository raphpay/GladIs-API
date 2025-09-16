//
//  Event.swift
//
//
//  Created by Raphaël Payet on 26/03/2024.
//

import Vapor
import Fluent

final class Event: Model, Content {
    static let schema = Event.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: Event.v20240207.name)
    var name: String
    
    @Field(key: Event.v20240207.date)
    var date: Double

	@OptionalField(key: Event.v20250910.startTime)
	var startTime: String?  // HH:mm format (or ISO8601 string if you prefer)

	@OptionalField(key: Event.v20250910.endTime)
	var endTime: String?

    @Timestamp(key: Event.v20240207.deletedAt, on: .delete)
    var deletedAt: Date?

    @Parent(key: Event.v20240207.clientID)
    var client: User

    init() {}

    init(id: UUID? = nil,
		 name: String,
		 date: Double,
		 clientID: User.IDValue,
		 startTime: String? = nil,
		 endTime: String? = nil
	) {
        self.id = id
        self.name = name
        self.date = date
        self.$client.id = clientID
		self.startTime = startTime
		self.endTime = endTime
    }
}
