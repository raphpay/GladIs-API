//
//  PendingUserControllerTests+CREATE.swift
//  
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Create
extension PendingUserControllerTests {
    func testCreatePendingUserSucceed() async throws {        
        let pendingUserInput = PendingUserControllerTests().createExpectedPendingUserInput()
        
        try app.test(.POST, baseRoute) { req in
            try req.content.encode(pendingUserInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let createdPendingUser = try res.content.decode(PendingUser.self)
            XCTAssertEqual(createdPendingUser.firstName, expectedFirstName)
            XCTAssertEqual(createdPendingUser.lastName, expectedLastName)
            XCTAssertEqual(createdPendingUser.phoneNumber, expectedPhoneNumber)
            XCTAssertEqual(createdPendingUser.companyName, expectedCompanyName)
            XCTAssertEqual(createdPendingUser.email, expectedEmail)
            XCTAssertEqual(createdPendingUser.products, expectedProducts)
            XCTAssertEqual(createdPendingUser.numberOfEmployees, expectedNumberOfEmployees)
            XCTAssertEqual(createdPendingUser.numberOfUsers, expectedNumberOfUsers)
            XCTAssertEqual(createdPendingUser.salesAmount, expectedSalesAmount)
        }
    }
    
    func testCreatePendingUserWithAlreadyExistingMailFails() async throws {
        let _ = try await PendingUserControllerTests().createExpectedPendingUser(on: app.db)
        let pendingUserInput = PendingUserControllerTests().createExpectedPendingUserInput()
        
        try app.test(.POST, baseRoute) { req in
            try req.content.encode(pendingUserInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.emailAlreadyExists"))
        }
    }
}

// MARK: - Convert To User
extension PendingUserControllerTests {
    func testConvertToUserSuceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let pendingUser = try await PendingUserControllerTests().createExpectedPendingUser(on: app.db)
        
        let pendingUserID = try pendingUser.requireID()
        try app.test(.POST, "\(baseRoute)/\(pendingUserID)/convertToUser") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.Public.self)
            XCTAssertEqual(user.firstName, expectedFirstName)
            XCTAssertEqual(user.lastName, expectedLastName)
            XCTAssertEqual(user.email, expectedEmail)
        }
    }
 
    func testConvertToUserWithoutAdminPermissionFails() async throws {
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let clientToken = try await Token.create(for: user, on: app.db)
        
        let pendingUser = try await PendingUserControllerTests().createExpectedPendingUser(on: app.db)
        
        let pendingUserID = try pendingUser.requireID()
        try app.test(.POST, "\(baseRoute)/\(pendingUserID)/convertToUser") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: clientToken.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        }
    }
    
    func testConvertToUserWithInexistantPendingUserFails() async throws {
        try app.test(.POST, "\(baseRoute)/2345/convertToUser") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.pendingUser"))
        }
    }
}
