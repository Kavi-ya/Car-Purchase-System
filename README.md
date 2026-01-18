# Car Purchase System

A web-based application for managing car purchase operations.

## Overview
This system provides functionality for managing users and car listings. It uses a Java-based backend with JSP/Servlet for the web interface.

## Project Structure
- `src/main/java`: Java source code (Controllers, Models, Services)
- `src/main/webapp`: Web application resources (JSP files, CSS, Images)

## Configuration
**Important**: The application uses file-based storage. 
Please check `com.carpurchase.service.UserService` and ensure the `DATA_DIR` constant points to a valid directory on your system:
```java
private static final String DATA_DIR = "PATH_TO_YOUR_DATA_DIRECTORY";
```

## Features
- User Registration and Authentication
- Car Listings Management
- User Administration
