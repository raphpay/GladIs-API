# GladIs Server

GladIs-API is a server-side application built using [Vapor](https://vapor.codes/), a web framework for Swift. This application provides API endpoints for document management, user authentication, and administrative tasks, among other features.

> **Note:** This README is still a work in progress.

## Installation

### Prerequisites
- **Swift**: Ensure that Swift 5.5 or higher is installed.
- **Vapor**: Install Vapor using the following command:
  ```bash
  brew install vapor/tap/vapor
  ```

### Steps
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-repository/GladIs.git
   cd GladIs
   ```
2. **Install Dependencies**:
   Run the following command to fetch and resolve all dependencies using Swift Package Manager:
   ```bash
   swift update
   ```

3. **Build the Project**:
   ```bash
   swift build
   ```

4. **Run the Server**:
   ```bash
   swift run
   ```
   The server will be available at `http://localhost:8080` by default.

## Configuration

### Environment Variables
Configuration can be handled via environment variables for flexibility in different environments (development, testing, production).

- **Database Configuration**: Modify the `.env` file or use environment variables for database credentials (`DATABASE_URL`, `MONGO_URI`, etc.).
- **API Keys & Secrets**: Store sensitive keys and tokens in environment variables.
  
### Custom Configuration Files
Some additional settings, such as port numbers, logging options, and external API configurations, can be found and adjusted in the `Config` directory (`app.json`, `.env`).

## Project Structure

- **`Sources/`**: Main source code, including controllers, models, routes, and services.
- **`Public/`**: Static files (if needed), such as images, CSS, and JavaScript.
- **`Resources/`**: Any additional resources such as HTML templates or localization files.
- **`Tests/`**: Contains unit and integration tests to ensure the reliability of the project.

### Authentication
The API uses JWT (JSON Web Tokens) for secure authentication. Include the token in the `Authorization` header as a Bearer token.

For full documentation on each endpoint and its parameters, refer to the respective controllers inside the `Sources/App/Controllers` directory.

## Database Configuration

GladIs supports **MongoDB** for data storage. You can configure the database connection through environment variables or in the `app.json` file:
- **MongoDB URI**: The connection string should be set via the `MONGO_URI` environment variable.

Example `.env` configuration:
```bash
MONGO_URI=mongodb://localhost:27017/gladis-db
```

## Deployment

To deploy the application using Docker, follow these steps:

1. **Pull the latest changes** from the GitHub repository:
   ```bash
   git pull origin main
   ```

2. **Build and run the Docker container**:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

3. **Apply database migrations** (if necessary):
   ```bash
   swift run App migrate
   ```

## Dependencies

The `GladIs` project uses several dependencies managed through the Swift Package Manager. You can find these listed in the `Package.swift` file.

Some key dependencies include:
- **Vapor**: Web framework.
- **MongoKitten**: MongoDB driver for Vapor.
- **JWT**: For handling JSON Web Tokens.

To update dependencies, run:
```bash
vapor update
```

## Testing

Unit and integration tests are located in the `Tests` directory. To run the tests, execute:
```bash
swift test
```

## License

This project is licensed under the MIT License. See the `LICENSE` file for full details.

## Contact

If you have any questions or suggestions, feel free to reach out:
- **Email**: [raphaelpayet@twinpaw.fr](mailto:raphaelpayet@twinpaw.fr)