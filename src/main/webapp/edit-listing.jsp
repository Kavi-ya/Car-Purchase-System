<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="com.carpurchase.model.Car" %>
<%@ page import="com.carpurchase.model.CarListManager" %>

<%
    // Check if user is logged in as seller
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");
    String userRole = (String) session.getAttribute("userRole");
    String userId = (String) session.getAttribute("userId");
    
    if (username == null || !userRole.equalsIgnoreCase("seller")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Path to car_list.txt file
    String dataDir = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data";
    String carListFile = "car_list.txt";
    File file = new File(dataDir, carListFile);
    String message = "";
    boolean success = false;
    
    // Check if car ID is provided
    String carId = request.getParameter("id");
    if (carId == null || carId.trim().isEmpty()) {
        response.sendRedirect("my-listing.jsp");
        return;
    }
    
    // Get current file content - useful for debugging
    String currentContent = "";
    try {
        currentContent = new String(Files.readAllBytes(file.toPath()));
    } catch (Exception e) {
        currentContent = "Error reading file: " + e.getMessage();
    }
    
    // Auto-fix the file if it has metadata at the top (this happens automatically)
    if (currentContent.startsWith("Current Date") || currentContent.startsWith("Current User")) {
        try {
            // Create a fixed content without metadata
            StringBuilder fixedContent = new StringBuilder();
            
            boolean inCarRecord = false;
            boolean firstRecord = true;
            
            try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
                String line;
                
                while ((line = reader.readLine()) != null) {
                    // Look for the start of car records
                    if (line.contains("==== CAR LISTING RECORD ====")) {
                        if (firstRecord) {
                            firstRecord = false;
                        } else {
                            fixedContent.append("\n"); // Add empty line between records
                        }
                        
                        inCarRecord = true;
                        fixedContent.append("==== CAR LISTING RECORD ====\n");
                        continue;
                    }
                    
                    if (inCarRecord) {
                        fixedContent.append(line).append("\n");
                    }
                    // Skip lines not in a car record (e.g., metadata at the top)
                }
            }
            
            // Write the fixed content back to file
            try (FileWriter writer = new FileWriter(file)) {
                writer.write(fixedContent.toString());
            }
            
            success = true;
            message = "File has been auto-fixed to remove metadata.";
            
            // Update current content after fix
            currentContent = new String(Files.readAllBytes(file.toPath()));
            
        } catch (Exception e) {
            message = "Error fixing file: " + e.getMessage();
        }
    }
    
    // Extract car data for editing
    Map<String, String> carFields = new HashMap<>();
    
    try {
        boolean inTargetCar = false;
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (inTargetCar) {
                    if (line.equals("-----------------------------")) {
                        break; // End of this car record
                    } else if (line.contains(": ")) {
                        String[] parts = line.split(": ", 2);
                        if (parts.length == 2) {
                            carFields.put(parts[0], parts[1]);
                        }
                    }
                } else if (line.contains("Listing ID: " + carId)) {
                    inTargetCar = true;
                    carFields.put("Listing ID", carId);
                }
            }
        }
        
        if (carFields.isEmpty()) {
            message = "Car with ID " + carId + " was not found.";
        }
    } catch (Exception e) {
        message = "Error reading car data: " + e.getMessage();
    }
    
    // Also load car using CarListManager for compatibility
    Car car = null;
    try {
        CarListManager carManager = new CarListManager();
        car = carManager.getCarById(carId);
        
        // Check if car belongs to current user
        if (car != null && !car.getSellerId().equals(userId)) {
            response.sendRedirect("my-listing.jsp");
            return;
        }
    } catch (Exception e) {
        // Just continue, as we'll use the map data
    }

    // Process form submission for car update
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            // Get form parameters
            Map<String, String[]> params = request.getParameterMap();
            
            // Read all lines of the file
            List<String> lines = new ArrayList<>();
            try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    // Skip any metadata at the beginning
                    if (lines.isEmpty() && (line.startsWith("Current Date") || line.startsWith("Current User"))) {
                        continue;
                    }
                    lines.add(line);
                }
            }
            
            // Find the car record and update it
            int i = 0;
            boolean inTargetCar = false;
            List<String> updatedLines = new ArrayList<>();
            
            while (i < lines.size()) {
                String line = lines.get(i);
                
                if (line.equals("==== CAR LISTING RECORD ====")) {
                    updatedLines.add(line);
                    inTargetCar = false;
                    i++;
                    
                    // Check next line for car ID
                    if (i < lines.size()) {
                        String idLine = lines.get(i);
                        if (idLine.contains("Listing ID: " + carId)) {
                            inTargetCar = true;
                        }
                        updatedLines.add(idLine);
                        i++;
                    }
                    continue;
                }
                
                if (inTargetCar) {
                    // This is a line in the car record we want to update
                    if (line.equals("-----------------------------")) {
                        inTargetCar = false;
                        updatedLines.add(line);
                    } else {
                        // Parse the line
                        String fieldName = "";
                        if (line.contains(": ")) {
                            fieldName = line.substring(0, line.indexOf(": ")).trim();
                        }
                        
                        // Direct-car-manager.jsp style field updates
                        if (!fieldName.isEmpty() && params.containsKey(fieldName.toLowerCase().replace(" ", "_"))) {
                            String paramName = fieldName.toLowerCase().replace(" ", "_");
                            String value = params.get(paramName)[0];
                            
                            // Special case for features which might be multi-valued
                            if (fieldName.equals("Features") && params.get("features") != null) {
                                String[] featureValues = params.get("features");
                                value = String.join(", ", featureValues);
                            }
                            
                            updatedLines.add(fieldName + ": " + value);
                        } else {
                            // For fields not being updated
                            updatedLines.add(line);
                        }
                    }
                } else {
                    // Not in the target car record
                    updatedLines.add(line);
                }
                
                i++;
            }
            
            // Write the updated lines back to file
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
                for (String line : updatedLines) {
                    writer.write(line);
                    writer.newLine();
                }
            }
            
            success = true;
            message = "Car listing updated successfully!";
            
            // Update current content after update
            currentContent = new String(Files.readAllBytes(file.toPath()));
            
            // Refresh car fields after update
            carFields.clear();
            boolean refreshTargetCar = false;
            try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (refreshTargetCar) {
                        if (line.equals("-----------------------------")) {
                            break; // End of this car record
                        } else if (line.contains(": ")) {
                            String[] parts = line.split(": ", 2);
                            if (parts.length == 2) {
                                carFields.put(parts[0], parts[1]);
                            }
                        }
                    } else if (line.contains("Listing ID: " + carId)) {
                        refreshTargetCar = true;
                        carFields.put("Listing ID", carId);
                    }
                }
            }
        } catch (Exception e) {
            message = "Error updating car: " + e.getMessage();
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Listing - CarTrader</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #3a86ff;
            --secondary-color: #ff006e;
            --success-color: #38b000;
            --warning-color: #ffbe0b;
            --danger-color: #d90429;
            --light-color: #f8f9fa;
            --dark-color: #212529;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
        }
        
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: 280px;
            background-color: var(--dark-color);
            color: white;
            padding-top: 20px;
            transition: all 0.3s;
            z-index: 1000;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }
        
        .sidebar-header {
            padding: 20px 25px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        
        .sidebar-header .logo {
            font-size: 1.8rem;
            font-weight: bold;
            color: white;
            text-decoration: none;
            display: flex;
            align-items: center;
        }
        
        .nav-item {
            margin-bottom: 5px;
        }
        
        .nav-link {
            padding: 12px 25px;
            color: rgba(255,255,255,0.8);
            font-weight: 500;
            border-radius: 0;
            display: flex;
            align-items: center;
            transition: all 0.3s;
        }
        
        .nav-link:hover, .nav-link.active {
            background-color: rgba(255,255,255,0.1);
            color: white;
        }
        
        .nav-link i {
            margin-right: 10px;
            width: 20px;
            text-align: center;
        }
        
        .content {
            margin-left: 280px;
            padding: 20px;
            transition: all 0.3s;
        }
        
        .toggle-sidebar {
            position: fixed;
            top: 20px;
            left: 20px;
            z-index: 1001;
            display: none;
        }
        
        .sidebar-bottom {
            position: absolute;
            bottom: 0;
            width: 100%;
            padding: 20px 25px;
            border-top: 1px solid rgba(255,255,255,0.1);
        }
        
        .user-menu {
            display: flex;
            align-items: center;
            color: white;
            text-decoration: none;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            margin-right: 10px;
        }
        
        .dropdown-toggle::after {
            display: none;
        }
        
        .card {
            border: none;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-radius: 10px;
        }
        
        .form-section {
            margin-bottom: 2rem;
        }
        
        .form-section-title {
            font-weight: 600;
            font-size: 1.1rem;
            padding-bottom: 0.5rem;
            margin-bottom: 1.5rem;
            border-bottom: 1px solid #e9ecef;
        }
        
        .form-label {
            font-weight: 500;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .btn-primary:hover {
            background-color: #0056b3;
            border-color: #0056b3;
        }
        
        .btn-danger {
            background-color: var(--danger-color);
            border-color: var(--danger-color);
        }
        
        .btn-danger:hover {
            background-color: #ba0021;
            border-color: #ba0021;
        }
        
        .form-check-label {
            cursor: pointer;
        }
        
        .form-check-input:checked {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .image-preview {
            width: 100%;
            height: 180px;
            border: 2px dashed #dee2e6;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
            cursor: pointer;
        }
        
        .image-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .image-preview-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s;
        }
        
        .image-preview:hover .image-preview-overlay {
            opacity: 1;
        }
        
        .file-input {
            display: none;
        }
        
        pre {
            background-color: #f5f5f5;
            padding: 15px;
            border-radius: 4px;
            overflow-x: auto;
            font-size: 14px;
        }
        
        @media (max-width: 992px) {
            .sidebar {
                transform: translateX(-280px);
            }
            
            .content {
                margin-left: 0;
            }
            
            .sidebar.show {
                transform: translateX(0);
            }
            
            .toggle-sidebar {
                display: block;
            }
            
            .content.pushed {
                margin-left: 280px;
            }
        }
    </style>
</head>
<body>
    <button class="btn btn-light toggle-sidebar" id="toggleSidebar">
        <i class="fas fa-bars"></i>
    </button>
    
    <!-- Sidebar -->
    <div class="sidebar">
        <div class="sidebar-header">
            <a href="index.jsp" class="logo">
                <i class="fas fa-car-side me-2"></i> CarTrader
            </a>
        </div>
        
        <ul class="nav flex-column mt-4">
            <li class="nav-item">
                <a class="nav-link" href="seller-dashboard.jsp">
                    <i class="fas fa-tachometer-alt"></i> Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="my-listing.jsp">
                    <i class="fas fa-list"></i> My Listings
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="add-listing.jsp">
                    <i class="fas fa-plus-circle"></i> Add New Listing
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="inquiries.jsp">
                    <i class="fas fa-envelope"></i> Inquiries
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="#">
                    <i class="fas fa-cog"></i> Settings
                </a>
            </li>
        </ul>
        
        <div class="sidebar-bottom">
            <div class="dropdown">
                <a href="#" class="user-menu dropdown-toggle" data-bs-toggle="dropdown">
                    <div class="user-avatar">
                        <%= fullName.substring(0, 1).toUpperCase() %>
                    </div>
                    <div>
                        <div class="fw-bold"><%= fullName %></div>
                        <small class="text-muted"><%= username %></small>
                    </div>
                </a>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="#"><i class="fas fa-user"></i> My Profile</a></li>
                    <li><a class="dropdown-item" href="#"><i class="fas fa-cog"></i> Account Settings</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                </ul>
            </div>
        </div>
    </div>
    
    <!-- Content -->
    <div class="content">
        <div class="container-fluid">
            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>Edit Listing</h2>
                <div>
                    <a href="my-listing.jsp" class="btn btn-outline-secondary">
                        <i class="fas fa-chevron-left me-2"></i> Back to My Listings
                    </a>
                </div>
            </div>
            
            <!-- Status Messages -->
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= success ? "success" : "danger" %> alert-dismissible fade show" role="alert">
                    <i class="fas fa-<%= success ? "check" : "exclamation" %>-circle me-2"></i> <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            
            <!-- Edit Form -->
            <form action="edit-listing.jsp?id=<%= carId %>" method="post" id="editForm">
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="form-section">
                            <div class="form-section-title">Basic Information</div>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Title</label>
                                    <input type="text" class="form-control" id="title" name="title" value="<%= carFields.getOrDefault("Title", "") %>" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Status</label>
                                    <select class="form-select" id="status" name="status">
                                        <option value="Active" <%= "Active".equals(carFields.get("Status")) ? "selected" : "" %>>Active</option>
                                        <option value="Pending" <%= "Pending".equals(carFields.get("Status")) ? "selected" : "" %>>Pending</option>
                                        <option value="Sold" <%= "Sold".equals(carFields.get("Status")) ? "selected" : "" %>>Sold</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <label class="form-label">Make</label>
                                    <input type="text" class="form-control" id="make" name="make" value="<%= carFields.getOrDefault("Make", "") %>" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Model</label>
                                    <input type="text" class="form-control" id="model" name="model" value="<%= carFields.getOrDefault("Model", "") %>" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Year</label>
                                    <input type="number" class="form-control" id="year" name="year" value="<%= carFields.getOrDefault("Year", "") %>" required>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <label class="form-label">Body Type</label>
                                    <input type="text" class="form-control" id="body_type" name="body_type" value="<%= carFields.getOrDefault("Body Type", "") %>" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Condition</label>
                                    <input type="text" class="form-control" id="condition" name="condition" value="<%= carFields.getOrDefault("Condition", "") %>" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Price</label>
                                    <input type="number" class="form-control" id="price" name="price" value="<%= carFields.getOrDefault("Price", "") %>" step="0.01" required>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-section">
                            <div class="form-section-title">Technical Details</div>
                            
                            <div class="row mb-3">
                                <div class="col-md-12">
                                    <label class="form-label">Description</label>
                                    <textarea class="form-control" id="description" name="description" rows="3" required><%= carFields.getOrDefault("Description", "") %></textarea>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <label class="form-label">Mileage</label>
                                    <input type="number" class="form-control" id="mileage" name="mileage" value="<%= carFields.getOrDefault("Mileage", "") %>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">VIN</label>
                                    <input type="text" class="form-control" id="vin" name="vin" value="<%= carFields.getOrDefault("VIN", "") %>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Transmission</label>
                                    <select class="form-select" id="transmission" name="transmission">
                                        <option value="Automatic" <%= "Automatic".equals(carFields.get("Transmission")) ? "selected" : "" %>>Automatic</option>
                                        <option value="Manual" <%= "Manual".equals(carFields.get("Transmission")) ? "selected" : "" %>>Manual</option>
                                        <option value="CVT" <%= "CVT".equals(carFields.get("Transmission")) ? "selected" : "" %>>CVT</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <label class="form-label">Exterior Color</label>
                                    <input type="text" class="form-control" id="exterior_color" name="exterior_color" value="<%= carFields.getOrDefault("Exterior Color", "") %>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Interior Color</label>
                                    <input type="text" class="form-control" id="interior_color" name="interior_color" value="<%= carFields.getOrDefault("Interior Color", "") %>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Fuel Type</label>
                                    <select class="form-select" id="fuel_type" name="fuel_type">
                                        <option value="Gasoline" <%= "Gasoline".equals(carFields.get("Fuel Type")) ? "selected" : "" %>>Gasoline</option>
                                        <option value="Diesel" <%= "Diesel".equals(carFields.get("Fuel Type")) ? "selected" : "" %>>Diesel</option>
                                        <option value="Electric" <%= "Electric".equals(carFields.get("Fuel Type")) ? "selected" : "" %>>Electric</option>
                                        <option value="Hybrid" <%= "Hybrid".equals(carFields.get("Fuel Type")) ? "selected" : "" %>>Hybrid</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <label class="form-label">Engine</label>
                                    <input type="text" class="form-control" id="engine" name="engine" value="<%= carFields.getOrDefault("Engine", "") %>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Drive Type</label>
                                    <select class="form-select" id="drive_type" name="drive_type">
                                        <option value="FWD" <%= "FWD".equals(carFields.get("Drive Type")) ? "selected" : "" %>>FWD</option>
                                        <option value="RWD" <%= "RWD".equals(carFields.get("Drive Type")) ? "selected" : "" %>>RWD</option>
                                        <option value="AWD" <%= "AWD".equals(carFields.get("Drive Type")) ? "selected" : "" %>>AWD</option>
                                        <option value="4WD" <%= "4WD".equals(carFields.get("Drive Type")) ? "selected" : "" %>>4WD</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Doors</label>
                                    <select class="form-select" id="doors" name="doors">
                                        <option value="2" <%= "2".equals(carFields.get("Doors")) ? "selected" : "" %>>2 doors</option>
                                        <option value="3" <%= "3".equals(carFields.get("Doors")) ? "selected" : "" %>>3 doors</option>
                                        <option value="4" <%= "4".equals(carFields.get("Doors")) ? "selected" : "" %>>4 doors</option>
                                        <option value="5" <%= "5".equals(carFields.get("Doors")) ? "selected" : "" %>>5 doors</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <% 
                        // Parse features from carFields
                        String featuresString = carFields.getOrDefault("Features", "");
                        List<String> carFeaturesList = new ArrayList<>();
                        if (!featuresString.isEmpty()) {
                            String[] featureParts = featuresString.split(", ");
                            for (String feature : featureParts) {
                                carFeaturesList.add(feature.trim());
                            }
                        }
                        
                        // Common car features
                        String[] allFeatures = {
                            "Air Conditioning", "Power Steering", "Power Windows", "Power Door Locks", 
                            "Cruise Control", "Navigation System", "Bluetooth", "Heated Seats", 
                            "Leather Seats", "Sunroof/Moonroof", "Backup Camera", "Parking Sensors",
                            "Blind Spot Monitoring", "Lane Departure Warning", "Forward Collision Warning",
                            "Keyless Entry", "Push Button Start", "Remote Start", "Third Row Seating"
                        };
                        %>
                        
                        <div class="form-section">
                            <div class="form-section-title">Features</div>
                            
                            <div class="row mb-3">
                                <div class="col-md-12">
                                    <label class="form-label d-block mb-3">Select All That Apply</label>
                                    
                                    <div class="row">
                                        <% for (String feature : allFeatures) {
                                            boolean isChecked = carFeaturesList.contains(feature);
                                        %>
                                            <div class="col-md-4 mb-2">
                                                <div class="form-check">
                                                    <input class="form-check-input" type="checkbox" value="<%= feature %>" 
                                                           id="feature<%= feature.replaceAll("\\s+", "") %>" name="features"
                                                           <%= isChecked ? "checked" : "" %>>
                                                    <label class="form-check-label" for="feature<%= feature.replaceAll("\\s+", "") %>">
                                                        <%= feature %>
                                                    </label>
                                                </div>
                                            </div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-section">
                            <div class="form-section-title">Seller Information</div>
                            
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <label class="form-label">Contact Name</label>
                                    <input type="text" class="form-control" id="contact_name" name="contact_name" value="<%= carFields.getOrDefault("Contact Name", "") %>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Contact Email</label>
                                    <input type="email" class="form-control" id="contact_email" name="contact_email" value="<%= carFields.getOrDefault("Contact Email", "") %>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Contact Phone</label>
                                    <input type="text" class="form-control" id="contact_phone" name="contact_phone" value="<%= carFields.getOrDefault("Contact Phone", "") %>">
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-12">
                                    <label class="form-label">Location</label>
                                    <input type="text" class="form-control" id="location" name="location" value="<%= carFields.getOrDefault("Location", "") %>">
                                </div>
                            </div>
                        </div>
                        
                        <% if (!carFields.isEmpty()) { %>
                            <div class="row mt-3">
                                <div class="col-12">
                                    <button type="submit" class="btn btn-primary">Save Changes</button>
                                    <a href="my-listing.jsp" class="btn btn-secondary ms-2">Cancel</a>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>
            </form>
            
            <% if (carFields.isEmpty()) { %>
                <div class="alert alert-warning">
                    <p>Car with ID <%= carId %> was not found or could not be loaded.</p>
                    <a href="my-listing.jsp" class="btn btn-sm btn-primary mt-2">Back to My Listings</a>
                </div>
            <% } %>
            
            <!-- Footer -->
            <footer class="mt-4">
                <div class="text-center text-muted">
                    <p>&copy; 2025 CarTrader. All rights reserved.</p>
                </div>
            </footer>
        </div>
    </div>
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Toggle sidebar on mobile
            const toggleSidebarBtn = document.getElementById('toggleSidebar');
            const sidebar = document.querySelector('.sidebar');
            const content = document.querySelector('.content');
            
            toggleSidebarBtn?.addEventListener('click', function() {
                sidebar.classList.toggle('show');
                content.classList.toggle('pushed');
                
                // Change icon based on sidebar state
                const icon = toggleSidebarBtn.querySelector('i');
                if (sidebar.classList.contains('show')) {
                    icon.classList.remove('fa-bars');
                    icon.classList.add('fa-times');
                } else {
                    icon.classList.remove('fa-times');
                    icon.classList.add('fa-bars');
                }
            });
            
            // Format price input with commas as user types
            const priceInput = document.getElementById('price');
            if (priceInput) {
                priceInput.addEventListener('input', function() {
                    // Remove non-numeric characters except decimal point
                    let value = this.value.replace(/[^0-9.]/g, '');
                    
                    // Ensure only one decimal point
                    const decimalPoints = (value.match(/\./g) || []).length;
                    if (decimalPoints > 1) {
                        const parts = value.split('.');
                        value = parts[0] + '.' + parts.slice(1).join('');
                    }
                    
                    this.value = value;
                });
            }
            
            // Format mileage input to only allow numbers
            const mileageInput = document.getElementById('mileage');
            if (mileageInput) {
                mileageInput.addEventListener('input', function() {
                    // Remove non-numeric characters
                    this.value = this.value.replace(/[^0-9]/g, '');
                });
            }
        });
    </script>
</body>
</html>