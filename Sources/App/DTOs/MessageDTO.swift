//
//  MessageDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 16/09/2025.
//

import Fluent
import Vapor

extension Message {
	struct Input: Content {
	 let title: String
	 let content: String
	 let senderID: User.IDValue
	 let senderMail: String
	 let receiverID: User.IDValue
	 let receiverMail: String
 }

	struct PaginatedOutput: Content {
		let messages: [Message]
		let pageCount: Int
	}
}

