<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carpurchase.model.User" %>
<%@ page import="java.util.*" %>

<%
    // Check if user is logged in as a buyer
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");
    String userRole = (String) session.getAttribute("userRole");
    String userId = (String) session.getAttribute("userId");
    
    if(username == null || !userRole.equalsIgnoreCase("buyer")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get user from request
    User userDetail = (User) request.getAttribute("userDetail");
    
    // Get any messages
    String message = (String) request.getAttribute("message");
    Boolean success = (Boolean) request.getAttribute("success");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Settings - CarTrader</title>
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
        
        .dashboard-header {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }
        
        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: transform 0.3s, box-shadow 0.3s;
            margin-bottom: 20px;
        }
        
        .card:hover {
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .card-header {
            border-bottom: none;
            background: white;
            font-weight: 600;
            padding: 20px;
            border-radius: 10px 10px 0 0 !important;
        }
        
        .card-body {
            padding: 20px;
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
        
        .settings-nav {
            display: flex;
            flex-wrap: wrap;
            border-bottom: 1px solid #dee2e6;
            margin-bottom: 20px;
        }
        
        .settings-link {
            padding: 10px 15px;
            margin-right: 10px;
            border-bottom: 2px solid transparent;
            color: #495057;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.3s;
            cursor: pointer;
        }
        
        .settings-link:hover, .settings-link.active {
            color: var(--primary-color);
            border-bottom-color: var(--primary-color);
        }
        
        .settings-link i {
            margin-right: 6px;
        }
        
        .form-label {
            font-weight: 500;
            margin-bottom: 0.5rem;
        }
        
        .user-welcome {
            display: flex;
            align-items: center;
        }
        
        .user-info h4 {
            margin-bottom: 0;
            font-weight: 600;
        }
        
        .user-info p {
            margin-bottom: 0;
            color: #6c757d;
        }
        
        .dropdown-menu {
            border: none;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            border-radius: 10px;
        }
        
        .dropdown-item {
            padding: 10px 20px;
            font-size: 14px;
        }
        
        .dropdown-item i {
            margin-right: 10px;
            color: #6c757d;
        }
        
        .dropdown-divider {
            margin: 5px 0;
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
        
        /* Animation classes */
        .fade-in {
            animation: fadeIn 0.5s ease forwards;
        }
        
        @keyframes fadeIn {
            0% {
                opacity: 0;
            }
            100% {
                opacity: 1;
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
                <a class="nav-link" href="buyer-dashboard.jsp">
                    <i class="fas fa-tachometer-alt"></i> Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="browse-cars.jsp">
                    <i class="fas fa-search"></i> Browse Cars
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="SavedCarsServlet">
                    <i class="fas fa-heart"></i> Saved Cars
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="InquiryServlet">
                    <i class="fas fa-clipboard-list"></i> My Inquiries
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="#">
                    <i class="fas fa-history"></i> Purchase History
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="UserSettingsServlet">
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
                    <li><a class="dropdown-item" href="UserSettingsServlet"><i class="fas fa-user"></i> My Profile</a></li>
                    <li><a class="dropdown-item" href="UserSettingsServlet"><i class="fas fa-cog"></i> Account Settings</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                </ul>
            </div>
        </div>
    </div>
    
    <!-- Content -->
    <div class="content">
        <div class="container-fluid">
            <!-- Header with welcome message -->
            <div class="row mb-4">
                <div class="col-md-12">
                    <div class="dashboard-header">
                        <div class="d-flex justify-content-between align-items-center flex-wrap">
                            <div class="user-welcome mb-3 mb-md-0">
                                <div class="user-avatar">
                                    <%= fullName.substring(0, 1).toUpperCase() %>
                                </div>
                                <div class="user-info">
                                    <h4>Account Settings</h4>
                                    <p>Manage your profile and security settings</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Display Messages -->
            <% if (message != null) { %>
                <div class="alert alert-<%= success ? "success" : "danger" %> alert-dismissible fade show" role="alert">
                    <strong><i class="fas <%= success ? "fa-check-circle" : "fa-exclamation-triangle" %> me-2"></i></strong>
                    <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            
            <!-- Settings navigation -->
            <div class="settings-nav">
                <a id="profileTab" class="settings-link active" role="button">
                    <i class="fas fa-user"></i> Profile
                </a>
                <a id="securityTab" class="settings-link" role="button">
                    <i class="fas fa-lock"></i> Security
                </a>
            </div>
            
            <!-- Settings content -->
            <div class="tab-content">
                <!-- Profile Settings -->
                <div class="tab-pane fade show active" id="profile">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0">Personal Information</h5>
                        </div>
                        <div class="card-body">
                            <form action="UserSettingsServlet" method="post">
                                <input type="hidden" name="action" value="updateProfile">
                                <input type="hidden" name="userId" value="<%= userDetail.getUserId() %>">
                                
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="username" class="form-label">Username</label>
                                        <input type="text" class="form-control" id="username" value="<%= userDetail.getUsername() %>" readonly>
                                        <div class="form-text text-muted">Username cannot be changed</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="userId" class="form-label">User ID</label>
                                        <input type="text" class="form-control" id="userId" value="<%= userDetail.getUserId() %>" readonly>
                                    </div>
                                </div>
                                
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="fullName" class="form-label">Full Name</label>
                                        <input type="text" class="form-control" id="fullName" name="fullName" value="<%= userDetail.getFullName() %>" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="email" class="form-label">Email Address</label>
                                        <input type="email" class="form-control" id="email" name="email" value="<%= userDetail.getEmail() %>" required>
                                    </div>
                                </div>
                                
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="phone" class="form-label">Phone Number</label>
                                        <input type="tel" class="form-control" id="phone" name="phone" value="<%= userDetail.getPhone() != null ? userDetail.getPhone() : "" %>">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="registrationDate" class="form-label">Registration Date</label>
                                        <input type="text" class="form-control" id="registrationDate" value="<%= userDetail.getRegistrationDate() %>" readonly>
                                    </div>
                                </div>
                                
                                <div class="row">
                                    <div class="col-12">
                                        <button type="submit" class="btn btn-primary">Save Changes</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                
                <!-- Security Settings -->
                <div class="tab-pane fade" id="security">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0">Change Password</h5>
                        </div>
                        <div class="card-body">
                            <form action="UserSettingsServlet" method="post">
                                <input type="hidden" name="action" value="updatePassword">
                                <input type="hidden" name="userId" value="<%= userDetail.getUserId() %>">
                                
                                <div class="mb-3">
                                    <label for="currentPassword" class="form-label">Current Password</label>
                                    <input type="password" class="form-control" id="currentPassword" name="currentPassword" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="newPassword" class="form-label">New Password</label>
                                    <input type="password" class="form-control" id="newPassword" name="newPassword" required>
                                    <div class="form-text text-muted">Password must be at least 6 characters</div>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="confirmPassword" class="form-label">Confirm New Password</label>
                                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                                </div>
                                
                                <div>
                                    <button type="submit" class="btn btn-primary">Update Password</button>
                                </div>
                            </form>
                        </div>
                    </div>
                    
                    <div class="card mt-4">
                        <div class="card-header">
                            <h5 class="mb-0">Account Status</h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <p>Account Status: 
                                    <span class="badge bg-<%= "yes".equalsIgnoreCase(userDetail.getActive()) ? "success" : "danger" %>">
                                        <%= "yes".equalsIgnoreCase(userDetail.getActive()) ? "Active" : "Inactive" %>
                                    </span>
                                </p>
                                <p>Account Type: 
                                    <span class="badge bg-primary">
                                        <%= userDetail.getRole() %>
                                    </span>
                                </p>
                            </div>
                            
                            <div class="alert alert-warning">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                If you wish to deactivate your account, please contact our support team.
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Footer -->
            <footer class="mt-4">
                <div class="text-center text-muted">
                    <p>&copy; 2025 CarTrader. All rights reserved.</p>
                </div>
            </footer>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const toggleSidebarBtn = document.getElementById('toggleSidebar');
            const sidebar = document.querySelector('.sidebar');
            const content = document.querySelector('.content');
            
            // Tab functionality
            const profileTab = document.getElementById('profileTab');
            const securityTab = document.getElementById('securityTab');
            const profilePane = document.getElementById('profile');
            const securityPane = document.getElementById('security');
            
            // Function to show profile tab
            const showProfileTab = function() {
                // Update active tab
                profileTab.classList.add('active');
                securityTab.classList.remove('active');
                
                // Show/hide content
                profilePane.classList.add('show', 'active');
                securityPane.classList.remove('show', 'active');
            };
            
            // Function to show security tab
            const showSecurityTab = function() {
                // Update active tab
                profileTab.classList.remove('active');
                securityTab.classList.add('active');
                
                // Show/hide content
                profilePane.classList.remove('show', 'active');
                securityPane.classList.add('show', 'active');
            };
            
            // Add click events to tabs
            profileTab.addEventListener('click', showProfileTab);
            securityTab.addEventListener('click', showSecurityTab);
            
            // Toggle sidebar on mobile
            toggleSidebarBtn.addEventListener('click', function() {
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
            
            // Auto-close alerts after 5 seconds
            setTimeout(function() {
                const alerts = document.querySelectorAll('.alert');
                alerts.forEach(function(alert) {
                    const bsAlert = bootstrap.Alert.getOrCreateInstance(alert);
                    bsAlert.close();
                });
            }, 5000);
            
            // Form validation
            const forms = document.querySelectorAll('form');
            Array.from(forms).forEach(function (form) {
                form.addEventListener('submit', function (event) {
                    if (!form.checkValidity()) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                }, false);
            });
            
            // Password match validation
            const newPasswordInput = document.getElementById('newPassword');
            const confirmPasswordInput = document.getElementById('confirmPassword');
            
            if (newPasswordInput && confirmPasswordInput) {
                confirmPasswordInput.addEventListener('input', function() {
                    if (newPasswordInput.value !== this.value) {
                        this.setCustomValidity('Passwords do not match');
                    } else {
                        this.setCustomValidity('');
                    }
                });
                
                newPasswordInput.addEventListener('input', function() {
                    if (confirmPasswordInput.value && this.value !== confirmPasswordInput.value) {
                        confirmPasswordInput.setCustomValidity('Passwords do not match');
                    } else {
                        confirmPasswordInput.setCustomValidity('');
                    }
                });
            }
            
            // Car favorite toggle (if needed)
            const favoriteButtons = document.querySelectorAll('.car-favorite');
            favoriteButtons.forEach(function(btn) {
                btn.addEventListener('click', function() {
                    btn.classList.toggle('active');
                    const icon = btn.querySelector('i');
                    if (btn.classList.contains('active')) {
                        icon.classList.remove('far');
                        icon.classList.add('fas');
                    } else {
                        icon.classList.remove('fas');
                        icon.classList.add('far');
                    }
                });
            });
        });
    </script>
</body>
</html>