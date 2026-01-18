<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.file.*" %>

<%!
    // Helper method to get proper image URL with consistent path handling
    public String getImagePath(HttpServletRequest request, String relativePath) {
        if (relativePath == null || relativePath.trim().isEmpty()) {
            return request.getContextPath() + "/car_images/default1.jpg";
        }
        
        // Check if this is already a full URL
        if (relativePath.startsWith("http://") || relativePath.startsWith("https://")) {
            return relativePath;
        }
        
        // Ensure the path has no double slashes and has proper context path
        String path = relativePath.trim();
        
        // Remove any leading / to avoid double slashes when adding context path
        if (path.startsWith("/")) {
            path = path.substring(1);
        }
        
        // Add context path
        String contextPath = request.getContextPath();
        if (!contextPath.endsWith("/") && !path.startsWith("/")) {
            contextPath += "/";
        }
        
        // Return the proper full path
        return contextPath + path;
    }
    
    // Check if the file exists on disk - useful for debugging
    public boolean imageFileExists(String realPath, String imagePath) {
        if (imagePath == null || imagePath.isEmpty()) {
            return false;
        }
        
        // Extract the filename from the path
        String fileName = imagePath;
        int lastSlash = imagePath.lastIndexOf('/');
        if (lastSlash != -1) {
            fileName = imagePath.substring(lastSlash + 1);
        }
        
        // Check in the car_images directory
        File imageFile = new File(realPath + File.separator + "car_images" + File.separator + fileName);
        return imageFile.exists();
    }
%>

<%
    // Get the real path to the web app root
    String realPath = application.getRealPath("/");
    
    // Sample image path for testing
    String sampleImage = "car_images/carImg1_20345.jpg";
    boolean fileExists = imageFileExists(realPath, sampleImage);
%>

<!-- Use this for image tags in your JSPs: -->
<img src="<%= getImagePath(request, "car_images/carImg1_20345.jpg") %>" class="card-img-top" alt="Car Image">