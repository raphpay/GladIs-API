//
//  FormControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 10/05/2024.
//

@testable import App
import XCTVapor

// MARK: - Delete
extension FormControllerTests {
    func testDeleteFormSucceed() async throws {
        try await Form.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let form = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: expectedClientID, path: expectedPath,
            on: app.db
        )
        
        let formID = try form.requireID()
        let route = "\(baseRoute)/\(formID)"
        try app.test(.DELETE, route) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
    
    func testDeleteFormWithInexistantFormFails() async throws {
        try await Form.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let route = "\(baseRoute)/123456"
        try app.test(.DELETE, route) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.form"))
        }
    }
}

// MARK: - Delete All
extension FormControllerTests {
    func testDeleteAllFormsSucceed() async throws {
        try await Form.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let form = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: expectedClientID, path: expectedPath,
            on: app.db
        )
        
        try app.test(.DELETE, "\(baseRoute)/all") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
}
