package com.carpurchase.servlets;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class LoginServlet
 * Handles user login authentication against users.txt file
 * and redirects to appropriate dashboard based on user role
 */
// @WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DATA_DIR = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data";
    private static final String USER_DATA_FILE = "users.txt";
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            System.out.println("==== LOGIN PROCESSING STARTED ====");
            
            // Get form data
            String usernameOrEmail = request.getParameter("username");
            String password = request.getParameter("password");
            boolean rememberMe = request.getParameter("rememberMe") != null;
            
            System.out.println("Login attempt for: " + usernameOrEmail);
            
            // Validate input
            if (usernameOrEmail == null || password == null || 
                usernameOrEmail.trim().isEmpty() || password.trim().isEmpty()) {
                System.out.println("Error: Missing login credentials");
                response.sendRedirect("login.jsp?error=invalid");
                return;
            }
            
            // Try to authenticate the user
            Map<String, String> userData = authenticateUser(usernameOrEmail, password);
            
            if (userData != null) {
                // Authentication successful
                System.out.println("Login successful for user: " + userData.get("username"));
                
                // Create a session for the user
                HttpSession session = request.getSession();
                session.setAttribute("username", userData.get("username"));
                session.setAttribute("fullName", userData.get("fullName"));
                session.setAttribute("userRole", userData.get("userRole"));
                session.setAttribute("userId", userData.get("userId"));
                session.setAttribute("email", userData.get("email"));
                
                // If remember me is checked, extend session timeout
                if (rememberMe) {
                    // Set session timeout to 7 days (in seconds)
                    session.setMaxInactiveInterval(7 * 24 * 60 * 60);
                }
                
                System.out.println("Session created for user: " + userData.get("username"));
                System.out.println("User role: " + userData.get("userRole"));
                System.out.println("==== LOGIN PROCESSING COMPLETED SUCCESSFULLY ====");
                
                // Redirect based on user role
                String userRole = userData.get("userRole");
                if (userRole != null) {
                    switch (userRole.toLowerCase()) {
                        case "buyer":
                            response.sendRedirect("buyer-dashboard.jsp");
                            break;
                        case "seller":
                            response.sendRedirect("seller-dashboard.jsp");
                            break;
                        case "admin":
                            response.sendRedirect("admin-dashboard.jsp");
                            break;
                        default:
                            // Default redirect to index page
                            response.sendRedirect("index.jsp");
                            break;
                    }
                } else {
                    // If no role is found, default to index
                    response.sendRedirect("index.jsp");
                }
            } else {
                // Authentication failed
                System.out.println("Login failed: Invalid credentials for " + usernameOrEmail);
                response.sendRedirect("login.jsp?error=invalid");
            }
            
        } catch (Exception e) {
            System.err.println("Error in LoginServlet: " + e.getMessage());
            e.printStackTrace();
            log("Error in LoginServlet", e);
            response.sendRedirect("login.jsp?error=system");
        } finally {
            out.close();
        }
    }
    
    /**
     * Authenticates a user by checking the users.txt file
     * 
     * @param usernameOrEmail The username or email to check
     * @param password The password to validate
     * @return A map of user data if authentication succeeds, null otherwise
     */
    private Map<String, String> authenticateUser(String usernameOrEmail, String password) {
        File userDataFile = new File(DATA_DIR, USER_DATA_FILE);
        
        if (!userDataFile.exists()) {
            System.out.println("User data file not found: " + userDataFile.getAbsolutePath());
            return null;
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(userDataFile))) {
            String line;
            Map<String, String> userData = new HashMap<>();
            String currentUserId = null;
            boolean processingUser = false;
            
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                
                // Skip header or empty lines
                if (line.isEmpty() || line.startsWith("====")) {
                    continue;
                }
                
                // Check for user record separator
                if (line.startsWith("----")) {
                    // End of a user record
                    if (processingUser) {
                        String username = userData.get("username");
                        String email = userData.get("email");
                        String storedPassword = userData.get("password");
                        
                        // Check if username or email matches
                        boolean usernameMatch = username != null && username.equalsIgnoreCase(usernameOrEmail);
                        boolean emailMatch = email != null && email.equalsIgnoreCase(usernameOrEmail);
                        
                        // Check if password matches
                        if ((usernameMatch || emailMatch) && storedPassword != null && storedPassword.equals(password)) {
                            System.out.println("User authenticated successfully: " + username);
                            return userData;
                        }
                    }
                    
                    // Reset for next user
                    userData.clear();
                    processingUser = false;
                    continue;
                }
                
                // Parse user data lines
                if (line.contains(":")) {
                    String[] parts = line.split(":", 2);
                    if (parts.length == 2) {
                        String key = parts[0].trim();
                        String value = parts[1].trim();
                        
                        // Track key user data fields
                        switch (key) {
                            case "User ID":
                                currentUserId = value;
                                userData.put("userId", value);
                                processingUser = true;
                                break;
                            case "Full Name":
                                userData.put("fullName", value);
                                break;
                            case "Email":
                                userData.put("email", value);
                                break;
                            case "Username":
                                userData.put("username", value);
                                break;
                            case "Password":
                                userData.put("password", value);
                                break;
                            case "Role":
                                userData.put("userRole", value);
                                break;
                            default:
                                // Store other fields in case they're needed
                                userData.put(key.toLowerCase().replace(" ", "_"), value);
                                break;
                        }
                    }
                }
            }
            
            // Check if we were processing a user at the end of the file
            if (processingUser) {
                String username = userData.get("username");
                String email = userData.get("email");
                String storedPassword = userData.get("password");
                
                // Check if username or email matches
                boolean usernameMatch = username != null && username.equalsIgnoreCase(usernameOrEmail);
                boolean emailMatch = email != null && email.equalsIgnoreCase(usernameOrEmail);
                
                // Check if password matches
                if ((usernameMatch || emailMatch) && storedPassword != null && storedPassword.equals(password)) {
                    System.out.println("User authenticated successfully: " + username);
                    return userData;
                }
            }
            
            // No matching user found
            return null;
            
        } catch (IOException e) {
            System.err.println("Error reading user data file: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}