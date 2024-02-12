//
//  TokenController.swift
//
//
//  Created by Raphaël Payet on 09/02/2024.
//


import Fluent
import Vapor

struct TokenController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let tokens = routes.grouped("api", "tokens")
        tokens.get(":tokenID", use: getTokenByID)
    }
    
    // MARK: - Read
    func getTokenByID(req: Request) throws -> EventLoopFuture<Token> {
        Token
            .find(req.parameters.get("tokenID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}
