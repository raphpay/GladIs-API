//
//  PendingUser+Ext.swift
//  
//
//  Created by Raphaël Payet on 13/02/2024.
//

import Foundation

extension PendingUser {
    func convertToUser() -> User {
        let user = User(firstName: self.firstName, lastName: self.lastName,
                        phoneNumber: self.phoneNumber,
                        username: "", password: "Passwordlong1(",
                        email: self.email, firstConnection: true, userType: .client,
                        companyName: self.companyName, products: self.products,
                        numberOfEmployees: self.numberOfEmployees, numberOfUsers: self.numberOfUsers,
                        salesAmount: self.salesAmount)
        // TODO: Get the modules right after
        // TODO: Generate and send a password
        return user
    }
}
