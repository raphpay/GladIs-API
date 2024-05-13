//
//  FormControllerTests+UPDATE.swift
//
//
//  Created by Raphaël Payet on 10/05/2024.
//

@testable import App
import XCTVapor

// MARK: - Update
extension FormControllerTests {
    func testUpdateFormSucceed() async throws {
        try await Form.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let userID = try user.requireID()
        
        let token = try await Token.create(for: user, on: app.db)
        let form = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: expectedClientID, path: expectedPath,
            on: app.db
        )
        
        let formID = try form.requireID()
        let formInput = Form.UpdateInput(
            updatedBy: userID.uuidString,
            value: expectedUpdatedValue,
            title: expectedUpdatedTitle,
            createdBy: nil
        )
        
        let route = "\(baseRoute)/\(formID)"
        try app.test(.PUT, route) { req in
            try req.content.encode(formInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedForm = try res.content.decode(Form.self)
            XCTAssertEqual(updatedForm.title, expectedUpdatedTitle)
            XCTAssertEqual(updatedForm.value, expectedUpdatedValue)
            XCTAssertEqual(updatedForm.clientID, expectedClientID)
        }
    }
    
    func testUpdateFormWithInexistantFormFails() async throws {
        try await Form.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let userID = try user.requireID()
        
        let token = try await Token.create(for: user, on: app.db)
        let formInput = Form.UpdateInput(
            updatedBy: userID.uuidString,
            value: expectedUpdatedValue,
            title: expectedUpdatedTitle,
            createdBy: nil
        )
      
        let route = "\(baseRoute)/123456"
        try app.test(.PUT, route) { req in
            try req.content.encode(formInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.form"))
        }
    }
}

// MARK: - Approve Form By Admin
extension FormControllerTests {
    func testApproveFormByAdminSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let form = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: expectedClientID, path: expectedPath,
            on: app.db
        )
        
        let formID = try form.requireID()
        let route = "\(baseRoute)/admin/\(formID)/approve"
        try app.test(.PUT, route) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedForm = try res.content.decode(Form.self)
            XCTAssertEqual(updatedForm.approvedByAdmin, true)
        }
    }

    func testApproveFormByAdminWithInexistantFormFails() async throws {
        try await Form.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let route = "\(baseRoute)/admin/123456/approve"
        try app.test(.PUT, route) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.form"))
        }
    }
}

// MARK: - Deapprove Form By Admin
extension FormControllerTests {
    func testDeapproveFormByAdminSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let form = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: expectedClientID, path: expectedPath,
            on: app.db
        )

        try await Form.approveByAdmin(form, on: app.db)
        
        let formID = try form.requireID()
        let route = "\(baseRoute)/admin/\(formID)/deapprove"
        try app.test(.PUT, route) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedForm = try res.content.decode(Form.self)
            XCTAssertEqual(updatedForm.approvedByAdmin, false)
        }
    }

    func testDeapproveFormByAdminWithInexistantFormFails() async throws {
        try await Form.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let form = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: expectedClientID, path: expectedPath,
            on: app.db
        )

        try await Form.approveByAdmin(form, on: app.db)
        
        let route = "\(baseRoute)/admin/123456/approve"
        try app.test(.PUT, route) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.form"))
        }
    }
}

// MARK: - Approve Form By Client
extension FormControllerTests {
    func testApproveFormByClient() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let form = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: expectedClientID, path: expectedPath,
            on: app.db
        )
        
        let formID = try form.requireID()
        let route = "\(baseRoute)/client/\(formID)/approve"
        try app.test(.PUT, route) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedForm = try res.content.decode(Form.self)
            XCTAssertEqual(updatedForm.approvedByClient, true)
        }
    }

    func testApproveFormByClientWithInexistantFormFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let route = "\(baseRoute)/client/123456/approve"
        try app.test(.PUT, route) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.form"))
        }
    }
}

// MARK: - Deapprove Form By Client
extension FormControllerTests {
    func testDeapproveFormByClient() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let form = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: expectedClientID, path: expectedPath,
            on: app.db
        )

        try await Form.approveByClient(form, on: app.db)
        
        let formID = try form.requireID()
        let route = "\(baseRoute)/client/\(formID)/deapprove"
        try app.test(.PUT, route) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedForm = try res.content.decode(Form.self)
            XCTAssertEqual(updatedForm.approvedByClient, false)
        }
    }

    func testDeapproveFormByClientWithInexistantFormFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let form = try await Form.create(
            title: expectedTitle, value: expectedValue,
            clientID: expectedClientID, path: expectedPath,
            on: app.db
        )

        try await Form.approveByClient(form, on: app.db)
        
        let route = "\(baseRoute)/client/123456/deapprove"
        try app.test(.PUT, route) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.form"))
        }
    }
}
