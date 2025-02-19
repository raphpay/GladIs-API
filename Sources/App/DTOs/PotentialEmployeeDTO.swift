//
//  PotentialEmployeeDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 19/02/2024
//

import Vapor

extension PotentialEmployee {
  struct Input: Content {
        var id: UUID?
        let firstName: String
        let lastName: String
        let companyName: String
        let phoneNumber: String
        let email: String
        let pendingUserID: PendingUser.IDValue
    }

    struct ConvertInput: Content {
      let password: String
    }
}