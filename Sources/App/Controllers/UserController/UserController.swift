//
//  UserController.swift
//
//
//  Created by Raphaël Payet on 07/02/2024.
//


import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let users = routes.grouped("api", "users")
        users.post("noToken", use: createWithoutToken)
        users.put(":userID", "block", "connection", use: blockUserConnection)
        users.post("userLoginTry", use: getUserLoginTryOutput)
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = users.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        tokenAuthGroup.post(":userID", "technicalDocumentationTabs", ":tabID", use: addTechnicalDocTab)
        tokenAuthGroup.post(":userID", "verifyPassword", use: verifyPassword)
        tokenAuthGroup.post("byMail", use: getUserByMail)
        tokenAuthGroup.post(":userID", "folders", "records", use: getRecordsFolders)
        // Read
        tokenAuthGroup.get(use: getAll)
        tokenAuthGroup.get("clients", use: getAllClients)
        tokenAuthGroup.get("admins", use: getAdmins)
        tokenAuthGroup.get(":userID", use: getUser)
        tokenAuthGroup.get(":userID", "modules", use: getModules)
        tokenAuthGroup.get(":userID", "technicalDocumentationTabs", use: getTechnicalDocumentationTabs)
        tokenAuthGroup.get(":userID", "manager", use: getManager)
        tokenAuthGroup.get(":userID", "employees", use: getEmployees)
        tokenAuthGroup.get(":userID", "token", use: getToken)
        tokenAuthGroup.get(":userID", "resetToken", use: getResetTokensForClient)
        tokenAuthGroup.get(":userID", "messages", "all", use: getUserMessages)
        tokenAuthGroup.get(":userID", "messages", "received", use: getReceivedMessages)
        tokenAuthGroup.get(":userID", "messages", "sent", use: getSentMessages)
        tokenAuthGroup.get(":userID", "folders", "systemQuality", use: getSystemQualityFolders)
        // Update
        tokenAuthGroup.put(":userID", "setFirstConnectionToFalse", use: setUserFirstConnectionToFalse)
        tokenAuthGroup.put(":userID", "changePassword", use: changePassword)
        tokenAuthGroup.put(":userID", "addManager", ":managerID", use: addManager)
        tokenAuthGroup.put(":userID", "block", use: blockUser)
        tokenAuthGroup.put(":userID", "unblock", use: unblockUser)
        tokenAuthGroup.put(":userID", "updateInfos", use: updateUserInfos)
        tokenAuthGroup.put(":userID", "remove", ":employeeID", use: removeEmployee)
        tokenAuthGroup.put(":userID", "modules", use: updateModules)
        tokenAuthGroup.put(":userID", "unblock", "connection", use: unblockUserConnection)
        // Delete
        tokenAuthGroup.delete(":userID", use: remove)
        tokenAuthGroup.delete("all", use: removeAll)
    }
}
