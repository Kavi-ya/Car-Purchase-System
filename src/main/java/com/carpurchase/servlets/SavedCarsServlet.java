package com.carpurchase.servlets;

import com.carpurchase.model.Car;
import com.carpurchase.model.CarListManager;
import java.io.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class SavedCarsServlet
 * Handles operations for saving and retrieving favorite cars
 * Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-05-06 08:40:23
 * Current User's Login: IT24102083
 */
@WebServlet("/SavedCarsServlet")
public class SavedCarsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Hardcoded file path as requested
    private static final String SAVED_CARS_FILE = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data\\savedcars.txt";
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public SavedCarsServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     * Handles loading saved cars for display
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        String userRole = (String) session.getAttribute("userRole");
        
        if (userId == null || username == null || !"buyer".equalsIgnoreCase(userRole)) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Load the user's saved car IDs
        List<String> savedCarIds = getSavedCarIds(userId);
        
        // Load the actual car details
        CarListManager carManager = new CarListManager();
        List<Car> savedCars = new ArrayList<>();
        
        for (String carId : savedCarIds) {
            Car car = carManager.getCarById(carId);
            if (car != null) {
                savedCars.add(car);
            }
        }
        
        // Set the saved cars as a request attribute
        request.setAttribute("savedCars", savedCars);
        
        // Forward to the saved cars JSP
        request.getRequestDispatcher("/SavedCars.jsp").forward(request, response);
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     * Handles saving or removing cars from favorites
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        String userRole = (String) session.getAttribute("userRole");
        
        if (userId == null || username == null || !"buyer".equalsIgnoreCase(userRole)) {
            // Return error response
            sendTextResponse(response, false, "User not authenticated");
            return;
        }
        
        // Get action and car ID from the request
        String action = request.getParameter("action");
        String carId = request.getParameter("carId");
        
        if (action == null || carId == null || carId.isEmpty()) {
            sendTextResponse(response, false, "Missing required parameters");
            return;
        }
        
        boolean success = false;
        String message = "";
        
        try {
            if ("save".equals(action)) {
                // Add car to favorites
                success = addToSavedCars(userId, carId);
                message = success ? "Car saved to favorites" : "Failed to save car";
            } else if ("remove".equals(action)) {
                // Remove car from favorites
                success = removeFromSavedCars(userId, carId);
                message = success ? "Car removed from favorites" : "Failed to remove car";
            } else {
                message = "Invalid action";
            }
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            e.printStackTrace();
        }
        
        // Send text response
        sendTextResponse(response, success, message);
    }
    
    /**
     * Checks if a car is saved by a user
     */
    protected void doHead(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get user ID and car ID
        String userId = request.getParameter("userId");
        String carId = request.getParameter("carId");
        
        if (userId == null || carId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        // Check if car is saved
        boolean isSaved = isCarSaved(userId, carId);
        
        if (isSaved) {
            response.setStatus(HttpServletResponse.SC_OK); // 200
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND); // 404
        }
    }
    
    /**
     * Sends a simple text response
     */
    private void sendTextResponse(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        out.print("success=" + success + ";message=" + message);
        out.flush();
    }
    
    /**
     * Gets all saved car IDs for a user
     */
    private List<String> getSavedCarIds(String userId) {
        List<String> savedCarIds = new ArrayList<>();
        File file = new File(SAVED_CARS_FILE);
        
        if (!file.exists()) {
            return savedCarIds;
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            boolean foundUser = false;
            
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("UserId: " + userId)) {
                    foundUser = true;
                } else if (foundUser && line.startsWith("SavedCarIds: ")) {
                    String carIdsStr = line.substring("SavedCarIds: ".length()).trim();
                    if (!carIdsStr.isEmpty()) {
                        String[] carIds = carIdsStr.split(",");
                        for (String carId : carIds) {
                            savedCarIds.add(carId.trim());
                        }
                    }
                    break;
                } else if (line.startsWith("---------------------------------------")) {
                    foundUser = false;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        return savedCarIds;
    }
    
    /**
     * Checks if a car is saved by a user
     */
    private boolean isCarSaved(String userId, String carId) {
        List<String> savedCarIds = getSavedCarIds(userId);
        return savedCarIds.contains(carId);
    }
    
    /**
     * Adds a car to user's saved cars
     */
    private boolean addToSavedCars(String userId, String carId) throws IOException {
        // Get current saved car IDs
        List<String> savedCarIds = getSavedCarIds(userId);
        
        // If car already saved, return true
        if (savedCarIds.contains(carId)) {
            return true;
        }
        
        // Add the new car ID
        savedCarIds.add(carId);
        
        // Save the updated list
        return updateSavedCarsFile(userId, savedCarIds);
    }
    
    /**
     * Removes a car from user's saved cars
     */
    private boolean removeFromSavedCars(String userId, String carId) throws IOException {
        // Get current saved car IDs
        List<String> savedCarIds = getSavedCarIds(userId);
        
        // If car not in saved list, return true (already not saved)
        if (!savedCarIds.contains(carId)) {
            return true;
        }
        
        // Remove the car ID
        savedCarIds.remove(carId);
        
        // Save the updated list
        return updateSavedCarsFile(userId, savedCarIds);
    }
    
    /**
     * Updates the saved cars file with new car IDs for a user
     */
    private boolean updateSavedCarsFile(String userId, List<String> savedCarIds) throws IOException {
        File file = new File(SAVED_CARS_FILE);
        
        // Create directories if they don't exist
        File parent = file.getParentFile();
        if (!parent.exists()) {
            parent.mkdirs();
        }
        
        // If file doesn't exist, create it with the new entry
        if (!file.exists()) {
            try (PrintWriter writer = new PrintWriter(new FileWriter(file))) {
                writer.println("Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-05-06 08:40:23");
                writer.println("Current User's Login: " + userId);
                writer.println("UserId: " + userId);
                writer.println("SavedCarIds: " + String.join(",", savedCarIds));
                writer.println("---------------------------------------");
            }
            return true;
        }
        
        // Read all entries
        List<String> fileLines = new ArrayList<>();
        boolean foundUser = false;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            boolean skipUser = false;
            
            // First two lines are metadata - keep them
            String headerLine1 = reader.readLine();
            String headerLine2 = reader.readLine();
            if (headerLine1 != null && headerLine1.startsWith("Current Date")) {
                fileLines.add(headerLine1);
            } else {
                fileLines.add("Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-05-06 08:40:23");
                if (headerLine1 != null) fileLines.add(headerLine1);
            }
            
            if (headerLine2 != null && headerLine2.startsWith("Current User")) {
                fileLines.add(headerLine2);
            } else {
                fileLines.add("Current User's Login: " + userId);
                if (headerLine2 != null) fileLines.add(headerLine2);
            }
            
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("UserId: " + userId)) {
                    foundUser = true;
                    skipUser = true;
                    
                    // Add the updated user entry
                    fileLines.add("UserId: " + userId);
                    fileLines.add("SavedCarIds: " + String.join(",", savedCarIds));
                } else if (skipUser && line.startsWith("---------------------------------------")) {
                    skipUser = false;
                    fileLines.add(line);
                } else if (!skipUser) {
                    fileLines.add(line);
                }
            }
        }
        
        // If user wasn't found, add them to the end
        if (!foundUser) {
            fileLines.add("UserId: " + userId);
            fileLines.add("SavedCarIds: " + String.join(",", savedCarIds));
            fileLines.add("---------------------------------------");
        }
        
        // Write all entries back to file
        try (PrintWriter writer = new PrintWriter(new FileWriter(file))) {
            for (String line : fileLines) {
                writer.println(line);
            }
        }
        
        return true;
    }
}