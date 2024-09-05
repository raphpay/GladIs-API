//
//  UserControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Create Without Token
extension UserControllerTests {
    func testCreateUserWithoutTokenSucceed() async throws {
        let userInput = UserControllerTests().createExpectedUserInput()
        
        try app.test(.POST, "\(baseRoute)/noToken") { req in
            try req.content.encode(userInput)
        } afterResponse: { res in
            print("res \(res)")
            XCTAssertEqual(res.status, .ok)
            let createdUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(createdUser.firstName, expectedFirstName)
            XCTAssertEqual(createdUser.lastName, expectedLastName)
        }
    }
    
    func testCreateUserWithoutTokenWithEmptyPasswordFails() async throws {
        let userInput = UserControllerTests().createExpectedUserInput(password: "")
        try app.test(.POST, "\(baseRoute)/noToken") { req in
            try req.content.encode(userInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.password"))
        }
    }
}


// MARK: - Create
extension UserControllerTests {
    func testCreateUserSucceed() async throws {
        let userInput = UserControllerTests().createExpectedUserInput()
        
        try app.test(.POST, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(userInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let createdUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(createdUser.firstName, expectedFirstName)
            XCTAssertEqual(createdUser.lastName, expectedLastName)
        }
    }
    
    func testCreateUserWithoutAdminPermissionFails() async throws {
        let userInput = UserControllerTests().createExpectedUserInput()
        
        let user = try await User.create(username: expectedAdminUsername, userType: .client, on: app.db)
        let clientToken = try await Token.create(for: user, on: app.db)
        
        try app.test(.POST, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: clientToken.value)
            try req.content.encode(userInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        }
    }
    
    func testCreateUserWithEmptyPasswordFails() async throws {
        let userInput = UserControllerTests().createExpectedUserInput(password: "")
        
        try app.test(.POST, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(userInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.password"))
        }
    }
}


// MARK: - Add Technical Doc Tab
extension UserControllerTests {
    func testAddTechnicalDocTabSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let docTab = try await TechnicalDocumentationTab.create(name: expectedDocTabName, area: expectedDocTabArea, on: app.db)
        
        let userID = try user.requireID()
        let tabID = try docTab.requireID()
        try app.test(.POST, "\(baseRoute)/\(userID)/technicalDocumentationTabs/\(tabID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let tab = try res.content.decode(TechnicalDocumentationTab.self)
            XCTAssertEqual(tab.name, expectedDocTabName)
            XCTAssertEqual(tab.area, expectedDocTabArea)
        }
    }
    
    func testAddTechnicalDocTabWithInexistantUserFails() async throws {
        let docTab = try await TechnicalDocumentationTab.create(name: expectedDocTabName, area: expectedDocTabArea, on: app.db)
        
        let tabID = try docTab.requireID()
        try app.test(.POST, "\(baseRoute)/12345/technicalDocumentationTabs/\(tabID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectUserID"))
        }
    }
    
    func testAddTechnicalDocTabWithInexistantTabFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let userID = try user.requireID()
        
        try app.test(.POST, "\(baseRoute)/\(userID)/technicalDocumentationTabs/1234") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectTabID"))
        }
    }
}

// MARK: - Verify Password
extension UserControllerTests {
    func testVerifyPasswordSucceed() async throws {
        let user = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        let userID = try user.requireID()
        token = try await Token.create(for: user, on: app.db)
        
        let passwordValidationRequest = PasswordValidationRequest(currentPassword: expectedPassword)
        
        try app.test(.POST, "\(baseRoute)/\(userID)/verifyPassword") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(passwordValidationRequest)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func testVerifyPasswordWithWrongPasswordFails() async throws {
        let user = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        let userID = try user.requireID()
        token = try await Token.create(for: user, on: app.db)
        
        let passwordValidationRequest = PasswordValidationRequest(currentPassword: "wrongPassword")
        
        try app.test(.POST, "\(baseRoute)/\(userID)/verifyPassword") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(passwordValidationRequest)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.password.invalidCurrent"))
        }
    }
    
    func testVerifyPasswordWithDifferentUserFails() async throws {
        let user = try await User.create(username: expectedUsername, userType: .client, password: expectedPassword, on: app.db)
        let userID = try user.requireID()
        
        let passwordValidationRequest = PasswordValidationRequest(currentPassword: expectedPassword)
        
        try app.test(.POST, "\(baseRoute)/\(userID)/verifyPassword") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(passwordValidationRequest)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.access"))
        }
    }
}

// MARK: - Get User By Mail
extension UserControllerTests {
    func testGetUserByMailSucceed() async throws {
        let user = try await User.create(username: expectedUsername, userType: .client, email: expectedEmail, on: app.db)
        let userEmailInput = User.EmailInput(email: expectedEmail)
        
        let path = "\(baseRoute)/byMail"
        try app.test(.POST, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(userEmailInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let foundUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(foundUser.id, user.id)
        }
    }
    
    func testGetUserByMailWithInexistantUserFails() async throws {
        let userEmailInput = User.EmailInput(email: expectedEmail)
        
        let path = "\(baseRoute)/byMail"
        try app.test(.POST, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(userEmailInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}
