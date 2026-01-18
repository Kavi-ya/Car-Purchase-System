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
    
    try {
        // Create a fixed content without metadata
        StringBuilder fixedContent = new StringBuilder();
        
        boolean inCarRecord = false;
        boolean foundFirstRecord = false;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            
            while ((line = reader.readLine()) != null) {
                // Skip metadata lines at the beginning
                if (line.startsWith("Current Date") || line.startsWith("Current User")) {
                    continue;
                }
                
                // Look for the start of car records
                if (line.contains("==== CAR LISTING RECORD ====")) {
                    if (!foundFirstRecord) {
                        foundFirstRecord = true;
                    } else {
                        fixedContent.append("\n"); // Add empty line between records
                    }
                    
                    inCarRecord = true;
                    fixedContent.append("==== CAR LISTING RECORD ====\n");
                    continue;
                }
                
                if (inCarRecord) {
                    fixedContent.append(line).append("\n");
                    
                    // Check for end of car record
                    if (line.equals("-----------------------------")) {
                        inCarRecord = false;
                    }
                }
            }
        }
        
        // Write the fixed content back to file
        // Use FileOutputStream to completely replace the file's contents
        try (FileOutputStream fos = new FileOutputStream(file, false);
             OutputStreamWriter osw = new OutputStreamWriter(fos, "UTF-8");
             BufferedWriter bw = new BufferedWriter(osw)) {
            
            bw.write(fixedContent.toString());
            bw.flush();
        }
        
        success = true;
        message = "File has been completely cleaned and fixed!";
        
    } catch (Exception e) {
        message = "Error fixing file: " + e.getMessage();
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Fix Car File Now</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="card">
            <div class="card-header bg-<%= success ? "success" : "danger" %> text-white">
                <h3>Car File Repair Utility</h3>
            </div>
            <div class="card-body">
                <div class="alert alert-<%= success ? "success" : "danger" %>">
                    <strong><%= success ? "Success!" : "Error!" %></strong> <%= message %>
                </div>
                
                <div class="mt-4">
                    <h5>Next Steps:</h5>
                    <ol>
                        <li>Now that the file has been fixed, go back to <a href="my-listing.jsp" class="btn btn-sm btn-primary">My Listings</a></li>
                        <li>Try editing a car listing - it should work properly now</li>
                        <li>If you still have issues, you need to identify what code is adding metadata to your file</li>
                    </ol>
                </div>
                
                <div class="alert alert-info mt-4">
                    <strong>Note:</strong> To completely fix the issue, you need to modify the code that's adding the metadata to the file.
                    Look for any code that writes to car_list.txt and adds the "Current Date" and "Current User" lines at the beginning.
                </div>
            </div>
        </div>
    </div>
</body>
</html>