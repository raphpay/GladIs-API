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
    try app.register(collection: TokenController())
    try app.register(collection: PendingUserController())
    try app.register(collection: DocumentController())
    try app.register(collection: TechnicalDocumentationTabController())
    try app.register(collection: DocumentActivityLogController())
    try app.register(collection: PotentialEmployeeController())
    try app.register(collection: EventController())
    try app.register(collection: PasswordResetTokenController())
    try app.register(collection: MessageController())
    try app.register(collection: SurveyController())
    try app.register(collection: FormController())
    try app.register(collection: FolderController())
    try app.register(collection: EmailController())
}
