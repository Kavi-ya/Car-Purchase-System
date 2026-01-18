<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.nio.file.*" %>

<%
    // Path to car_list.txt file
    String dataDir = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data";
    String carListFile = "car_list.txt";
    File file = new File(dataDir, carListFile);
    String message = "";
    boolean success = false;
    boolean isViewMode = true;
    
    // Check for action parameter
    String action = request.getParameter("action");
    if (action != null) {
        isViewMode = !action.equals("fix") && !action.equals("edit") && !action.equals("update");
    }
    
    // Extract car id if present
    String carId = request.getParameter("id");
    
    // Get current file content
    String currentContent = "";
    try {
        currentContent = new String(Files.readAllBytes(file.toPath()));
    } catch (Exception e) {
        currentContent = "Error reading file: " + e.getMessage();
    }
    
    // Process file fix action
    if ("fix".equals(action)) {
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
            message = "File has been fixed.";
            
            // Update current content after fix
            currentContent = new String(Files.readAllBytes(file.toPath()));
            
        } catch (Exception e) {
            message = "Error fixing file: " + e.getMessage();
        }
    }
    
    // Process update action from edit form
    if ("update".equals(action) && carId != null) {
        try {
            // Get form parameters
            Map<String, String[]> params = request.getParameterMap();
            
            // Read all lines of the file
            List<String> lines = new ArrayList<>();
            try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = reader.readLine()) != null) {
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
                        
                        // Check if we have a parameter for this field
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
                            // Keep unchanged
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
            message = "Car with ID " + carId + " has been updated.";
            
            // Update current content after update
            currentContent = new String(Files.readAllBytes(file.toPath()));
            
        } catch (Exception e) {
            message = "Error updating car: " + e.getMessage();
            e.printStackTrace();
        }
    }
    
    // Extract car data for editing
    Map<String, String> carFields = new HashMap<>();
    
    if ("edit".equals(action) && carId != null) {
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
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Direct Car File Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        pre {
            background-color: #f5f5f5;
            padding: 15px;
            border-radius: 4px;
            overflow-x: auto;
            font-size: 14px;
        }
        .action-btn {
            margin-right: 10px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <h1>Direct Car File Manager</h1>
        
        <% if (!message.isEmpty()) { %>
            <div class="alert <%= success ? "alert-success" : "alert-danger" %> mt-3">
                <%= message %>
            </div>
        <% } %>
        
        <div class="mb-4">
            <a href="direct-car-manager.jsp" class="btn btn-primary action-btn">View File</a>
            <a href="direct-car-manager.jsp?action=fix" class="btn btn-warning action-btn">Fix File</a>
            <a href="my-listing.jsp" class="btn btn-secondary action-btn">Back to My Listings</a>
        </div>
        
        <% if ("edit".equals(action) && !carFields.isEmpty()) { %>
            <!-- Edit car form -->
            <div class="card mb-4">
                <div class="card-header">
                    <h3>Edit Car: <%= carFields.getOrDefault("Title", "No Title") %></h3>
                </div>
                <div class="card-body">
                    <form action="direct-car-manager.jsp" method="post">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id" value="<%= carId %>">
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Title</label>
                                <input type="text" class="form-control" name="title" value="<%= carFields.getOrDefault("Title", "") %>">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Status</label>
                                <select class="form-select" name="status">
                                    <option value="Active" <%= "Active".equals(carFields.get("Status")) ? "selected" : "" %>>Active</option>
                                    <option value="Pending" <%= "Pending".equals(carFields.get("Status")) ? "selected" : "" %>>Pending</option>
                                    <option value="Sold" <%= "Sold".equals(carFields.get("Status")) ? "selected" : "" %>>Sold</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label class="form-label">Make</label>
                                <input type="text" class="form-control" name="make" value="<%= carFields.getOrDefault("Make", "") %>">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Model</label>
                                <input type="text" class="form-control" name="model" value="<%= carFields.getOrDefault("Model", "") %>">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Year</label>
                                <input type="number" class="form-control" name="year" value="<%= carFields.getOrDefault("Year", "") %>">
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label class="form-label">Body Type</label>
                                <input type="text" class="form-control" name="body_type" value="<%= carFields.getOrDefault("Body Type", "") %>">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Condition</label>
                                <input type="text" class="form-control" name="condition" value="<%= carFields.getOrDefault("Condition", "") %>">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Price</label>
                                <input type="number" class="form-control" name="price" value="<%= carFields.getOrDefault("Price", "") %>" step="0.01">
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label class="form-label">Description</label>
                                <textarea class="form-control" name="description" rows="3"><%= carFields.getOrDefault("Description", "") %></textarea>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label class="form-label">Contact Name</label>
                                <input type="text" class="form-control" name="contact_name" value="<%= carFields.getOrDefault("Contact Name", "") %>">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Contact Email</label>
                                <input type="email" class="form-control" name="contact_email" value="<%= carFields.getOrDefault("Contact Email", "") %>">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Location</label>
                                <input type="text" class="form-control" name="location" value="<%= carFields.getOrDefault("Location", "") %>">
                            </div>
                        </div>
                        
                        <div class="row mt-4">
                            <div class="col-12">
                                <button type="submit" class="btn btn-primary">Save Changes</button>
                                <a href="direct-car-manager.jsp" class="btn btn-secondary ms-2">Cancel</a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        <% } %>
        
        <% if (isViewMode) { %>
            <h3>Cars in File</h3>
            <div class="mb-3">
                <% 
                    try (BufferedReader reader = new BufferedReader(new StringReader(currentContent))) {
                        String line;
                        boolean inCarRecord = false;
                        String currentCarId = "";
                        String title = "";
                        
                        while ((line = reader.readLine()) != null) {
                            if (line.equals("==== CAR LISTING RECORD ====")) {
                                inCarRecord = true;
                            } else if (inCarRecord && line.startsWith("Listing ID:")) {
                                currentCarId = line.substring(line.indexOf(":") + 1).trim();
                            } else if (inCarRecord && line.startsWith("Title:")) {
                                title = line.substring(line.indexOf(":") + 1).trim();
                            } else if (line.equals("-----------------------------")) {
                                if (!currentCarId.isEmpty()) {
                                    %>
                                    <div class="card mb-2">
                                        <div class="card-body d-flex justify-content-between align-items-center">
                                            <div>
                                                <strong><%= title.isEmpty() ? "No Title" : title %></strong> (ID: <%= currentCarId %>)
                                            </div>
                                            <a href="direct-car-manager.jsp?action=edit&id=<%= currentCarId %>" class="btn btn-sm btn-primary">Edit</a>
                                        </div>
                                    </div>
                                    <%
                                }
                                inCarRecord = false;
                                currentCarId = "";
                                title = "";
                            }
                        }
                    } catch (Exception e) {
                        out.println("<p class='text-danger'>Error parsing car records: " + e.getMessage() + "</p>");
                    }
                %>
            </div>
            
            <h3>File Raw Content</h3>
            <pre><%= currentContent %></pre>
        <% } %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>