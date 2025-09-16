//
//  EventDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 10/09/2025.
//

import Fluent
import Vapor

// MARK: - Get
extension Event {
	struct Input: Content {
		var id: UUID?
		let name: String
		let date: Double
		let clientID: User.IDValue
		let startTime: String?
		let endTime: String?
	}
}
