# GladIs Server

GladIs-API is a server-side application built with Vapor.

/!\ This README is still under construction /!\

## Installation

1. Make sure you have Swift and Vapor installed on your machine.
2. Clone this repository.
3. Navigate to the project directory in your terminal.
4. Run `vapor build` to build the project.
5. Run `vapor run` to start the server.

## Configuration

The server configuration can be found in the `Config` directory. You can modify settings such as port number, database configuration, and logging options in the `app.json` file.

## Project Structure

- **Sources:** Contains the Swift source code for the project.
- **Public:** Contains static files such as images, CSS, and JavaScript files.
- **Resources:** Contains any additional resources needed for the project, such as HTML templates.
- **Tests:** Contains unit tests for the project.

## Endpoints

The server provides various endpoints for handling different types of requests. Here are some of the main endpoints:

- `/api/documents`: Handles requests related to managing documents.
- `/api/users`: Handles requests related to user authentication and management.
- `/api/admin`: Handles requests for administrative tasks.

For detailed information about each endpoint, refer to the source code in the `Sources/App` directory.

## Dependencies

The project uses various dependencies managed by Swift Package Manager. You can find the list of dependencies in the `Package.swift` file.

## Contributing

If you'd like to contribute to this project, please fork the repository and create a pull request with your changes. Make sure to follow the project's coding conventions and guidelines.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more information.

## Contact

If you have any questions or suggestions regarding this project, feel free to contact us at [raphaelpayet@twinpaw.fr](mailto:raphaelpayet@twinpaw.fr).

