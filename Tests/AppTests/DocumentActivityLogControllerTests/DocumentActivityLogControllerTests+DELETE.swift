//
//  DocumentActivityLogControllerTests+DELETE.swift
//  
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

extension DocumentActivityLogControllerTests {
    func testDeleteAllDocumentActivityLogs() async throws {
        let user = try await createUser(app: app, username: expectedUsername)
        let token = try await createToken(app: app, user: user)
        
        try app.test(.DELETE, "api/documentActivityLogs") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
}
