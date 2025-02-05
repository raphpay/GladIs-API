//
//  DocumentMiddleware.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 05/02/2025.
//

import Fluent
import Vapor

struct DocumentMiddleware {
    func validate(_ input: Document.PathInput,
                  for document: Document,
                  on database: Database) async throws -> String {
        guard !input.path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Abort(.badRequest, reason: "badRequest.emptyPath")
        }
        
        // 5. Check if the new path is different from the current path
        if document.path == input.path {
            throw Abort(.badRequest, reason: "badRequest.pathAlreadyExists")
        }
        
        var inputPath = input.path
        if !inputPath.hasSuffix("/") {
            inputPath += "/"
        }
        
        return inputPath
    }
}
