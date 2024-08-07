//
//  File.swift
//  
//
//  Created by Raphaël Payet on 07/08/2024.
//

import Fluent
import Vapor

// MARK: - Delete
extension UserController {
    func remove(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        try await user.delete(force: true, on: req.db)
        return .noContent
    }
    
    func removeAll(req: Request) async throws -> HTTPStatus {
        try await User
            .query(on: req.db)
            .all()
            .delete(force: true, on: req.db)
        return .noContent
    }
}
