//
//  FormControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 10/05/2024.
//

@testable import App
import XCTVapor

// MARK: - Create
extension FormControllerTests {
  func testCreateFormSuceed() async throws {
      let user = try await User.create(username: expectedUsername, on: app.db)
      let token = try await Token.create(for: user, on: app.db)

        let userID = try user.requireID()
        let formInput = Form.CreationInput(
            title: expectedTitle,
            createdBy: userID.uuidString,
            value: expectedValue,
            path: expectedPath,
            clientID: expectedClientID
        )
      

        try app.test(.POST, baseRoute) { req in
            try req.content.encode(formInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let receivedForm = try res.content.decode(Form.self)
            XCTAssertEqual(receivedForm.title, expectedTitle)
            XCTAssertEqual(receivedForm.createdBy, userID.uuidString)
            XCTAssertEqual(receivedForm.value, expectedValue)
            XCTAssertEqual(receivedForm.path, expectedPath)
            XCTAssertEqual(receivedForm.clientID, expectedClientID)
        }
  } 
}
