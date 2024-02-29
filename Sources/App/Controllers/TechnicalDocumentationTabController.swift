//
//  TechnicalDocumentationTabController.swift
//
//
//  Created by Raphaël Payet on 29/02/2024.
//


import Fluent
import Vapor

struct TechnicalDocumentationTabController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let technicalDocumentationTabs = routes.grouped("api", "technicalDocumentationTabs")
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = technicalDocumentationTabs.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get(use: getAll)
    }
    
    // MARK: - CREATE
    func create(req: Request) async throws -> TechnicalDocumentationTab {
        let tabData = try req.content.decode(TechnicalDocumentationTab.Input.self)
        let adminUser = try req.auth.require(User.self)
        
        guard adminUser.userType == .admin else {
            throw Abort(.badRequest, reason: "User should be admin to create another user")
        }
        
        let technicalDocTab = TechnicalDocumentationTab(name: tabData.name)
        
        try await technicalDocTab.save(on: req.db)
        return technicalDocTab
    }
    
    // MARK: - READ
    func getAll(req: Request) async throws -> [TechnicalDocumentationTab] {
        try await TechnicalDocumentationTab
            .query(on: req.db)
            .all()
    }
}
