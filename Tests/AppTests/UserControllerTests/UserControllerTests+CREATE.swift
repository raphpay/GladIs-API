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
        let userInput = User.Input(firstName: expectedFirstName, lastName: expectedLastName,
                                   phoneNumber: expectedPhoneNumber, email: expectedEmail,
                                   password: expectedPassword, userType: .admin,
                                   companyName: nil, products: nil,
                                   numberOfEmployees: nil, numberOfUsers: nil,
                                   salesAmount: nil, employeesIDs: nil, managerID: nil)
        let path = "\(baseRoute)/noToken"
        try app.test(.POST, path) { req in
            try req.content.encode(userInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let createdUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(createdUser.firstName, expectedFirstName)
            XCTAssertEqual(createdUser.lastName, expectedLastName)
        }
    }
    
    func testCreateUserWithoutTokenWithEmptyPasswordFails() async throws {
        let userInput = User.Input(firstName: expectedFirstName, lastName: expectedLastName,
                                   phoneNumber: expectedPhoneNumber, email: expectedEmail,
                                   password: "", userType: .admin,
                                   companyName: nil, products: nil,
                                   numberOfEmployees: nil, numberOfUsers: nil,
                                   salesAmount: nil, employeesIDs: nil, managerID: nil)
        let path = "\(baseRoute)/noToken"
        try app.test(.POST, path) { req in
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
        let userInput = User.Input(firstName: expectedFirstName, lastName: expectedLastName,
                                   phoneNumber: expectedPhoneNumber, email: expectedEmail,
                                   password: expectedPassword, userType: .admin,
                                   companyName: nil, products: nil,
                                   numberOfEmployees: nil, numberOfUsers: nil,
                                   salesAmount: nil, employeesIDs: nil, managerID: nil)
        let admin = try await User.create(username: expectedAdminUsername, userType: .admin, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        
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
        let userInput = User.Input(firstName: expectedFirstName, lastName: expectedLastName,
                                   phoneNumber: expectedPhoneNumber, email: expectedEmail,
                                   password: expectedPassword, userType: .admin,
                                   companyName: nil, products: nil,
                                   numberOfEmployees: nil, numberOfUsers: nil,
                                   salesAmount: nil, employeesIDs: nil, managerID: nil)
        let user = try await User.create(username: expectedAdminUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.POST, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(userInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        }
    }
    
    func testCreateUserWithEmptyPasswordFails() async throws {
        let userInput = User.Input(firstName: expectedFirstName, lastName: expectedLastName,
                                   phoneNumber: expectedPhoneNumber, email: expectedEmail,
                                   password: "", userType: .admin,
                                   companyName: nil, products: nil,
                                   numberOfEmployees: nil, numberOfUsers: nil,
                                   salesAmount: nil, employeesIDs: nil, managerID: nil)
        let user = try await User.create(username: expectedAdminUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
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
        let token = try await Token.create(for: user, on: app.db)
        let docTab = try await TechnicalDocumentationTab.create(name: expectedDocTabName, area: expectedDocTabArea, on: app.db)
        
        let userID = try user.requireID()
        let tabID = try docTab.requireID()
        let path = "\(baseRoute)/\(userID)/technicalDocumentationTabs/\(tabID)"
        try app.test(.POST, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let tab = try res.content.decode(TechnicalDocumentationTab.self)
            XCTAssertEqual(tab.name, expectedDocTabName)
            XCTAssertEqual(tab.area, expectedDocTabArea)
        }
    }
    
    func testAddTechnicalDocTabWithInexistantUserFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let docTab = try await TechnicalDocumentationTab.create(name: expectedDocTabName, area: expectedDocTabArea, on: app.db)
        
        let tabID = try docTab.requireID()
        let path = "\(baseRoute)/12345/technicalDocumentationTabs/\(tabID)"
        try app.test(.POST, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testAddTechnicalDocTabWithInexistantTabFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/technicalDocumentationTabs/1234"
        try app.test(.POST, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.technicalTab"))
        }
    }
}

// MARK: - Verify Password
extension UserControllerTests {
    func testVerifyPasswordSucceed() async throws {
        let user = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let passwordValidationRequest = PasswordValidationRequest(currentPassword: expectedPassword)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/verifyPassword"
        try app.test(.POST, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(passwordValidationRequest)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func testVerifyPasswordWithWrongPasswordFails() async throws {
        let user = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let passwordValidationRequest = PasswordValidationRequest(currentPassword: "wrongPassword")
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/verifyPassword"
        try app.test(.POST, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(passwordValidationRequest)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.password.invalidCurrent"))
        }
    }
    
    func testVerifyPasswordWithDifferentUserFails() async throws {
        let user = try await User.create(username: expectedUsername, userType: .client, password: expectedPassword, on: app.db)
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        let passwordValidationRequest = PasswordValidationRequest(currentPassword: expectedPassword)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/verifyPassword"
        try app.test(.POST, path) { req in
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
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let user = try await User.create(username: expectedUsername, userType: .client, email: expectedEmail, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
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
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
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

// MARK: - Get User By Mail
extension UserControllerTests {
    func testGetUserByUsernameSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let input = User.UsernameInput(username: expectedUsername)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/byUsername"
        try app.test(.POST, path) { req in
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let foundUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(foundUser.id?.uuidString, userID.uuidString)
        }
    }
    
    func testGetUserByUserNameWithWrongUsernameFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let input = User.UsernameInput(username: "hello")
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/byUsername"
        try app.test(.POST, path) { req in
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}
