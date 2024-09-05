//
//  CorsMiddleware.swift
//
//
//  Created by Raphaël Payet on 03/06/2024.
//

import Vapor

let corsConfig = CORSMiddleware.Configuration(
    allowedOrigin: .all,
    allowedMethods: [.GET, .POST, .PUT, .DELETE],
    allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
)

let cors = CORSMiddleware(configuration: corsConfig)
