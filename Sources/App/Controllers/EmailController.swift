//
//  EmailController.swift
//
//
//  Created by Raphaël Payet on 02/08/2024.
//

import Fluent
import Vapor
import SendGridKit

struct EmailController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let events = routes.grouped("api", "emails")
        // Token Authentification
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = events.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: sendEmail)
    }
    
    @Sendable
    func sendEmail(req: Request) async throws -> String {
        let input = try req.content.decode(Email.Input.self)
        try EmailMiddleware().validate(tos: input.to, from: input.fromMail)
        
        let from = EmailAddress(email: input.fromMail, name: input.fromName)
        let replyTo: EmailAddress
        if let replyToInput = input.replyTo {
            replyTo = EmailAddress(email: replyToInput)
        } else {
            replyTo = EmailAddress(email: input.fromMail)
        }
        
        let tos = EmailMiddleware().createToArray(tos: input.to)
        let content = EmailContent(type: input.isHTML ? "text/html" : "text/plain",
                                   value: input.content)
        
        let email = createEmail(from: from, tos: tos, subject: input.subject, content: content, replyTo: replyTo)
        try await send(email: email, sendGridApiKey: input.apiKey)
        
        return "success.emailSent"
    }
}

 extension EmailController {
     func createEmail(from: EmailAddress, tos: [EmailAddress], subject: String, content: EmailContent, replyTo: EmailAddress? = nil) -> SendGridEmail {
         let personalization: Personalization = .init(to: tos, subject: subject)
        
         var replyToEmailAddress = replyTo
         if replyToEmailAddress == nil { replyToEmailAddress = from }
         let email = SendGridEmail(personalizations: [personalization], from: from, replyTo: replyToEmailAddress, subject: subject, content: [content])
        
         return email
     }
    
     func send(email: SendGridEmail, sendGridApiKey: String) async throws {
         let httpClient = HTTPClient()
         let sendGridClient = SendGridClient(httpClient: httpClient, apiKey: sendGridApiKey)
        
         do {
             try await sendGridClient.send(email: email)
         } catch {
             try await httpClient.shutdown()
             throw Abort(.internalServerError, reason: error.localizedDescription)
         }
        
         try await httpClient.shutdown()
     }
 }
