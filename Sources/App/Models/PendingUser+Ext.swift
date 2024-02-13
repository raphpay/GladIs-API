//
//  PendingUser+Ext.swift
//  
//
//  Created by Raphaël Payet on 13/02/2024.
//

import Foundation

extension PendingUser {
    func convertToUser() -> User {
        let user = User(
            firstName: self.firstName,
            lastName: self.lastName,
            phoneNumber: self.phoneNumber,
            companyName: self.companyName,
            email: self.email,
            products: self.products,
            numberOfEmployees: self.numberOfEmployees,
            numberOfUsers: self.numberOfUsers,
            salesAmount: self.salesAmount,
            username: "",
            password: "",
            firstConnection: true,
            userType: .client
        )
        // TODO: Get the modules right after
        // TODO: Generate and send a password
        return user
    }
}
