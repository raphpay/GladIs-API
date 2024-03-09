//
//  PotentialEmployee+Ext.swift
//
//
//  Created by Raphaël Payet on 09/03/2024.
//

import Foundation

extension PotentialEmployee {
    func convertToEmployee() -> User {
        let user = User(firstName: self.firstName, lastName: self.lastName,
                        phoneNumber: self.phoneNumber,
                        username: "", password: "Passwordlong1(",
                        email: self.email, firstConnection: true, userType: .employee,
                        companyName: self.companyName)
        // TODO: Generate and send a password
        return user
    }
}
