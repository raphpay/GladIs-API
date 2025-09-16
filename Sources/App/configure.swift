import NIOSSL
import Fluent
import FluentMongoDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(cors, at: .beginning) // From CorsMiddleware.swift
    app.routes.defaultMaxBodySize = "10mb"

    try app.databases.use(DatabaseConfigurationFactory.mongo(
        connectionString: Environment.get("DATABASE_URL") ?? "mongodb://localhost:27017/vapor_database"
    ), as: .mongo)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateToken())
    app.migrations.add(CreatePendingUser())
    app.migrations.add(CreateDocument())
    app.migrations.add(CreateTechnicalDocumentationTab())
    app.migrations.add(CreateUserTabPivot())
    app.migrations.add(CreateDocumentActivityLog())
    app.migrations.add(CreatePotentialEmployee())
    app.migrations.add(CreateEvent())
    app.migrations.add(CreatePasswordResetToken())
    app.migrations.add(CreateMessage())
    app.migrations.add(CreateSurvey())
    app.migrations.add(CreateForm())
    // 05-08-2024
    app.migrations.add(AddFoldersToUser())
    app.migrations.add(CreateFolder())
    // 27-12-2024
    app.migrations.add(AddCategoryToFolder())
    app.migrations.add(MigrateFoldersToRelation())
    app.migrations.add(CreateVersionLog())
    // 05-01-2025
    app.migrations.add(RemoveParameterToVersionLog())
    // 22/01/2025
    app.migrations.add(CreateQuestionnaire())
    app.migrations.add(CreateQuestionnaireRecipient())
	// 10/09/2025
	app.migrations.add(AddStartTimeAndEndTimeToEvent())

    switch app.environment {
        case .development:
            app.databases.middleware.use(UserMiddleware(), on: .mongo)
        default:
            break
    }

    // register routes
    try routes(app)
}
