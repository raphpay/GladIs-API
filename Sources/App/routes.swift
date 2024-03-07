import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: UserController())
    try app.register(collection: AdminUserController())
    try app.register(collection: ModuleController())
    try app.register(collection: TokenController())
    try app.register(collection: PendingUserController())
    try app.register(collection: DocumentController())
    try app.register(collection: TechnicalDocumentationTabController())
    try app.register(collection: DocumentActivityLogController())
    try app.register(collection: PotentialEmployeeController())
}
