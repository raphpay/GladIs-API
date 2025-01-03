//
//  Utils.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 03/01/2025.
//

import Vapor

struct Utils {
    static func checkRole(on req: Request, allowedRoles: [User.UserType]) throws {
        let user = try req.auth.require(User.self)
        guard allowedRoles.contains(user.userType) else {
            throw Abort(.unauthorized, reason: "unauthorized.role")
        }
    }
}
