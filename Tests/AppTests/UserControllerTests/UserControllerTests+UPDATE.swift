//
//  UserControllerTests+UPDATE.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Set User Connection To False
extension UserControllerTests {
    func testSetUserConnectionToFalseSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/setFirstConnectionToFalse"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(updatedUser.firstConnection, false)
            XCTAssertEqual(updatedUser.id?.uuidString, userID.uuidString)
        }
    }
    
    func testSetUserConnectionToFalseWithInexistantUserFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let path = "\(baseRoute)/12345/setFirstConnectionToFalse"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Change Password
extension UserControllerTests {
    func testChangePasswordSucceed() async throws {
        let user = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let changeRequest = PasswordChangeRequest(currentPassword: expectedPassword, newPassword: expectedPassword + "hello")
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/changePassword"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(changeRequest)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let changeResponse = try res.content.decode(PasswordChangeResponse.self)
            XCTAssertEqual(changeResponse.message, "success.passwordChanged")
        }
    }
    
    func testChangePasswordWithDifferentUserFails() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let user = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        let changeRequest = PasswordChangeRequest(currentPassword: expectedPassword, newPassword: expectedPassword + "hello")
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/changePassword"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(changeRequest)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.wrongUser"))
        }
    }
    
    func testChangePasswordWithInvalidCurrentFails() async throws {
        let user = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let changeRequest = PasswordChangeRequest(currentPassword: "hello", newPassword: expectedPassword + "hello")
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/changePassword"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(changeRequest)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.password.invalidCurrent"))
        }
    }
}

// MARK: - Add Manager
extension UserControllerTests {
    func testAddManagerSucceed() async throws {
        let manager = try await User.create(username: expectedUsername, on: app.db)
        let employeeUsername = "employeeUsername"
        let employee = try await User.create(username: employeeUsername, on: app.db)
        let token = try await Token.create(for: manager, on: app.db)
        
        let employeeID = try employee.requireID()
        let managerID = try manager.requireID()
        let path = "\(baseRoute)/\(employeeID)/addManager/\(managerID)"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedEmployee = try res.content.decode(User.Public.self)
            XCTAssertEqual(updatedEmployee.id?.uuidString, employeeID.uuidString)
            XCTAssertEqual(updatedEmployee.managerID, managerID.uuidString)
        }
    }
    
    func testAddManagerWithWrongManagerFails() async throws {
        let manager = try await User.create(username: expectedUsername, on: app.db)
        let employeeUsername = "employeeUsername"
        let employee = try await User.create(username: employeeUsername, on: app.db)
        let token = try await Token.create(for: manager, on: app.db)
        
        let employeeID = try employee.requireID()
        let path = "\(baseRoute)/\(employeeID)/addManager/12345"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testAddManagerToWrongEmployeeFails() async throws {
        let manager = try await User.create(username: expectedUsername, on: app.db)
        let employeeUsername = "employeeUsername"
        let token = try await Token.create(for: manager, on: app.db)
        
        let managerID = try manager.requireID()
        let path = "\(baseRoute)/12345/addManager/\(managerID)"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testAddManagerWithAlreadyExistantManagerFails() async throws {
        let manager = try await User.create(username: expectedUsername, on: app.db)
        let employeeUsername = "employeeUsername"
        let employee = try await User.create(username: employeeUsername, on: app.db)
        let token = try await Token.create(for: manager, on: app.db)
        
        let employeeID = try employee.requireID()
        let managerID = try manager.requireID()
        
        employee.managerID = managerID.uuidString
        manager.employeesIDs = [employeeID.uuidString]
        try await employee.update(on: app.db)
        try await manager.update(on: app.db)
        
        let path = "\(baseRoute)/\(employeeID)/addManager/\(managerID)"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.managerAlreadySet"))
        }
    }
}

// MARK: - Block User
extension UserControllerTests {
    func testBlockUserSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/block"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(updatedUser.id?.uuidString, userID.uuidString)
            XCTAssertEqual(updatedUser.isBlocked, true)
        }
    }
    
    func testBlockUserWithWrongUserFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let path = "\(baseRoute)/1234/block"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Unblock User
extension UserControllerTests {
    func testUnblockUserSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        user.isBlocked = true
        try await user.update(on: app.db)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/unblock"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(updatedUser.id?.uuidString, userID.uuidString)
            XCTAssertEqual(updatedUser.isBlocked, false)
        }
    }
    
    func testUnblockUserWithWrongUserFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        user.isBlocked = true
        try await user.update(on: app.db)
        
        let path = "\(baseRoute)/1234/unblock"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Update User Infos
extension UserControllerTests {
    func testUpdateUserInfosSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let newFirstName = "newFirstName"
        let newLastName = "newLastName"
        let newPhoneNumber = "0609876554"
        let newEmail = "newEmail@test.com"
        let input = User.Input(firstName: newFirstName, lastName: newLastName, phoneNumber: newPhoneNumber, email: newEmail, password: nil, userType: .admin, companyName: nil, products: nil, numberOfEmployees: nil, numberOfUsers: nil, salesAmount: nil, employeesIDs: nil, managerID: nil)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/updateInfos"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(updatedUser.id?.uuidString, userID.uuidString)
            XCTAssertEqual(updatedUser.firstName, newFirstName)
            XCTAssertEqual(updatedUser.lastName, newLastName)
            XCTAssertEqual(updatedUser.phoneNumber, newPhoneNumber)
            XCTAssertEqual(updatedUser.email, newEmail)
        }
    }
    
    func testUpdateUserWithWrongPhoneNumberFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let newFirstName = "newFirstName"
        let newLastName = "newLastName"
        let newPhoneNumber = "09"
        let newEmail = "newEmail@test.com"
        let input = User.Input(firstName: newFirstName, lastName: newLastName, phoneNumber: newPhoneNumber, email: newEmail, password: nil, userType: .admin, companyName: nil, products: nil, numberOfEmployees: nil, numberOfUsers: nil, salesAmount: nil, employeesIDs: nil, managerID: nil)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/updateInfos"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.phoneNumber.invalid"))
        }
    }
    
    func testUpdateUserWithWrongEmailFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let newFirstName = "newFirstName"
        let newLastName = "newLastName"
        let newPhoneNumber = "0612345678"
        let newEmail = "newEmail"
        let input = User.Input(firstName: newFirstName, lastName: newLastName, phoneNumber: newPhoneNumber, email: newEmail, password: nil, userType: .admin, companyName: nil, products: nil, numberOfEmployees: nil, numberOfUsers: nil, salesAmount: nil, employeesIDs: nil, managerID: nil)
        
        let userID = try user.requireID()
        let path = "\(baseRoute)/\(userID)/updateInfos"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.email.invalid"))
        }
    }
    
    func testUpdateUserInfosWithInexistantUserFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let newFirstName = "newFirstName"
        let newLastName = "newLastName"
        let newPhoneNumber = "0612345678"
        let newEmail = "newEmail@test.com"
        let input = User.Input(firstName: newFirstName, lastName: newLastName, phoneNumber: newPhoneNumber, email: newEmail, password: nil, userType: .admin, companyName: nil, products: nil, numberOfEmployees: nil, numberOfUsers: nil, salesAmount: nil, employeesIDs: nil, managerID: nil)
        
        let path = "\(baseRoute)/12345/updateInfos"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Remove Employee
extension UserControllerTests {
    func testRemoveEmployeeSucceed() async throws {
        let manager = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let employee = try await User.create(username: expectedUsername, userType: .employee, on: app.db)
        let token = try await Token.create(for: manager, on: app.db)
        
        let employeeID = try employee.requireID()
        let managerID = try manager.requireID()
        manager.employeesIDs = [employeeID.uuidString]
        try await manager.update(on: app.db)
        
        let path = "\(baseRoute)/\(managerID)/remove/\(employeeID)"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedManager = try res.content.decode(User.Public.self)
            XCTAssertEqual(updatedManager.id?.uuidString, managerID.uuidString)
            XCTAssertEqual(updatedManager.employeesIDs?.count, 0)
        }
    }
    
    func testRemoveEmployeeWithWrongManagerFails() async throws {
        let manager = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let employee = try await User.create(username: expectedUsername, userType: .employee, on: app.db)
        let token = try await Token.create(for: manager, on: app.db)
        
        let employeeID = try employee.requireID()
        manager.employeesIDs = [employeeID.uuidString]
        try await manager.update(on: app.db)
        
        let path = "\(baseRoute)/12345/remove/\(employeeID)"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Update Modules
extension UserControllerTests {
    func testAddModulesToUserSuceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let userID = try user.requireID()
        let token = try await Token.create(for: user, on: app.db)

        let moduleToAdd = Module(name: expectedModuleName, index: expectedModuleIndex)
        let moduleToAddTwo = Module(name: "\(expectedModuleName)2", index: expectedModuleIndex + 1)
        let modules: [Module] = [moduleToAdd, moduleToAddTwo]
        
        let path = "\(baseRoute)/\(userID)/modules"

        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(modules)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(updatedUser.id?.uuidString, userID.uuidString)
            XCTAssertEqual(updatedUser.modules?.count, 2)
            XCTAssertEqual(updatedUser.modules?[0].name, expectedModuleName)
            XCTAssertEqual(updatedUser.modules?[0].index, expectedModuleIndex)
            XCTAssertEqual(updatedUser.modules?[1].name, "\(expectedModuleName)2")
            XCTAssertEqual(updatedUser.modules?[1].index, expectedModuleIndex + 1)
        }
    }

    func testRemoveModulesToUserSuceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let userID = try user.requireID()
        let token = try await Token.create(for: user, on: app.db)

        let moduleToAdd = Module(name: expectedModuleName, index: expectedModuleIndex)
        let moduleToAddTwo = Module(name: "\(expectedModuleName)2", index: expectedModuleIndex + 1)
        var modules: [Module] = [moduleToAdd, moduleToAddTwo]
        
        let path = "\(baseRoute)/\(userID)/modules"

        // Add Modules
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(modules)
        }

        modules.remove(at: 0)

        // Remove modules and test
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(modules)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(updatedUser.id?.uuidString, userID.uuidString)
            XCTAssertEqual(updatedUser.modules?.count, 1)
            XCTAssertEqual(updatedUser.modules?[0].name, "\(expectedModuleName)2")
            XCTAssertEqual(updatedUser.modules?[0].index, expectedModuleIndex + 1)
        }
    }

    func testAddModulesToUserWithWrongUserFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)

        let moduleToAdd = Module(name: expectedModuleName, index: expectedModuleIndex)
        let moduleToAddTwo = Module(name: "\(expectedModuleName)2", index: expectedModuleIndex + 1)
        let modules: [Module] = [moduleToAdd, moduleToAddTwo]

        let path = "\(baseRoute)/12345/modules"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(modules)
        } afterResponse: { res in 
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }

    func testRemoveModulesToUserWithWrongUserFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let userID = try user.requireID()
        let token = try await Token.create(for: user, on: app.db)

        let moduleToAdd = Module(name: expectedModuleName, index: expectedModuleIndex)
        let moduleToAddTwo = Module(name: "\(expectedModuleName)2", index: expectedModuleIndex + 1)
        var modules: [Module] = [moduleToAdd, moduleToAddTwo]

        var path = "\(baseRoute)/\(userID)/modules"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(modules)
        }

        modules.remove(at: 0)
        path = "\(baseRoute)/1234567/modules"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(modules)
        } afterResponse: { res in 
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Block User Connection
extension UserControllerTests {
    // users.put(":userID", "block", "connection", use: blockUserConnection)
    func testBlockUserConnectionSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let userID = try user.requireID()

        let path = "\(baseRoute)/\(userID)/block/connection"
        try app.test(.PUT, path) { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(updatedUser.id?.uuidString, userID.uuidString)
            XCTAssertEqual(updatedUser.isConnectionBlocked, nil)
            XCTAssertEqual(updatedUser.connectionFailedAttempts, 1)
        }
    }

    func testBlockUserConnectionAndReachLimitSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let userID = try user.requireID()

        let path = "\(baseRoute)/\(userID)/block/connection"
        // 1
        try await app.test(.PUT, path)
        // 2
        try await app.test(.PUT, path)
        // 3
        try await app.test(.PUT, path)
        // 4
        try await app.test(.PUT, path)
        // 5
        try app.test(.PUT, path) { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(updatedUser.id?.uuidString, userID.uuidString)
            XCTAssertEqual(updatedUser.isConnectionBlocked, true)
            XCTAssertEqual(updatedUser.connectionFailedAttempts, 5)
        }
    }

    func testBlockUserConnectionWithWrongUserFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let userID = try user.requireID()

        let path = "\(baseRoute)/12345/block/connection"
        try app.test(.PUT, path) { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK : - Unblock User Connection
extension UserControllerTests {
    func testUnblockUserConnectionSucceed() async throws {
        let admin = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        let client = try await User.create(username: expectedClientUsername, userType: .client, on: app.db)
        let clientID = try client.requireID()
        client.isConnectionBlocked = true
        try await client.update(on: app.db)

        let path = "\(baseRoute)/\(clientID)/unblock/connection"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(updatedUser.id, clientID)
            XCTAssertEqual(updatedUser.isConnectionBlocked, false)
            XCTAssertEqual(updatedUser.connectionFailedAttempts, 0)
        }
    }

    func testUnblockUserConnectionWithoutAdminPermissionFails() async throws {
        let admin = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        let client = try await User.create(username: expectedClientUsername, userType: .client, on: app.db)
        let clientID = try client.requireID()
        client.isConnectionBlocked = true
        try await client.update(on: app.db)

        let path = "\(baseRoute)/\(clientID)/unblock/connection"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        }
    }

    func testUnblockUserConnectionWithWrongUserFails() async throws {
        let admin = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)

        let path = "\(baseRoute)/12345/unblock/connection"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}
