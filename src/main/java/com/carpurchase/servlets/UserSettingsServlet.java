package com.carpurchase.servlets;

import com.carpurchase.model.User;
import java.io.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class UserSettingsServlet
 * Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-05-06 16:37:02
 * Current User's Login: IT24102083
 */
@WebServlet("/UserSettingsServlet")
public class UserSettingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Hardcoded file path
    private static final String USER_FILE = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data\\users.txt";
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UserSettingsServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     * Handles displaying the user settings
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        String userRole = (String) session.getAttribute("userRole");
        String userId = (String) session.getAttribute("userId");
        
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        User currentUser = null;
        
        try {
            // If userId is available in session, use it to get user
            if (userId != null) {
                currentUser = getUserById(userId);
            }
            
            // If not found by ID but username is available, try by username
            if (currentUser == null && username != null) {
                currentUser = getUserByUsername(username);
                if (currentUser != null) {
                    userId = currentUser.getUserId();
                    session.setAttribute("userId", userId);
                }
            }
            
            // Set the user in request for the JSP
            request.setAttribute("userDetail", currentUser);
            
            // Get any messages from previous actions
            String message = (String) session.getAttribute("message");
            Boolean success = (Boolean) session.getAttribute("success");
            
            if (message != null) {
                request.setAttribute("message", message);
                request.setAttribute("success", success);
                // Clear the session attributes once used
                session.removeAttribute("message");
                session.removeAttribute("success");
            }
            
        } catch (Exception e) {
            request.setAttribute("message", "Error loading user data: " + e.getMessage());
            request.setAttribute("success", false);
            e.printStackTrace();
        }
        
        // Forward to JSP
        request.getRequestDispatcher("/usersettings.jsp").forward(request, response);
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     * Handles updating user settings
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        
        if ("updateProfile".equals(action)) {
            updateProfile(request, response);
        } else if ("updatePassword".equals(action)) {
            updatePassword(request, response);
        } else {
            // Default to showing profile
            doGet(request, response);
        }
    }
    
    /**
     * Updates the user profile based on form submission
     */
    private void updateProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = request.getParameter("userId");
        String message = "";
        boolean success = false;
        
        try {
            User user = getUserById(userId);
            
            if (user != null) {
                // Get updated values from form
                String newFullName = request.getParameter("fullName");
                String newEmail = request.getParameter("email");
                String newPhone = request.getParameter("phone");
                
                // Validate fields
                if (newFullName == null || newFullName.trim().isEmpty()) {
                    message = "Full name cannot be empty!";
                    success = false;
                } else if (newEmail == null || newEmail.trim().isEmpty() || !newEmail.contains("@")) {
                    message = "Please enter a valid email address!";
                    success = false;
                } else {
                    // Update user data
                    user.setFullName(newFullName);
                    user.setEmail(newEmail);
                    user.setPhone(newPhone);
                    
                    // Save changes to file
                    updateUser(user);
                    
                    message = "Profile updated successfully!";
                    success = true;
                    
                    // Update session attributes
                    session.setAttribute("fullName", newFullName);
                }
            } else {
                message = "User not found!";
                success = false;
            }
        } catch (Exception e) {
            message = "Error updating profile: " + e.getMessage();
            e.printStackTrace();
            success = false;
        }
        
        // Set session attributes to be displayed after redirect
        session.setAttribute("message", message);
        session.setAttribute("success", success);
        
        // Redirect back to settings page
        response.sendRedirect("UserSettingsServlet");
    }
    
    /**
     * Updates the user password
     */
    private void updatePassword(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = request.getParameter("userId");
        String message = "";
        boolean success = false;
        
        try {
            User user = getUserById(userId);
            
            if (user != null) {
                String currentPassword = request.getParameter("currentPassword");
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");
                
                // Validate current password
                if (!currentPassword.equals(user.getPassword())) {
                    message = "Current password is incorrect!";
                    success = false;
                }
                // Validate new password
                else if (newPassword == null || newPassword.trim().isEmpty() || newPassword.length() < 6) {
                    message = "New password must be at least 6 characters long!";
                    success = false;
                }
                // Validate password confirmation
                else if (!newPassword.equals(confirmPassword)) {
                    message = "New passwords do not match!";
                    success = false;
                } else {
                    // Update user password
                    user.setPassword(newPassword);
                    
                    // Save changes to file
                    updateUser(user);
                    
                    message = "Password updated successfully!";
                    success = true;
                }
            } else {
                message = "User not found!";
                success = false;
            }
        } catch (Exception e) {
            message = "Error updating password: " + e.getMessage();
            e.printStackTrace();
            success = false;
        }
        
        // Set session attributes to be displayed after redirect
        session.setAttribute("message", message);
        session.setAttribute("success", success);
        
        // Redirect back to settings page
        response.sendRedirect("UserSettingsServlet");
    }
    
    /**
     * Gets all users from the user file
     */
    private List<User> getAllUsers() throws IOException {
        List<User> users = new ArrayList<>();
        File file = new File(USER_FILE);
        
        if (!file.exists()) {
            return users;
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            User currentUser = null;
            boolean foundFirstUserID = false;
            
            while ((line = reader.readLine()) != null) {
                // Skip metadata lines at the top
                if (!foundFirstUserID && !line.startsWith("User ID:")) {
                    continue;
                }
                
                // Empty line, continue
                if (line.trim().isEmpty()) {
                    continue;
                }
                
                // Start of a user entry
                if (line.startsWith("User ID:")) {
                    foundFirstUserID = true;
                    
                    // If there was a previous user being processed, add it to the list
                    if (currentUser != null) {
                        users.add(currentUser);
                    }
                    
                    currentUser = new User();
                    currentUser.setUserId(line.substring("User ID:".length()).trim());
                } else if (currentUser != null) {
                    // Process user fields
                    if (line.startsWith("Registration Date:")) {
                        currentUser.setRegistrationDate(line.substring("Registration Date:".length()).trim());
                    } else if (line.startsWith("Full Name:")) {
                        currentUser.setFullName(line.substring("Full Name:".length()).trim());
                    } else if (line.startsWith("Email:")) {
                        currentUser.setEmail(line.substring("Email:".length()).trim());
                    } else if (line.startsWith("Phone:")) {
                        currentUser.setPhone(line.substring("Phone:".length()).trim());
                    } else if (line.startsWith("Username:")) {
                        currentUser.setUsername(line.substring("Username:".length()).trim());
                    } else if (line.startsWith("Password:")) {
                        currentUser.setPassword(line.substring("Password:".length()).trim());
                    } else if (line.startsWith("Role:")) {
                        currentUser.setRole(line.substring("Role:".length()).trim());
                    } else if (line.startsWith("Active:")) {
                        currentUser.setActive(line.substring("Active:".length()).trim());
                    } else if (line.startsWith("Contact Method:")) {
                        currentUser.setContactMethod(line.substring("Contact Method:".length()).trim());
                    } else if (line.startsWith("Newsletter Subscription:")) {
                        currentUser.setNewsLetterSubscription(line.substring("Newsletter Subscription:".length()).trim());
                    }
                    
                    // If we encounter the separator line, this user is complete
                    if (line.startsWith("-----------------------------------------------------------")) {
                        if (currentUser != null) {
                            users.add(currentUser);
                            currentUser = null;
                        }
                    }
                }
            }
            
            // Add the last user if there is one being processed
            if (currentUser != null) {
                users.add(currentUser);
            }
        }
        
        return users;
    }
    
    /**
     * Gets a user by ID
     */
    private User getUserById(String userId) throws IOException {
        for (User user : getAllUsers()) {
            if (user.getUserId().equals(userId)) {
                return user;
            }
        }
        return null;
    }
    
    /**
     * Gets a user by username
     */
    private User getUserByUsername(String username) throws IOException {
        for (User user : getAllUsers()) {
            if (user.getUsername().equalsIgnoreCase(username)) {
                return user;
            }
        }
        return null;
    }
    
    /**
     * Updates a user in the users file
     */
    private void updateUser(User updatedUser) throws IOException {
        List<User> users = getAllUsers();
        boolean found = false;
        
        for (int i = 0; i < users.size(); i++) {
            if (users.get(i).getUserId().equals(updatedUser.getUserId())) {
                users.set(i, updatedUser);
                found = true;
                break;
            }
        }
        
        if (!found) {
            throw new IllegalArgumentException("User not found");
        }
        
        saveAllUsers(users);
    }
    
    /**
     * Saves all users to the users file
     */
    private void saveAllUsers(List<User> users) throws IOException {
        // Create a temp file without metadata
        File file = new File(USER_FILE);
        File tempFile = new File(USER_FILE + ".tmp");
        
        String currentDate = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        String currentUser = "System";
        
        // Try to get the first user's ID as current user
        if (!users.isEmpty()) {
            currentUser = users.get(0).getUserId();
        }
        
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(tempFile))) {
            // Write header metadata
            writer.write("Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): " + currentDate);
            writer.newLine();
            writer.write("Current User's Login: " + currentUser);
            writer.newLine();
            
            for (User user : users) {
                writer.write("User ID: " + user.getUserId());
                writer.newLine();
                writer.write("Registration Date: " + user.getRegistrationDate());
                writer.newLine();
                writer.write("Full Name: " + user.getFullName());
                writer.newLine();
                writer.write("Email: " + user.getEmail());
                writer.newLine();
                writer.write("Phone: " + (user.getPhone() != null ? user.getPhone() : "(000) 000-0000"));
                writer.newLine();
                writer.write("Username: " + user.getUsername());
                writer.newLine();
                writer.write("Password: " + user.getPassword());
                writer.newLine();
                writer.write("Role: " + user.getRole());
                writer.newLine();
                writer.write("Active: " + user.getActive()); 
                writer.newLine();
                writer.write("Contact Method: " + (user.getContactMethod() != null ? user.getContactMethod() : "email"));
                writer.newLine();
                writer.write("Newsletter Subscription: " + user.getNewsLetterSubscription());
                writer.newLine();
                writer.write("-----------------------------------------------------------");
                writer.newLine();
            }
        }
        
        // Replace the original file with the temp file
        if (file.exists()) {
            file.delete();
        }
        
        tempFile.renameTo(file);
    }
}