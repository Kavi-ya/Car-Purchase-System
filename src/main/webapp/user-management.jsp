<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!
    // Inner class to represent a User
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
    
    // Methods for user file operations
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
                        // Added support for parsing Active status
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
    
    public void addUser(User user, String filePath) throws IOException {
        File file = new File(filePath);
        File parent = file.getParentFile();
        
        if (!parent.exists()) {
            parent.mkdirs();
        }
        
        boolean fileExists = file.exists();
        String currentDate = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        
        try (FileWriter fw = new FileWriter(file, fileExists); 
             BufferedWriter writer = new BufferedWriter(fw)) {
            
            if (!fileExists) {
                // If file is new, write header
                writer.write("Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): " + currentDate);
                writer.newLine();
                writer.write("Current User's Login: " + (user.getId() != null ? user.getId() : "System"));
                writer.newLine();
            }
            
            // Write user data
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
            writer.write("Active: " + user.isActive()); // Added Active status field
            writer.newLine();
            writer.write("Contact Method: " + (user.getContactMethod() != null ? user.getContactMethod() : "email"));
            writer.newLine();
            writer.write("Newsletter Subscription: " + (user.hasNewsletterSubscription() ? "Yes" : "No"));
            writer.newLine();
            writer.write("-----------------------------------------------------------");
            writer.newLine();
        }
    }
    
    public void updateUser(User updatedUser, String filePath) throws IOException {
        List<User> users = getAllUsers(filePath);
        boolean found = false;
        
        for (int i = 0; i < users.size(); i++) {
            if (users.get(i).getId().equals(updatedUser.getId()) || 
                users.get(i).getUsername().equals(updatedUser.getUsername())) {
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
    
    public void deleteUser(String userId, String filePath) throws IOException {
        List<User> users = getAllUsers(filePath);
        boolean found = false;
        
        for (Iterator<User> iterator = users.iterator(); iterator.hasNext();) {
            User user = iterator.next();
            if (user.getId().equals(userId)) {
                iterator.remove();
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
                writer.write("Active: " + user.isActive()); // Added Active status field
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
    
    public void initializeUserStore(String filePath) throws IOException {
        File file = new File(filePath);
        if (!file.exists() || file.length() == 0) {
            // Create admin user
            User adminUser = new User();
            adminUser.setId("CT12345678");
            adminUser.setUsername("admin");
            adminUser.setPassword("admin123"); // Should be hashed in real app
            adminUser.setFullName("System Administrator");
            adminUser.setEmail("admin@cartrader.com");
            adminUser.setPhone("(123) 456-7890");
            adminUser.setRole("admin");
            adminUser.setContactMethod("email");
            adminUser.setNewsletterSubscription(false);
            addUser(adminUser, filePath);
        }
    }
%>

<%
    // Check if user is logged in as admin
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || !"admin".equalsIgnoreCase(userRole)) {
        // For testing, override this
        username = "admin";
        fullName = "Administrator";
        userRole = "admin";
        //response.sendRedirect("login.jsp");
        //return;
    }
    
    // Path to user data file
    String dataDir = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data";
    String userFile = dataDir + File.separator + "users.txt";
    
    // Initialize user store if needed
    try {
        initializeUserStore(userFile);
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Process user actions
    String action = request.getParameter("action");
    String userId = request.getParameter("userid");
    String message = "";
    boolean success = false;
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if ("add".equals(action)) {
            // Add new user
            try {
                String newUsername = request.getParameter("newUsername");
                String newPassword = request.getParameter("newPassword");
                String newEmail = request.getParameter("newEmail");
                String newFullName = request.getParameter("newFullName");
                String newRole = request.getParameter("newRole");
                String newPhone = request.getParameter("newPhone");
                
                // Validate username is unique
                User existingUser = getUserByUsername(newUsername, userFile);
                if (existingUser != null) {
                    message = "Username already exists. Please choose a different username.";
                } else {
                    // Create new user
                    User newUser = new User();
                    newUser.setUsername(newUsername);
                    newUser.setPassword(newPassword); // In real app, encrypt this
                    newUser.setEmail(newEmail);
                    newUser.setFullName(newFullName);
                    newUser.setRole(newRole);
                    newUser.setPhone(newPhone);
                    newUser.setContactMethod("email");
                    newUser.setActive(true);  // New users are active by default
                    
                    addUser(newUser, userFile);
                    success = true;
                    message = "User added successfully!";
                }
            } catch (Exception e) {
                message = "Error adding user: " + e.getMessage();
                e.printStackTrace();
            }
        } else if ("update".equals(action)) {
            // Update user
            try {
                String editUserId = request.getParameter("editUserId");
                String editUsername = request.getParameter("editUsername");
                String editPassword = request.getParameter("editPassword");
                String editEmail = request.getParameter("editEmail");
                String editFullName = request.getParameter("editFullName");
                String editRole = request.getParameter("editRole");
                String editPhone = request.getParameter("editPhone");
                String editNewsletterSubscription = request.getParameter("editNewsletter");
                String editActive = request.getParameter("editActive"); // Added active status
                
                User user = getUserById(editUserId, userFile);
                if (user != null) {
                    // Check if username is changed and if it's unique
                    if (!user.getUsername().equals(editUsername)) {
                        User existingUser = getUserByUsername(editUsername, userFile);
                        if (existingUser != null && !existingUser.getId().equals(editUserId)) {
                            message = "Username already exists. Please choose a different username.";
                            success = false;
                        } else {
                            user.setUsername(editUsername);
                            success = true;
                        }
                    } else {
                        success = true;
                    }
                    
                    if (success) {
                        // Only update password if provided
                        if (editPassword != null && !editPassword.trim().isEmpty()) {
                            user.setPassword(editPassword); // Should be hashed in real app
                        }
                        
                        user.setEmail(editEmail);
                        user.setFullName(editFullName);
                        user.setRole(editRole);
                        if (editPhone != null) {
                            user.setPhone(editPhone);
                        }
                        user.setNewsletterSubscription("on".equals(editNewsletterSubscription));
                        
                        // Update active status if not admin
                        if (!"admin".equals(user.getRole())) {
                            user.setActive("on".equals(editActive));
                        }
                        
                        updateUser(user, userFile);
                        success = true;
                        message = "User updated successfully!";
                    }
                } else {
                    message = "User not found.";
                    success = false;
                }
            } catch (Exception e) {
                message = "Error updating user: " + e.getMessage();
                e.printStackTrace();
                success = false;
            }
        }
    } else if (action != null && userId != null) {
        try {
            if ("delete".equals(action)) {
                // Delete user
                User user = getUserById(userId, userFile);
                if (user != null && !"admin".equals(user.getRole())) {
                    deleteUser(userId, userFile);
                    success = true;
                    message = "User deleted successfully.";
                } else {
                    message = "Cannot delete admin user.";
                    success = false;
                }
            } else if ("activate".equals(action)) {
                // Activate user
                User user = getUserById(userId, userFile);
                if (user != null) {
                    user.setActive(true);
                    updateUser(user, userFile);
                    success = true;
                    message = "User activated successfully.";
                } else {
                    message = "User not found.";
                    success = false;
                }
            } else if ("deactivate".equals(action)) {
                // Deactivate user
                User user = getUserById(userId, userFile);
                if (user != null && !"admin".equals(user.getRole())) {
                    user.setActive(false);
                    updateUser(user, userFile);
                    success = true;
                    message = "User deactivated successfully.";
                } else {
                    message = "Cannot deactivate admin user.";
                    success = false;
                }
            }
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            e.printStackTrace();
            success = false;
        }
    }
    
    // Get all users for display
    List<User> users = new ArrayList<>();
    try {
        users = getAllUsers(userFile);
        // For debugging
        System.out.println("Loaded " + users.size() + " users:");
        for (User user : users) {
            System.out.println("  - " + user.getUsername() + " (Role: " + user.getRole() + ", Active: " + user.isActive() + ")");
        }
    } catch (Exception e) {
        message = "Error loading users: " + e.getMessage();
        e.printStackTrace();
    }
    
    // Sort users by role and then username
    Collections.sort(users, new Comparator<User>() {
        @Override
        public int compare(User u1, User u2) {
            // First, sort by role with admin first
            if ("admin".equals(u1.getRole()) && !"admin".equals(u2.getRole())) {
                return -1;
            } else if (!"admin".equals(u1.getRole()) && "admin".equals(u2.getRole())) {
                return 1;
            } 
            
            // Then by role name
            int roleCompare = u1.getRole().compareTo(u2.getRole());
            if (roleCompare != 0) {
                return roleCompare;
            }
            
            // Finally by username
            return u1.getUsername().compareTo(u2.getUsername());
        }
    });
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - CarTrader Admin</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css">
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
        
        .role-badge {
            font-size: 0.75rem;
            padding: 0.25rem 0.5rem;
            border-radius: 10px;
        }
        
        .badge-admin {
            background-color: var(--admin-color);
            color: white;
        }
        
        .badge-seller {
            background-color: var(--secondary-color);
            color: white;
        }
        
        .badge-buyer {
            background-color: var(--primary-color);
            color: white;
        }
        
        .status-indicator {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 5px;
        }
        
        .status-active {
            background-color: var(--success-color);
            color: var(--success-color);
        }
        
        .status-inactive {
            background-color: var(--danger-color);
            color: var(--danger-color);
        }
        
        .action-btn {
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
        }
        
        .user-table th {
            font-weight: 600;
        }
        
        .search-container {
            position: relative;
            max-width: 300px;
        }
        
        .search-container .form-control {
            padding-left: 38px;
        }
        
        .search-icon {
            position: absolute;
            top: 50%;
            left: 13px;
            transform: translateY(-50%);
            color: #6c757d;
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
            <li class="nav-item active">
                <a class="nav-link active" href="user-management.jsp">
                    <i class="fas fa-users"></i> User Management
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="car-management.jsp">
                    <i class="fas fa-car"></i> Car Listings
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="AdminMyProfile.jsp">
                    <i class="fas fa-cog"></i> My Profile
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
                        <div class="fw-bold"><%= fullName %></div>
                        <small class="text-white-50"><%= username %></small>
                    </div>
                </a>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="AdminProfileServlet"><i class="fas fa-user me-2"></i>My Profile</a></li>
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
                <h2>User Management</h2>
                <div>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addUserModal">
                        <i class="fas fa-user-plus me-2"></i> Add New User
                    </button>
                </div>
            </div>
            
            <!-- Status Messages -->
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= success ? "success" : "danger" %> alert-dismissible fade show" role="alert">
                    <i class="fas fa-<%= success ? "check" : "exclamation" %>-circle me-2"></i> <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <!-- File Information -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">File Information</h5>
                </div>
                <div class="card-body">
                    <p><strong>Users File Path:</strong> <%= userFile %></p>
                    <p><strong>File Exists:</strong> <%= new File(userFile).exists() ? "Yes" : "No" %></p>
                    <p><strong>Users Loaded:</strong> <%= users.size() %></p>
                    
                    <!-- Role summary counts -->
                    <div class="mt-3">
                        <strong>User Roles:</strong>
                        <% 
                            int adminCount = 0;
                            int sellerCount = 0;
                            int buyerCount = 0;
                            int activeCount = 0;
                            int inactiveCount = 0;
                            
                            for (User user : users) {
                                if ("admin".equalsIgnoreCase(user.getRole())) {
                                    adminCount++;
                                } else if ("seller".equalsIgnoreCase(user.getRole())) {
                                    sellerCount++;
                                } else if ("buyer".equalsIgnoreCase(user.getRole())) {
                                    buyerCount++;
                                }
                                
                                if (user.isActive()) {
                                    activeCount++;
                                } else {
                                    inactiveCount++;
                                }
                            }
                        %>
                        <span class="badge badge-admin me-1">Admin: <%= adminCount %></span>
                        <span class="badge badge-seller me-1">Sellers: <%= sellerCount %></span>
                        <span class="badge badge-buyer me-1">Buyers: <%= buyerCount %></span>
                        <span class="badge bg-success me-1">Active: <%= activeCount %></span>
                        <span class="badge bg-danger">Inactive: <%= inactiveCount %></span>
                    </div>
                </div>
            </div>
            
            <!-- User List Card -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">All Users</h5>
                    <div class="search-container">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" id="userSearchInput" class="form-control" placeholder="Search users...">
                    </div>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table id="userTable" class="table table-striped table-hover user-table align-middle">
                            <thead>
                                <tr>
                                    <th>Username</th>
                                    <th>Full Name</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Role</th>
                                    <th>Status</th>
                                    <th>Registration Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (users.isEmpty()) { %>
                                    <tr>
                                        <td colspan="8" class="text-center">No users found.</td>
                                    </tr>
                                <% } else { %>
                                    <% for (User user : users) { %>
                                    <tr>
                                        <td><%= user.getUsername() %></td>
                                        <td><%= user.getFullName() %></td>
                                        <td><%= user.getEmail() %></td>
                                        <td><%= user.getPhone() != null ? user.getPhone() : "" %></td>
                                        <td>
                                            <% if ("admin".equalsIgnoreCase(user.getRole())) { %>
                                                <span class="badge role-badge badge-admin">Admin</span>
                                            <% } else if ("seller".equalsIgnoreCase(user.getRole())) { %>
                                                <span class="badge role-badge badge-seller">Seller</span>
                                            <% } else { %>
                                                <span class="badge role-badge badge-buyer">Buyer</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <% if (user.isActive()) { %>
                                                <span class="text-success"><i class="fas fa-check-circle me-1"></i> Active</span>
                                            <% } else { %>
                                                <span class="text-danger"><i class="fas fa-times-circle me-1"></i> Inactive</span>
                                            <% } %>
                                        </td>
                                        <td><%= user.getRegistrationDate() != null ? user.getRegistrationDate().split("\\(UTC\\)")[0].trim() : "N/A" %></td>
                                        <td>
                                            <div class="btn-group">
                                                <button class="btn btn-sm btn-outline-primary action-btn" 
                                                        onclick="viewUser('<%= user.getId() %>', '<%= user.getUsername() %>', '<%= user.getFullName() %>', '<%= user.getEmail() %>', '<%= user.getRole() %>', '<%= user.getPhone() %>', <%= user.isActive() %>)">
                                                    <i class="fas fa-eye" title="View User"></i>
                                                </button>
                                                
                                                <button class="btn btn-sm btn-outline-secondary action-btn" 
                                                        onclick="editUser('<%= user.getId() %>', '<%= user.getUsername() %>', '<%= user.getFullName() %>', '<%= user.getEmail() %>', '<%= user.getRole() %>', '<%= user.getPhone() %>', <%= user.hasNewsletterSubscription() %>, <%= user.isActive() %>)">
                                                    <i class="fas fa-edit" title="Edit User"></i>
                                                </button>
                                                
                                                <!-- Add activate/deactivate buttons based on current status -->
                                                <% if (user.isActive() && !"admin".equalsIgnoreCase(user.getRole())) { %>
                                                    <a href="user-management.jsp?action=deactivate&userid=<%= user.getId() %>" 
                                                       class="btn btn-sm btn-outline-warning action-btn"
                                                       onclick="return confirm('Are you sure you want to deactivate this user?')">
                                                        <i class="fas fa-user-slash" title="Deactivate User"></i>
                                                    </a>
                                                <% } else if (!user.isActive()) { %>
                                                    <a href="user-management.jsp?action=activate&userid=<%= user.getId() %>" 
                                                       class="btn btn-sm btn-outline-success action-btn"
                                                       onclick="return confirm('Are you sure you want to activate this user?')">
                                                        <i class="fas fa-user-check" title="Activate User"></i>
                                                    </a>
                                                <% } else if ("admin".equalsIgnoreCase(user.getRole())) { %>
                                                    <button class="btn btn-sm btn-outline-secondary action-btn" disabled title="Admin users cannot be deactivated">
                                                        <i class="fas fa-user-check"></i>
                                                    </button>
                                                <% } %>
                                                
                                                <% if (!"admin".equalsIgnoreCase(user.getRole())) { %>
                                                    <a href="user-management.jsp?action=delete&userid=<%= user.getId() %>" 
                                                       class="btn btn-sm btn-outline-danger action-btn"
                                                       onclick="return confirm('Are you sure you want to delete this user? This action cannot be undone.')">
                                                        <i class="fas fa-trash" title="Delete User"></i>
                                                    </a>
                                                <% } else { %>
                                                    <button class="btn btn-sm btn-outline-secondary action-btn" disabled title="Admin users cannot be deleted">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Footer -->
            <footer class="mt-4">
                <div class="text-center text-muted">
                    <p>&copy; 2025 CarTrader Administrative Panel. All rights reserved.</p>
                </div>
            </footer>
        </div>
    </div>
    
    <!-- Add User Modal -->
    <div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addUserModalLabel">Add New User</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="user-management.jsp" method="post">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="newUsername" class="form-label">Username</label>
                                <input type="text" class="form-control" id="newUsername" name="newUsername" required>
                                <div class="form-text">Username must be unique and at least 4 characters.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="newPassword" class="form-label">Password</label>
                                <input type="password" class="form-control" id="newPassword" name="newPassword" required>
                                <div class="form-text">Password must be at least 8 characters.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="newFullName" class="form-label">Full Name</label>
                                <input type="text" class="form-control" id="newFullName" name="newFullName" required>
                            </div>
                            <div class="col-md-6">
                                <label for="newEmail" class="form-label">Email</label>
                                <input type="email" class="form-control" id="newEmail" name="newEmail" required>
                            </div>
                            <div class="col-md-6">
                                <label for="newPhone" class="form-label">Phone</label>
                                <input type="text" class="form-control" id="newPhone" name="newPhone" placeholder="(123) 456-7890">
                            </div>
                            <div class="col-md-6">
                                <label for="newRole" class="form-label">User Role</label>
                                <select class="form-select" id="newRole" name="newRole" required>
                                    <option value="" selected disabled>Select a role</option>
                                    <option value="admin">Administrator</option>
                                    <option value="seller">Seller</option>
                                    <option value="buyer">Buyer</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <div class="form-check mt-4">
                                    <input class="form-check-input" type="checkbox" id="newActive" name="newActive" checked>
                                    <label class="form-check-label" for="newActive">
                                        Active Account
                                    </label>
                                    <div class="form-text">Inactive users cannot log in to the system.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Add User</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Edit User Modal -->
    <div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="editUserModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editUserModalLabel">Edit User</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="user-management.jsp" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" id="editUserId" name="editUserId" value="">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="editUsername" class="form-label">Username</label>
                                <input type="text" class="form-control" id="editUsername" name="editUsername" required>
                            </div>
                            <div class="col-md-6">
                                <label for="editPassword" class="form-label">Password</label>
                                <input type="password" class="form-control" id="editPassword" name="editPassword" placeholder="Leave blank to keep current password">
                                <div class="form-text">Only enter a new password if you want to change it.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="editFullName" class="form-label">Full Name</label>
                                <input type="text" class="form-control" id="editFullName" name="editFullName" required>
                            </div>
                            <div class="col-md-6">
                                <label for="editEmail" class="form-label">Email</label>
                                <input type="email" class="form-control" id="editEmail" name="editEmail" required>
                            </div>
                            <div class="col-md-6">
                                <label for="editPhone" class="form-label">Phone</label>
                                <input type="text" class="form-control" id="editPhone" name="editPhone">
                            </div>
                            <div class="col-md-6">
                                <label for="editRole" class="form-label">User Role</label>
                                <select class="form-select" id="editRole" name="editRole" required>
                                    <option value="admin">Administrator</option>
                                    <option value="seller">Seller</option>
                                    <option value="buyer">Buyer</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <div class="form-check mt-4">
                                    <input class="form-check-input" type="checkbox" id="editNewsletter" name="editNewsletter">
                                    <label class="form-check-label" for="editNewsletter">
                                        Newsletter Subscription
                                    </label>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-check mt-4">
                                    <input class="form-check-input" type="checkbox" id="editActive" name="editActive">
                                    <label class="form-check-label" for="editActive">
                                        Active Account
                                    </label>
                                    <div class="form-text">Inactive users cannot log in to the system.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- View User Modal -->
    <div class="modal fade" id="viewUserModal" tabindex="-1" aria-labelledby="viewUserModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="viewUserModalLabel">User Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="text-center mb-4">
                        <div class="user-avatar mx-auto" style="width: 80px; height: 80px; font-size: 32px; background-color: var(--admin-color);">
                            <span id="viewUserInitial"></span>
                        </div>
                        <h4 id="viewUserFullName" class="mt-3"></h4>
                        <div id="viewUserRoleBadge"></div>
                        <div id="viewUserStatus" class="mt-2"></div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Username:</label>
                        <div id="viewUserUsername"></div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Email:</label>
                        <div id="viewUserEmail"></div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Phone:</label>
                        <div id="viewUserPhone"></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="viewEditButton">Edit User</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- DataTables -->
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize DataTable with NO initial sorting
            // This will preserve our server-side sorting
            const userTable = $('#userTable').DataTable({
                "paging": true,
                "ordering": true,
                "info": true,
                "responsive": true,
                "lengthMenu": [10, 25, 50, 100],
                // Removed the initial order so it uses our server-side sort
                "order": [],
                "language": {
                    "search": "Filter records:",
                    "lengthMenu": "Show _MENU_ users per page",
                    "zeroRecords": "No matching users found",
                    "info": "Showing _START_ to _END_ of _TOTAL_ users",
                    "infoEmpty": "No users available",
                    "infoFiltered": "(filtered from _MAX_ total users)"
                }
            });
            
            // Connect the custom search box to DataTable
            $('#userSearchInput').on('keyup', function() {
                userTable.search(this.value).draw();
            });
            
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
        });
        
        // Function to populate and show edit user modal
        function editUser(id, username, fullName, email, role, phone, newsletter, isActive) {
            document.getElementById('editUserId').value = id;
            document.getElementById('editUsername').value = username;
            document.getElementById('editFullName').value = fullName;
            document.getElementById('editEmail').value = email;
            document.getElementById('editRole').value = role;
            document.getElementById('editPhone').value = phone;
            document.getElementById('editNewsletter').checked = newsletter;
            document.getElementById('editActive').checked = isActive;
            
            // If editing admin user, disable role change and active checkbox
            if (role === 'admin') {
                document.getElementById('editRole').disabled = true;
                document.getElementById('editActive').disabled = true;
            } else {
                document.getElementById('editRole').disabled = false;
                document.getElementById('editActive').disabled = false;
            }
            
            // Show the modal
            new bootstrap.Modal(document.getElementById('editUserModal')).show();
        }
        
        // Function to populate and show view user modal
        function viewUser(id, username, fullName, email, role, phone, isActive) {
            // Set user data in the modal
            document.getElementById('viewUserFullName').textContent = fullName;
            document.getElementById('viewUserUsername').textContent = username;
            document.getElementById('viewUserEmail').textContent = email;
            document.getElementById('viewUserPhone').textContent = phone || 'Not provided';
            document.getElementById('viewUserInitial').textContent = fullName.charAt(0).toUpperCase();
            
            // Set user status
            document.getElementById('viewUserStatus').innerHTML = isActive ? 
                '<span class="badge bg-success">Active</span>' : 
                '<span class="badge bg-danger">Inactive</span>';
            
            // Set role badge
            let roleBadgeHTML = '';
            if (role === 'admin') {
                roleBadgeHTML = '<span class="badge role-badge badge-admin">Administrator</span>';
            } else if (role === 'seller') {
                roleBadgeHTML = '<span class="badge role-badge badge-seller">Seller</span>';
            } else {
                roleBadgeHTML = '<span class="badge role-badge badge-buyer">Buyer</span>';
            }
            document.getElementById('viewUserRoleBadge').innerHTML = roleBadgeHTML;
            
            // Set up edit button
            document.getElementById('viewEditButton').onclick = function() {
                // Close view modal
                bootstrap.Modal.getInstance(document.getElementById('viewUserModal')).hide();
                // Open edit modal with newsletter default to false since we don't have it in the view
                editUser(id, username, fullName, email, role, phone, false, isActive);
            };
            
            // Show the modal
            new bootstrap.Modal(document.getElementById('viewUserModal')).show();
        }
    </script>
</body>
</html>