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
        tokens.delete(":tokenID", use: logout)
        // Basic Auth
        let basicAuthMiddleware = User.authenticator()
        let basicAuthGroup = tokens.grouped(basicAuthMiddleware)
        // Login
        basicAuthGroup.post("login", use: login)
        // Bearer authentication
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = tokens.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.get(use: getTokens)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    // MARK: - READ
    func getTokenByID(req: Request) async throws -> Token {
        guard let token = try await Token.find(req.parameters.get("tokenID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.token")
        }
        
        return token
    }
    
    func getTokens(req: Request) async throws -> [Token] {
        try await Token
            .query(on: req.db)
            .all()
    }
    
    // MARK: - Login
    func login(req: Request) async throws -> Token {
        // Extract credentials from the Authorization header (Basic Auth)
        let credentials = try decodeBasicAuth(req.headers)
        
        // Fetch the user based on the username
        guard let user = try await User.query(on: req.db)
            .filter(\.$username == credentials.username)
            .first() else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        try await handleMaxLoginAttempt(user: user, on: req)
        
        let newToken = try await verifyPassword(credentials: credentials, user: user, on: req)
        return newToken
    }
        
    func logout(req: Request) async throws -> HTTPStatus {
        guard let token = try await Token.find(req.parameters.get("tokenID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.token")
        }
        
        try await token.delete(force: true, on: req.db)
        return .noContent
    }
    
    // MARK: - Delete
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        let authUser = try req.auth.require(User.self)
        
        guard authUser.userType == .admin else {
            throw Abort(.forbidden, reason: "forbidden.userShouldBeAdmin")
        }
        
        try await Token.query(on: req.db)
            .all()
            .delete(force: true, on: req.db)
        
        return .noContent
    }
}

// MARK: - Private Methods
extension TokenController {
    private func decodeBasicAuth(_ headers: HTTPHeaders) throws -> (username: String, password: String) {
        // Get the Authorization header from the request headers
        guard let authHeader = headers.first(name: .authorization) else {
            throw Abort(.unauthorized, reason: "unauthorized.missingAuthorizationHeader")
        }
            
        // Check that the Authorization header starts with "Basic"
        guard authHeader.lowercased().hasPrefix("basic ") else {
            throw Abort(.unauthorized, reason: "unauthorized.invalidAuthorizationHeader")
        }

        // Extract the base64 encoded part of the Authorization header
        let base64String = authHeader.dropFirst(6) // Drop "Basic " prefix
        
        // Decode the base64 encoded string into data
        guard let data = Data(base64Encoded: String(base64String)) else {
            throw Abort(.unauthorized, reason: "unauthorized.wrongAuthorizationHeader")
        }

        // Convert the decoded data into a UTF-8 string
        guard let decodedString = String(data: data, encoding: .utf8) else {
            throw Abort(.unauthorized, reason: "unauthorized.wrongAuthorizationHeaderData")
        }

        // Split the decoded string into username (email) and password
        let components = decodedString.split(separator: ":")
        guard components.count == 2 else {
            throw Abort(.unauthorized, reason: "unauthorized.invalidAuthorizationFormat")
        }

        // Return the username (email) and password
        let username = String(components[0])
        let password = String(components[1])
        
        return (username, password)
    }
        
    private func handleMaxLoginAttempt(user: User, on req: Request) async throws {
        // Define max attempts and lockout duration
        let maxAttempts = 5

        // Check if the user has exceeded the max login attempts or is blocked
        if user.isConnectionBlocked == true {
            throw Abort(.forbidden, reason: "forbidden.accountBlocked")
        }
        
        if let connectionFailedAttempts = user.connectionFailedAttempts,
            connectionFailedAttempts >= maxAttempts,
           user.isConnectionBlocked == true {
            user.isConnectionBlocked = true
            try await user.update(on: req.db)
            throw Abort(.unauthorized, reason: "unauthorized.maxLoginAttemptReached")
        }
    }
    
    private func verifyPassword(credentials: (username: String, password: String), user: User, on req: Request) async throws -> Token {
        // Verify the password
        if try Bcrypt.verify(credentials.password, created: user.password) {
            // Successful login, reset failed attempts
            if user.connectionFailedAttempts != nil {
                user.connectionFailedAttempts = 0
            }
            try await user.save(on: req.db)
            
            // Generate or update the token
            let token = try await Token
                .query(on: req.db)
                .filter(\.$user.$id == user.id!)
                .first()
            
            if let token = token {
                token.value = [UInt8].random(count: 16).base64
                try await token.update(on: req.db)
                return token
            } else {
                // If no token exists, create a new one
                let newToken = try Token.generate(for: user)
                try await newToken.save(on: req.db)
                return newToken
            }
        } else {
            // Failed login attempt
            if user.connectionFailedAttempts != nil {
                user.connectionFailedAttempts! += 1
            } else {
                user.connectionFailedAttempts = 1
            }
            
            try await user.update(on: req.db)
            
            // Throw unauthorized error
            throw Abort(.unauthorized, reason: "unauthorized.invalidCredentials")
        }
    }
}
