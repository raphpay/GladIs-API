//
//  CorsMiddleware.swift
//
//
//  Created by Raphaël Payet on 03/06/2024.
//

import Vapor

let corsConfig = CORSMiddleware.Configuration(
    allowedOrigin: .all,
    allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS, .PATCH], // Include OPTIONS for preflight requests
    allowedHeaders: [
        .accept,
        .authorization,
        .contentType,
        .origin,
        .xRequestedWith,
        .userAgent,
        .accessControlAllowOrigin,
        "Access-Control-Allow-Origin",
        "Authorization",
        "Content-Type"
    ]
)

let cors = CORSMiddleware(configuration: corsConfig)
