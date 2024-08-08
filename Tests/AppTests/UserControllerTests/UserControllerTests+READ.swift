//
//  UserControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Get All
extension UserControllerTests {
    func testGetAllSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.GET, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let users = try res.content.decode([User.Public].self)
            XCTAssertEqual(users.count, 1)
            XCTAssertEqual(users[0].username, expectedUsername)
        }
    }
}

// MARK: - Get All Clients
extension UserControllerTests {
    func testGetAllClientsSucceed() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let client = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        
        let path = "\(baseRoute)/clients"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let clients = try res.content.decode([User.Public].self)
            XCTAssertEqual(clients.count, 1)
            XCTAssertEqual(clients[0].username, expectedUsername)
        }
    }
}

// MARK: - Get Admins
extension UserControllerTests {
    func testGetAllAdminsSucceed() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let _ = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        
        let path = "\(baseRoute)/admins"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let admins = try res.content.decode([User.Public].self)
            XCTAssertEqual(admins.count, 2)
            XCTAssertEqual(admins[0].username, expectedAdminUsername)
            XCTAssertEqual(admins[1].username, expectedUsername)
        }
    }
}

// MARK: - Get User By ID
extension UserControllerTests {
    func testGetUserByIDSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.Public.self)
            XCTAssertEqual(user.username, expectedUsername)
        }
    }
    
    func testGetUserByIdWithInexistantUserFails() async throws {
        let userID = UUID()
        let path = "\(baseRoute)/\(userID)"
        
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testGetUserByIDWithIncorrectIDFails() async throws {
        let path = "\(baseRoute)/12345"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectUserID"))
        }
    }
}

// MARK: - Get Modules
extension UserControllerTests {
    func testGetUserModulesSucceed() async throws {
        let adminID = try admin.requireID()
        
        let module = Module(name: expectedModuleName, index: expectedModuleIndex)
        admin.modules = [module]
        try await admin.update(on: app.db)
        
        let path = "\(baseRoute)/\(adminID)/modules"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let modules = try res.content.decode([Module].self)
            XCTAssertEqual(modules.count, 1)
            XCTAssertEqual(modules[0].name, expectedModuleName)
            XCTAssertEqual(modules[0].index, expectedModuleIndex)
        }
    }
    
    func testGetUserModuleWithInexistantUserFails() async throws {
        let falseUserID = UUID()
        let path = "\(baseRoute)/\(falseUserID)/modules"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testGetUserModuleWithIncorrectIDFails() async throws {
        let path = "\(baseRoute)/12345/modules"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectUserID"))
        }
    }
}

// MARK: - Get Technical Doc Tabs
extension UserControllerTests {
    func testGetUserTabsSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let tab = try await TechnicalDocumentationTab.create(name: expectedDocTabName, area: expectedDocTabArea, on: app.db)
        try await User.attachTechnicalTab(tab, to: user, on: app.db)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/technicalDocumentationTabs"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let tabs = try res.content.decode([TechnicalDocumentationTab].self)
            XCTAssertEqual(tabs.count, 1)
            XCTAssertEqual(tabs[0].name, expectedDocTabName)
            XCTAssertEqual(tabs[0].area, expectedDocTabArea)
        }
    }
    
    func testGetUserTabWithInexistantUserFails() async throws {
        let falseUserID = UUID()
        let tab = try await TechnicalDocumentationTab.create(name: expectedDocTabName, area: expectedDocTabArea, on: app.db)
        try await User.attachTechnicalTab(tab, to: admin, on: app.db)
        
        let path = "\(baseRoute)/\(falseUserID)/technicalDocumentationTabs"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testGetUserTabWithIncorrectIDFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let tab = try await TechnicalDocumentationTab.create(name: expectedDocTabName, area: expectedDocTabArea, on: app.db)
        try await User.attachTechnicalTab(tab, to: user, on: app.db)
        
        let path = "\(baseRoute)/12345/technicalDocumentationTabs"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectUserID"))
        }
    }
}

// MARK: - Get Manager
extension UserControllerTests {
    func testGetManagerSucceed() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let manager = try await User.create(username: expectedUsername, on: app.db)
        let employee = try await User.create(username: "employeeUsername", on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        
        let managerID = try manager.requireID()
        let employeeID = try employee.requireID()
        employee.managerID = managerID.uuidString
        manager.employeesIDs = [employeeID.uuidString]
        try await employee.update(on: app.db)
        try await manager.update(on: app.db)
        
        let path = "\(baseRoute)/\(employeeID)/manager"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let foundManager = try res.content.decode(User.Public.self)
            XCTAssertEqual(foundManager.username, expectedUsername)
            XCTAssertEqual(foundManager.employeesIDs, [employeeID.uuidString])
        }
    }
    
    func testGetManagerWithInexistantEmployeeFails() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let manager = try await User.create(username: expectedUsername, on: app.db)
        let employee = try await User.create(username: "employeeUsername", on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        
        let managerID = try manager.requireID()
        let employeeID = try employee.requireID()
        employee.managerID = managerID.uuidString
        manager.employeesIDs = [employeeID.uuidString]
        try await employee.update(on: app.db)
        try await manager.update(on: app.db)
        
        let path = "\(baseRoute)/12345/manager"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testGetManagerWithEmptyManagerFails() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let manager = try await User.create(username: expectedUsername, on: app.db)
        let employee = try await User.create(username: "employeeUsername", on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        
        let managerID = try manager.requireID()
        let employeeID = try employee.requireID()
        
        manager.employeesIDs = [employeeID.uuidString]
        try await employee.update(on: app.db)
        try await manager.update(on: app.db)
        
        let path = "\(baseRoute)/\(employeeID)/manager"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}


// MARK: - Get Employees
extension UserControllerTests {
    func testGetEmployeesSucceed() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let manager = try await User.create(username: expectedUsername, on: app.db)
        let employee = try await User.create(username: "employeeUsername", on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        
        let managerID = try manager.requireID()
        let employeeID = try employee.requireID()
        employee.managerID = managerID.uuidString
        manager.employeesIDs = [employeeID.uuidString]
        try await employee.update(on: app.db)
        try await manager.update(on: app.db)
        
        let path = "\(baseRoute)/\(managerID)/employees"
        
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let foundEmployees = try res.content.decode([User.Public].self)
            XCTAssertEqual(foundEmployees.count, 1)
            XCTAssertEqual(foundEmployees[0].id, employeeID)
            XCTAssertEqual(foundEmployees[0].managerID, managerID.uuidString)
        }
    }
    
    func testGetEmployeesWithInexistantManagerFails() async throws {
        let falseUserID = UUID()
        let path = "\(baseRoute)/\(falseUserID)/employees"
        
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testGetEmployeesWithIncorrectIDFails() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        
        let path = "\(baseRoute)/23456/employees"
        
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectUserID"))
        }
    }
}

// MARK: - Get Token
extension UserControllerTests {
    func testGetTokenSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/token"
        
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let fetchedToken = try res.content.decode(Token.self)
            XCTAssertEqual(fetchedToken.value, token.value)
        }
    }
    
    func testGetTokenWithInexistantUserFails() async throws {
        let falseUserID = UUID()
        let path = "\(baseRoute)/\(falseUserID)/token"
        
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testGetTokenWithIncorrectIDFails() async throws {
        let path = "\(baseRoute)/12345/token"
        
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectUserID"))
        }
    }
}

// MARK: - Get Reset Tokens For Client
extension UserControllerTests {
    func testGetResetTokensForClientSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let resetToken = try await PasswordResetToken.create(for: user, on: app.db)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/resetToken"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let fetchedToken = try res.content.decode(PasswordResetToken.self)
            XCTAssertEqual(fetchedToken.token, resetToken.token)
        }
    }
    
    func testGetResetTokenWithInexistantUserFails() async throws {
        let _ = try await User.create(username: expectedUsername, on: app.db)
        let falseUserID = UUID()
        
        let path = "\(baseRoute)/\(falseUserID)/resetToken"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testGetResetTokenWithIncorrectIDFails() async throws {
        let path = "\(baseRoute)/123456/resetToken"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectUserID"))
        }
    }
    
    func testGetResetTokenWithoutAdminPermissionFails() async throws {
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let userToken = try await Token.create(for: user, on: app.db)
        let resetToken = try await PasswordResetToken.create(for: user, on: app.db)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/resetToken"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: userToken.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        }
    }
}

// MARK: - Get All User Messages
extension UserControllerTests {
    func testGetAllUserMessagesSucceed() async throws {
        let sender = try await User.create(username: expectedUsername, on: app.db)
        let receiver = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: sender, on: app.db)
        let _ = try await Message.create(title: expectedMessageTitle, content: expectedMessageContent, sender: sender, receiver: receiver, on: app.db)
        
        let userID = try sender.requireID()
        let path = "\(baseRoute)/\(userID)/messages/all"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let messages = try res.content.decode([Message].self)
            XCTAssertEqual(messages.count, 1)
            XCTAssertEqual(messages[0].title, expectedMessageTitle)
            XCTAssertEqual(messages[0].content, expectedMessageContent)
        }
    }
}

// MARK: - Get Received Messages
extension UserControllerTests {
    func testGetReceivedMessagesWithMessagesSucceed() async throws {
        let sender = try await User.create(username: expectedUsername, on: app.db)
        let receiver = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: sender, on: app.db)
        let _ = try await Message.create(title: expectedMessageTitle, content: expectedMessageContent, sender: sender, receiver: receiver, on: app.db)
        
        let userID = try receiver.requireID()
        let path = "\(baseRoute)/\(userID)/messages/received"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let messages = try res.content.decode([Message].self)
            XCTAssertEqual(messages.count, 1)
            XCTAssertEqual(messages[0].title, expectedMessageTitle)
            XCTAssertEqual(messages[0].content, expectedMessageContent)
        }
    }
    
    func testGetReceivedMessagesWithoutMessagesSucceedWithEmptyResponse() async throws {
        let sender = try await User.create(username: expectedUsername, on: app.db)
        let receiver = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: sender, on: app.db)
        let _ = try await Message.create(title: expectedMessageTitle, content: expectedMessageContent, sender: sender, receiver: receiver, on: app.db)
        
        let userID = try sender.requireID()
        let path = "\(baseRoute)/\(userID)/messages/received"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let messages = try res.content.decode([Message].self)
            XCTAssertEqual(messages.count, 0)
        }
    }
    
    func testGetReceivedMessagesWithWrongUUIDFails() async throws {
        let sender = try await User.create(username: expectedUsername, on: app.db)
        let receiver = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let _ = try await Message.create(title: expectedMessageTitle, content: expectedMessageContent, sender: sender, receiver: receiver, on: app.db)
        
        let path = "\(baseRoute)/1/messages/received"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectUserID"))
        }
    }
}

// MARK: - Get Sent Messages
extension UserControllerTests {
    func testGetSentMessagesWithMessagesSucceed() async throws {
        let sender = try await User.create(username: expectedUsername, on: app.db)
        let receiver = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: sender, on: app.db)
        let _ = try await Message.create(title: expectedMessageTitle, content: expectedMessageContent, sender: sender, receiver: receiver, on: app.db)
        
        let userID = try sender.requireID()
        let path = "\(baseRoute)/\(userID)/messages/sent"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let messages = try res.content.decode([Message].self)
            XCTAssertEqual(messages.count, 1)
            XCTAssertEqual(messages[0].title, expectedMessageTitle)
            XCTAssertEqual(messages[0].content, expectedMessageContent)
        }
    }
    
    func testGetSentMessagesWithoutMessagesSucceedWithEmptyResponse() async throws {
        let sender = try await User.create(username: expectedUsername, on: app.db)
        let receiver = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: sender, on: app.db)
        let _ = try await Message.create(title: expectedMessageTitle, content: expectedMessageContent, sender: sender, receiver: receiver, on: app.db)
        
        let userID = try receiver.requireID()
        let path = "\(baseRoute)/\(userID)/messages/sent"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let messages = try res.content.decode([Message].self)
            XCTAssertEqual(messages.count, 0)
        }
    }
    
    func testGetSentMessagesWithInexistantUserFails() async throws {
        let falseUserID = UUID()
        
        let path = "\(baseRoute)/\(falseUserID)/messages/sent"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testGetSentMessagesWithIncorrectIDFails() async throws {
        let sender = try await User.create(username: expectedUsername, on: app.db)
        let receiver = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let _ = try await Message.create(title: expectedMessageTitle, content: expectedMessageContent, sender: sender, receiver: receiver, on: app.db)
        
        let path = "\(baseRoute)/1/messages/sent"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectUserID"))
        }
    }
}

// MARK: - Get User Login Output
extension UserControllerTests {
    func testGetUserLoginOutputSucceed() async throws {
        let user = try await User.create(username: expectedUsername, email: expectedEmail, on: app.db)
        let usernameInput = User.UsernameInput(username: expectedUsername)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/userLoginTry"
        try app.test(.POST, path) { req in
            try req.content.encode(usernameInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let loginOutput = try res.content.decode(User.LoginTryOutput.self)
            XCTAssertEqual(loginOutput.email, expectedEmail)
            XCTAssertEqual(loginOutput.id, userID)
        }
    }
    
    func testGetUserLoginOutputWithInexistantUserFails() async throws {
        let usernameInput = User.UsernameInput(username: expectedUsername)
        
        let path = "\(baseRoute)/userLoginTry"
        try app.test(.POST, path) { req in
            try req.content.encode(usernameInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}
