<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!
    // Inner class to represent a User (copied from user-management.jsp)
    public static class User {
        private String id;
        private String username;
        private String password;
        private String fullName;
        private String email;
        private String phone;
        private String role;
        private boolean active = true;
        private String registrationDate;
        private String contactMethod;
        private boolean newsletterSubscription;
        
        public User() {
            this.id = generateId();
            this.registrationDate = LocalDateTime.now().format(
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) + " (UTC)";
            this.active = true;
        }
        
        private String generateId() {
            // Generate a random ID
            Random rand = new Random();
            String prefix = "CT";
            String numbers = String.format("%08d", rand.nextInt(100000000));
            return prefix + numbers;
        }
        
        // Getters and setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
        
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
        
        public boolean isActive() { return active; }
        public void setActive(boolean active) { this.active = active; }
        
        public String getRegistrationDate() { return registrationDate; }
        public void setRegistrationDate(String registrationDate) { this.registrationDate = registrationDate; }
        
        public String getContactMethod() { return contactMethod; }
        public void setContactMethod(String contactMethod) { this.contactMethod = contactMethod; }
        
        public boolean hasNewsletterSubscription() { return newsletterSubscription; }
        public void setNewsletterSubscription(boolean newsletterSubscription) { this.newsletterSubscription = newsletterSubscription; }
    }
    
    // File operations methods (copied from user-management.jsp)
    public List<User> getAllUsers(String filePath) throws IOException {
        List<User> users = new ArrayList<>();
        File file = new File(filePath);
        
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
                    currentUser.setId(line.substring("User ID:".length()).trim());
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
                        currentUser.setActive(Boolean.parseBoolean(line.substring("Active:".length()).trim()));
                    } else if (line.startsWith("Contact Method:")) {
                        currentUser.setContactMethod(line.substring("Contact Method:".length()).trim());
                    } else if (line.startsWith("Newsletter Subscription:")) {
                        String sub = line.substring("Newsletter Subscription:".length()).trim();
                        currentUser.setNewsletterSubscription("Yes".equalsIgnoreCase(sub));
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
    
    public User getUserById(String userId, String filePath) throws IOException {
        for (User user : getAllUsers(filePath)) {
            if (user.getId().equals(userId)) {
                return user;
            }
        }
        return null;
    }
    
    public User getUserByUsername(String username, String filePath) throws IOException {
        for (User user : getAllUsers(filePath)) {
            if (user.getUsername().equalsIgnoreCase(username)) {
                return user;
            }
        }
        return null;
    }
    
    public void updateUser(User updatedUser, String filePath) throws IOException {
        List<User> users = getAllUsers(filePath);
        boolean found = false;
        
        for (int i = 0; i < users.size(); i++) {
            if (users.get(i).getId().equals(updatedUser.getId())) {
                users.set(i, updatedUser);
                found = true;
                break;
            }
        }
        
        if (!found) {
            throw new IllegalArgumentException("User not found");
        }
        
        saveAllUsers(users, filePath);
    }
    
    private void saveAllUsers(List<User> users, String filePath) throws IOException {
        // Create a temp file without metadata
        File file = new File(filePath);
        File tempFile = new File(filePath + ".tmp");
        
        String currentDate = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        String currentUser = "System";
        
        // Try to get the first user's ID as current user
        if (!users.isEmpty()) {
            currentUser = users.get(0).getId();
        }
        
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(tempFile))) {
            // Write header metadata
            writer.write("Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): " + currentDate);
            writer.newLine();
            writer.write("Current User's Login: " + currentUser);
            writer.newLine();
            
            for (User user : users) {
                writer.write("User ID: " + user.getId());
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
                writer.write("Active: " + user.isActive());
                writer.newLine();
                writer.write("Contact Method: " + (user.getContactMethod() != null ? user.getContactMethod() : "email"));
                writer.newLine();
                writer.write("Newsletter Subscription: " + (user.hasNewsletterSubscription() ? "Yes" : "No"));
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
%>

<%
    // Check if user is logged in as admin
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    String userId = (String) session.getAttribute("userId");
    
    // For testing only - remove in production
    if (username == null || !"admin".equalsIgnoreCase(userRole)) {
        // For testing, override this
        username = "admin";
        userRole = "admin";
        userId = "CT48867810";  // From users.txt
    }
    
    // Hardcoded file path as requested
    String userFile = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data\\users.txt";
    
    // Variable to store user data and messages
    User adminUser = null;
    String message = "";
    boolean success = false;
    
    try {
        // If userId is available in session, use it to get admin user
        if (userId != null) {
            adminUser = getUserById(userId, userFile);
        }
        
        // If not found by ID but username is available, try by username
        if (adminUser == null && username != null) {
            adminUser = getUserByUsername(username, userFile);
            if (adminUser != null) {
                userId = adminUser.getId();
                session.setAttribute("userId", userId);
            }
        }
        
        // If still null, get any admin user
        if (adminUser == null) {
            // Find any admin user
            List<User> allUsers = getAllUsers(userFile);
            for (User user : allUsers) {
                if ("admin".equalsIgnoreCase(user.getRole())) {
                    adminUser = user;
                    userId = adminUser.getId();
                    username = adminUser.getUsername();
                    session.setAttribute("userId", userId);
                    session.setAttribute("username", username);
                    break;
                }
            }
        }
    } catch (Exception e) {
        message = "Error loading user data: " + e.getMessage();
        e.printStackTrace();
    }
    
    // Handle form submission to update profile
    if ("POST".equalsIgnoreCase(request.getMethod()) && "update".equals(request.getParameter("action"))) {
        try {
            if (adminUser != null) {
                // Get updated values from form
                String newFullName = request.getParameter("fullName");
                String newEmail = request.getParameter("email");
                String newPhone = request.getParameter("phone");
                String newPassword = request.getParameter("password");
                String confirmPassword = request.getParameter("confirmPassword");
                String contactMethod = request.getParameter("contactMethod");
                String newsletter = request.getParameter("newsletter");
                
                // Validate password if provided
                if (newPassword != null && !newPassword.isEmpty()) {
                    if (!newPassword.equals(confirmPassword)) {
                        message = "Passwords do not match!";
                        success = false;
                    } else {
                        adminUser.setPassword(newPassword);
                        success = true;
                    }
                } else {
                    success = true;
                }
                
                if (success) {
                    // Update user data
                    adminUser.setFullName(newFullName);
                    adminUser.setEmail(newEmail);
                    adminUser.setPhone(newPhone);
                    adminUser.setContactMethod(contactMethod);
                    adminUser.setNewsletterSubscription("on".equals(newsletter));
                    
                    // Save changes to file
                    updateUser(adminUser, userFile);
                    
                    message = "Profile updated successfully!";
                    success = true;
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
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Settings - CarTrader Admin</title>
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
            --admin-color: #6f42c1;
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
            background: linear-gradient(to bottom, var(--admin-color), #4e1d9e);
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
        
        .admin-badge {
            font-size: 0.7rem;
            background-color: white;
            color: var(--admin-color);
            padding: 2px 8px;
            border-radius: 10px;
            margin-left: 10px;
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
            background-color: #8854d0;
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
            margin-bottom: 20px;
        }
        
        .card-header {
            background-color: white;
            border-bottom: 1px solid rgba(0,0,0,0.05);
            padding: 15px 20px;
        }
        
        .form-label {
            font-weight: 500;
            color: #555;
        }
        
        .form-control:focus {
            box-shadow: 0 0 0 0.25rem rgba(111, 66, 193, 0.25);
            border-color: var(--admin-color);
        }
        
        .btn-primary {
            background-color: var(--admin-color);
            border-color: var(--admin-color);
        }
        
        .btn-primary:hover {
            background-color: #5e35b1;
            border-color: #5e35b1;
        }
        
        .profile-picture {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            background-color: #e9ecef;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            overflow: hidden;
            position: relative;
        }
        
        .profile-picture img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .profile-picture .upload-overlay {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background-color: rgba(0,0,0,0.5);
            color: white;
            padding: 5px;
            font-size: 12px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .profile-picture:hover .upload-overlay {
            bottom: 0;
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
            <a href="admin-dashboard.jsp" class="logo">
                <i class="fas fa-car-side me-2"></i> CarTrader <span class="admin-badge">ADMIN</span>
            </a>
        </div>
        
        <ul class="nav flex-column mt-4">
            <li class="nav-item">
                <a class="nav-link" href="admin-dashboard.jsp">
                    <i class="fas fa-tachometer-alt"></i> Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="user-management.jsp">
                    <i class="fas fa-users"></i> User Management
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="car-management.jsp">
                    <i class="fas fa-car"></i> Car Listings
                </a>
            </li>
            <li class="nav-item active">
                <a class="nav-link active" href="AdminMyProfile.jsp">
                    <i class="fas fa-user-cog"></i> My Profile
                </a>
            </li>
        </ul>
        
        <div class="sidebar-bottom">
            <div class="dropdown">
                <a href="#" class="user-menu dropdown-toggle" data-bs-toggle="dropdown">
                    <div class="user-avatar">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div>
                        <div class="fw-bold"><%= adminUser != null ? adminUser.getFullName() : "Admin" %></div>
                        <small class="text-white-50"><%= username %></small>
                    </div>
                </a>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="AdminMyProfile.jsp"><i class="fas fa-user-cog me-2"></i>My Profile</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                </ul>
            </div>
        </div>
    </div>
    
    <!-- Content -->
    <div class="content">
        <div class="container-fluid">
            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>Profile Settings</h2>
            </div>
            
            <!-- Status Messages -->
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= success ? "success" : "danger" %> alert-dismissible fade show" role="alert">
                    <i class="fas fa-<%= success ? "check" : "exclamation" %>-circle me-2"></i> <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            
            <% if (adminUser != null) { %>
                <div class="row">
                    <!-- Profile Information Card -->
                    <div class="col-lg-8 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">Profile Information</h5>
                            </div>
                            <div class="card-body">
                                <form action="AdminMyProfile.jsp" method="post">
                                    <input type="hidden" name="action" value="update">
                                    
                                    <div class="mb-3">
                                        <label for="userId" class="form-label">User ID</label>
                                        <input type="text" class="form-control" id="userId" value="<%= adminUser.getId() %>" readonly>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="username" class="form-label">Username</label>
                                        <input type="text" class="form-control" id="username" value="<%= adminUser.getUsername() %>" readonly>
                                        <small class="text-muted">Username cannot be changed</small>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="registrationDate" class="form-label">Registration Date</label>
                                        <input type="text" class="form-control" id="registrationDate" value="<%= adminUser.getRegistrationDate() %>" readonly>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="fullName" class="form-label">Full Name</label>
                                        <input type="text" class="form-control" id="fullName" name="fullName" value="<%= adminUser.getFullName() %>" required>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label for="email" class="form-label">Email</label>
                                            <input type="email" class="form-control" id="email" name="email" value="<%= adminUser.getEmail() %>" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label for="phone" class="form-label">Phone Number</label>
                                            <input type="text" class="form-control" id="phone" name="phone" value="<%= adminUser.getPhone() %>" placeholder="(xxx) xxx-xxxx">
                                        </div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="role" class="form-label">Role</label>
                                        <input type="text" class="form-control" id="role" value="<%= adminUser.getRole() %>" readonly>
                                        <small class="text-muted">Role cannot be changed</small>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label for="contactMethod" class="form-label">Preferred Contact Method</label>
                                            <select class="form-select" id="contactMethod" name="contactMethod">
                                                <option value="email" <%= "email".equals(adminUser.getContactMethod()) ? "selected" : "" %>>Email</option>
                                                <option value="phone" <%= "phone".equals(adminUser.getContactMethod()) ? "selected" : "" %>>Phone</option>
                                                <option value="both" <%= "both".equals(adminUser.getContactMethod()) ? "selected" : "" %>>Both</option>
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <div class="mb-3 form-check">
                                        <input type="checkbox" class="form-check-input" id="newsletter" name="newsletter" <%= adminUser.hasNewsletterSubscription() ? "checked" : "" %>>
                                        <label class="form-check-label" for="newsletter">Subscribe to newsletter</label>
                                    </div>
                                    
                                    <hr>
                                    
                                    <h5 class="mb-3">Change Password</h5>
                                    <div class="mb-3">
                                        <label for="currentPassword" class="form-label">Current Password</label>
                                        <input type="password" class="form-control" id="currentPassword" name="currentPassword">
                                        <small class="text-muted">Leave blank to keep current password</small>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label for="password" class="form-label">New Password</label>
                                            <input type="password" class="form-control" id="password" name="password">
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label for="confirmPassword" class="form-label">Confirm New Password</label>
                                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword">
                                        </div>
                                    </div>
                                    
                                    <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                        <button type="submit" class="btn btn-primary">Save Changes</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Profile Picture and Account Info Card -->
                    <div class="col-lg-4">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">Account Information</h5>
                            </div>
                            <div class="card-body">
                                <ul class="list-group list-group-flush">
                                    <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-2">
                                        <span>Account Status</span>
                                        <span class="badge bg-success rounded-pill">Active</span>
                                    </li>
                                    <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-2">
                                        <span>Account Type</span>
                                        <span class="badge badge-admin rounded-pill">Administrator</span>
                                    </li>
                                    <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-2">
                                        <span>Last Login</span>
                                        <span><%= LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) %></span>
                                    </li>
                                </ul>
                                
                                <hr>
                                
                                <div class="mt-3">
                                    <h6 class="mb-3">File Information</h6>
                                    <p class="small text-muted mb-1">User file path: </p>
                                    <p class="small text-break"><%= userFile %></p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            <% } else { %>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-triangle me-2"></i> User not found. Please make sure you're logged in as an admin.
                </div>
            <% } %>
        </div>
    </div>

    <!-- Bootstrap JS and dependencies -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Toggle sidebar functionality
        document.getElementById('toggleSidebar').addEventListener('click', function() {
            document.querySelector('.sidebar').classList.toggle('show');
            document.querySelector('.content').classList.toggle('pushed');
        });
        
        // Password validation
        document.querySelector('form').addEventListener('submit', function(event) {
            const newPassword = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (newPassword) {
                if (newPassword !== confirmPassword) {
                    event.preventDefault();
                    alert('Passwords do not match!');
                    return false;
                }
            }
            
            return true;
        });
    </script>
</body>
</html>