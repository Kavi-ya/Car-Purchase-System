package com.carpurchase.servlets;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Random;
import java.util.TimeZone;
import java.util.Calendar;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class RegisterServlet
 * Handles user registration and stores data in a text file
 */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DATA_DIR = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data";
    private static final String USER_DATA_FILE = "users.txt";
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public RegisterServlet() {
        super();
    }
    
    /**
     * Generates a random user ID with format: CT[YY][XXXXXX]
     * Where YY is the current year (2 digits) and XXXXXX is a random 6-digit number
     * 
     * @return A randomly generated user ID
     */
    private String generateRandomUserId() {
        // Get current year (last 2 digits)
        Calendar calendar = Calendar.getInstance();
        int year = calendar.get(Calendar.YEAR) % 100;
        
        // Generate a random 6-digit number
        Random random = new Random();
        int randomNum = 100000 + random.nextInt(900000); // Generates a number between 100000 and 999999
        
        // Format: CT[YY][XXXXXX]
        return String.format("CT%02d%06d", year, randomNum);
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            System.out.println("==== REGISTRATION PROCESSING STARTED ====");
            System.out.println("Processing registration form submission...");
            
            // Create data directory if it doesn't exist
            File dataDir = new File(DATA_DIR);
            if (!dataDir.exists()) {
                System.out.println("Creating data directory: " + DATA_DIR);
                dataDir.mkdirs();
            }
            
            // Get form data
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String username = request.getParameter("username");
            String password = request.getParameter("password"); // In a real app, this should be hashed
            String userRole = request.getParameter("userRole"); // "buyer" or "seller"
            String contactMethod = request.getParameter("contactMethod");
            String newsletter = request.getParameter("newsletter") != null ? "Yes" : "No";
            
            // Debug form data - detailed logging
            System.out.println("Form data received:");
            System.out.println("Full Name: " + fullName);
            System.out.println("Email: " + email);
            System.out.println("Phone: " + phone);
            System.out.println("Username: " + username);
            System.out.println("Password: [PROTECTED]");
            System.out.println("User Role: " + userRole);
            System.out.println("Contact Method: " + contactMethod);
            System.out.println("Newsletter: " + newsletter);
            
            // Validate required fields
            if (fullName == null || email == null || phone == null || username == null || 
                password == null || userRole == null || fullName.trim().isEmpty() || 
                email.trim().isEmpty() || phone.trim().isEmpty() || 
                username.trim().isEmpty() || password.trim().isEmpty()) {
                
                System.out.println("Error: Missing required fields");
                System.out.println("fullName present: " + (fullName != null && !fullName.trim().isEmpty()));
                System.out.println("email present: " + (email != null && !email.trim().isEmpty()));
                System.out.println("phone present: " + (phone != null && !phone.trim().isEmpty()));
                System.out.println("username present: " + (username != null && !username.trim().isEmpty()));
                System.out.println("password present: " + (password != null && !password.trim().isEmpty()));
                System.out.println("userRole present: " + (userRole != null && !userRole.trim().isEmpty()));
                
                response.sendRedirect("register.jsp?error=missing");
                return;
            }
            
            // Get current date and time in UTC format
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
            String currentDateTime = sdf.format(new Date());
            
            // Generate random user ID
            String userId = generateRandomUserId();
            System.out.println("Generated User ID: " + userId);
            
            // Prepare data to write to file
            StringBuilder userData = new StringBuilder();
            userData.append("User ID: ").append(userId).append("\n");
            userData.append("Registration Date: ").append(currentDateTime).append(" (UTC)\n");
            userData.append("Full Name: ").append(fullName).append("\n");
            userData.append("Email: ").append(email).append("\n");
            userData.append("Phone: ").append(phone).append("\n");
            userData.append("Username: ").append(username).append("\n");
            userData.append("Password: ").append(password).append("\n"); // In a real app, store hashed password
            userData.append("Role: ").append(userRole).append("\n");
            userData.append("Contact Method: ").append(contactMethod).append("\n");
            userData.append("Newsletter Subscription: ").append(newsletter).append("\n");
            userData.append("-----------------------------------------------------------\n");
            
            // Write to file
            File userDataFile = new File(dataDir, USER_DATA_FILE);
            boolean isNewFile = !userDataFile.exists();
            
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(userDataFile, true))) {
                if (isNewFile) {
                    System.out.println("Creating new user data file: " + userDataFile.getAbsolutePath());
                    writer.write("======== CAR TRADER USER REGISTRATION DATA ========\n\n");
                } else {
                    System.out.println("Appending to existing user data file: " + userDataFile.getAbsolutePath());
                }
                
                writer.write(userData.toString());
                writer.flush();
                
                System.out.println("User data successfully written to file!");
                System.out.println("--------------------------------------");
                System.out.println(userData.toString());
                System.out.println("--------------------------------------");
                
                // Set session attributes for the newly registered user
                HttpSession session = request.getSession();
                session.setAttribute("username", username);
                session.setAttribute("fullName", fullName);
                session.setAttribute("userRole", userRole);
                session.setAttribute("userId", userId);
                
                System.out.println("Session attributes set - Redirecting to login.jsp");
                System.out.println("==== REGISTRATION PROCESSING COMPLETED SUCCESSFULLY ====");
                
                // Redirect to success page
                response.sendRedirect("login.jsp");
            } catch (IOException e) {
                System.err.println("Error writing to user data file: " + e.getMessage());
                e.printStackTrace();
                log("Error writing to user data file", e);
                response.sendRedirect("register.jsp?error=file");
            }
            
        } catch (Exception e) {
            System.err.println("Error in RegisterServlet: " + e.getMessage());
            e.printStackTrace();
            log("Error in RegisterServlet", e);
            response.sendRedirect("register.jsp?error=unknown");
        } finally {
            out.close();
        }
    }
}