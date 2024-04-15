//
//  EventControllerTests+DELETE.swift
//  
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

// MARK: - DELETE
extension EventControllerTests {
    func testDeleteAllEvents() async throws {
        let user = try await createUser()
        let token = try await createToken(user: user)
        
        try app.test(.DELETE, "api/events//all") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
}
