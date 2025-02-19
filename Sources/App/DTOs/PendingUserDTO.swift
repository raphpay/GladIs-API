//
//  PendingUserDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 19/02/2025.
//

import Vapor

extension PendingUser {
  struct Input: Content {
      var id: UUID?
      let firstName: String
      let lastName: String
      let phoneNumber: String
      let companyName: String
      let email: String
      let products: String
      let numberOfEmployees: Int?
      let numberOfUsers: Int?
      let salesAmount: Double?
  }

  struct StatusInput: Content {
      let type: StatusEnum
  }

  struct ConvertInput: Content {
    let password: String
  }
}