//
//  FormControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 10/05/2024.
//

@testable import App
import XCTVapor

// MARK: - Get All
extension FormControllerTests {
    func testGetAllFormsSucceed() async throws {
        try await Form.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let _ = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: expectedClientID, path: expectedPath,
            on: app.db
        )
        
        try app.test(.GET, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let forms = try res.content.decode([Form].self)
            XCTAssertEqual(forms.count, 1)
            XCTAssertEqual(forms.first?.title, expectedTitle)
            XCTAssertEqual(forms.first?.value, expectedValue)
            XCTAssertEqual(forms.first?.path, expectedPath)
            XCTAssertEqual(forms.first?.clientID, expectedClientID)
        }
    }

    func testGetAllFormsWithoutFormsSucceed() async throws {
        try await Form.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.GET, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let forms = try res.content.decode([Form].self)
            XCTAssertEqual(forms.count, 0)
        }
    }
}

// MARK: - Get By Client At Path
extension FormControllerTests {
    func testGetByClientAtPathSucceed() async throws {
        try await Form.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let client = try await User.create(username: expectedClientUsername, on: app.db)
        let clientID = try client.requireID().uuidString
        let _ = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: clientID, path: expectedPath,
            on: app.db
        )
        
        let route = "\(baseRoute)/client/\(clientID)/path"
        try app.test(.POST, route) { req in
            try req.content.encode(Form.PathInput(value: expectedPath))
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let forms = try res.content.decode([Form].self)
            XCTAssertEqual(forms.count, 1)
            XCTAssertEqual(forms.first?.title, expectedTitle)
            XCTAssertEqual(forms.first?.value, expectedValue)
            XCTAssertEqual(forms.first?.path, expectedPath)
            XCTAssertEqual(forms.first?.clientID, clientID)
        }
    }

    func testGetByClientAtPathWithWrongClientFails() async throws {
        try await Form.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let _ = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: expectedClientID, path: expectedPath,
            on: app.db
        )
        
        let route = "\(baseRoute)/client/123456/path"
        try app.test(.POST, route) { req in
            try req.content.encode(Form.PathInput(value: expectedPath))
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}
