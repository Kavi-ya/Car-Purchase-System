<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");
    String userRole = (String) session.getAttribute("userRole");
    
    if(username == null || !userRole.equalsIgnoreCase("seller")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Dashboard - CarTrader</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
            transform: translateY(-5px);
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
        
        .stats-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }
        
        .stats-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        
        .stats-details h3 {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .stats-details p {
            font-size: 14px;
            margin-bottom: 0;
            color: #6c757d;
        }
        
        .primary-bg {
            background-color: rgba(58, 134, 255, 0.1);
            color: var(--primary-color);
        }
        
        .success-bg {
            background-color: rgba(56, 176, 0, 0.1);
            color: var(--success-color);
        }
        
        .warning-bg {
            background-color: rgba(255, 190, 11, 0.1);
            color: var(--warning-color);
        }
        
        .danger-bg {
            background-color: rgba(217, 4, 41, 0.1);
            color: var(--danger-color);
        }
        
        .car-card {
            overflow: hidden;
            position: relative;
        }
        
        .car-image {
            height: 180px;
            background-size: cover;
            background-position: center;
            border-radius: 10px 10px 0 0;
            position: relative;
        }
        
        .car-badge {
            position: absolute;
            top: 10px;
            left: 10px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .car-price {
            position: absolute;
            bottom: 10px;
            right: 10px;
            background: rgba(0,0,0,0.7);
            color: white;
            padding: 5px 10px;
            border-radius: 5px;
            font-weight: 600;
        }
        
        .car-status {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 5px 10px;
            border-radius: 5px;
            font-weight: 600;
            font-size: 12px;
            text-transform: uppercase;
        }
        
        .status-active {
            background-color: var(--success-color);
            color: white;
        }
        
        .status-pending {
            background-color: var(--warning-color);
            color: white;
        }
        
        .status-sold {
            background-color: var(--danger-color);
            color: white;
        }
        
        .car-details h5 {
            font-weight: 600;
            margin-bottom: 5px;
        }
        
        .car-details p {
            font-size: 14px;
            color: #6c757d;
            margin-bottom: 10px;
        }
        
        .car-stats {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            font-size: 13px;
        }
        
        .car-stat {
            display: flex;
            align-items: center;
        }
        
        .car-stat i {
            margin-right: 5px;
            color: var(--primary-color);
        }
        
        .listing-actions {
            display: flex;
            gap: 5px;
        }
        
        .search-form {
            position: relative;
            margin-bottom: 20px;
        }
        
        .search-form .form-control {
            padding-left: 40px;
            border-radius: 30px;
            border: none;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            height: 50px;
        }
        
        .search-form .search-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #6c757d;
        }
        
        .user-welcome {
            display: flex;
            align-items: center;
        }
        
        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background-color: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            margin-right: 15px;
        }
        
        .user-info h4 {
            margin-bottom: 0;
            font-weight: 600;
        }
        
        .user-info p {
            margin-bottom: 0;
            color: #6c757d;
        }
        
        .notification-item {
            padding: 15px;
            border-bottom: 1px solid #eee;
            transition: all 0.3s;
        }
        
        .notification-item:hover {
            background-color: rgba(58, 134, 255, 0.05);
        }
        
        .notification-item:last-child {
            border-bottom: none;
        }
        
        .notification-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background-color: var(--primary-color);
            position: absolute;
            top: 5px;
            right: 5px;
        }
        
        .inquiry-item {
            padding: 15px;
            border-bottom: 1px solid #eee;
            transition: all 0.3s;
        }
        
        .inquiry-item:hover {
            background-color: rgba(58, 134, 255, 0.05);
        }
        
        .inquiry-item:last-child {
            border-bottom: none;
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
        }
        
        .user-menu img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            margin-right: 10px;
        }
        
        .user-menu .dropdown-toggle::after {
            display: none;
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
        
        .btn-floating {
            position: fixed;
            bottom: 30px;
            right: 30px;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.2);
            transition: transform 0.3s, box-shadow 0.3s;
            z-index: 999;
        }
        
        .btn-floating:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            color: white;
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
            <li class="nav-item active">
                <a class="nav-link active" href="seller-dashboard.jsp">
                    <i class="fas fa-tachometer-alt"></i> Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="my-listing.jsp">
                    <i class="fas fa-list"></i> My Listings
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="add-listing.jsp">
                    <i class="fas fa-plus-circle"></i> Add New Listing
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="inquiries.jsp">
                    <i class="fas fa-envelope"></i> Inquiries
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="UserSettingsServlet">
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
                                    <h4>Welcome back, <%= fullName %>!</h4>
                                    <p>Here's what's happening with your vehicle listings today.</p>
                                </div>
                            </div>
                            
                            <div class="btn-group">
                                <a href="add-listing.jsp" class="btn btn-primary">
                                    <i class="fas fa-plus-circle me-2"></i> Add New Listing
                                </a>
                                <a href="#" class="btn btn-outline-secondary ms-2">
                                    <i class="fas fa-download me-2"></i> Export Report
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Stats cards -->
            <div class="row">
                <div class="col-md-3 col-sm-6">
                    <div class="stats-card">
                        <div class="stats-details">
                            <h3>12</h3>
                            <p>Active Listings</p>
                        </div>
                        <div class="stats-icon primary-bg">
                            <i class="fas fa-car"></i>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3 col-sm-6">
                    <div class="stats-card">
                        <div class="stats-details">
                            <h3>842</h3>
                            <p>Total Views</p>
                        </div>
                        <div class="stats-icon success-bg">
                            <i class="fas fa-eye"></i>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3 col-sm-6">
                    <div class="stats-card">
                        <div class="stats-details">
                            <h3>28</h3>
                            <p>Inquiries</p>
                        </div>
                        <div class="stats-icon warning-bg">
                            <i class="fas fa-envelope"></i>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3 col-sm-6">
                    <div class="stats-card">
                        <div class="stats-details">
                            <h3>5</h3>
                            <p>Sales This Month</p>
                        </div>
                        <div class="stats-icon danger-bg">
                            <i class="fas fa-dollar-sign"></i>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Performance Chart -->
            <div class="row mt-4">
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">
                            Listing Performance
                        </div>
                        <div class="card-body">
                            <canvas id="performanceChart" height="300"></canvas>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">
                            Listing Distribution
                        </div>
                        <div class="card-body">
                            <canvas id="distributionChart" height="300"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Your active listings -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <div>Your Active Listings</div>
                            <a href="#" class="btn btn-sm btn-primary">Manage All</a>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle">
                                    <thead>
                                        <tr>
                                            <th>Listing</th>
                                            <th>Price</th>
                                            <th>Views</th>
                                            <th>Inquiries</th>
                                            <th>Status</th>
                                            <th>Listed Date</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <img src="https://images.unsplash.com/photo-1494976388531-d1058494cdd8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=120&q=80" class="rounded me-3" style="width: 60px; height: 40px; object-fit: cover;">
                                                    <div>
                                                        <h6 class="mb-0">2023 Ford Mustang GT</h6>
                                                        <small class="text-muted">Premium Package</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>LKR 32,50000</td>
                                            <td>245</td>
                                            <td>8</td>
                                            <td><span class="badge bg-success">Active</span></td>
                                            <td>Mar 15, 2025</td>
                                            <td>
                                                <div class="listing-actions">
                                                    <a href="#" class="btn btn-sm btn-outline-primary" data-bs-toggle="tooltip" title="Edit"><i class="fas fa-edit"></i></a>
                                                    <a href="#" class="btn btn-sm btn-outline-success" data-bs-toggle="tooltip" title="View Inquiries"><i class="fas fa-envelope"></i></a>
                                                    <a href="#" class="btn btn-sm btn-outline-warning" data-bs-toggle="tooltip" title="Promote"><i class="fas fa-ad"></i></a>
                                                    <a href="#" class="btn btn-sm btn-outline-danger" data-bs-toggle="tooltip" title="Remove"><i class="fas fa-trash-alt"></i></a>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <img src="https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=120&q=80" class="rounded me-3" style="width: 60px; height: 40px; object-fit: cover;">
                                                    <div>
                                                        <h6 class="mb-0">2022 Honda Accord Sport</h6>
                                                        <small class="text-muted">Low miles, One owner</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>LKR 2008,900</td>
                                            <td>189</td>
                                            <td>12</td>
                                            <td><span class="badge bg-success">Active</span></td>
                                            <td>Mar 24, 2025</td>
                                            <td>
                                                <div class="listing-actions">
                                                    <a href="#" class="btn btn-sm btn-outline-primary" data-bs-toggle="tooltip" title="Edit"><i class="fas fa-edit"></i></a>
                                                    <a href="#" class="btn btn-sm btn-outline-success" data-bs-toggle="tooltip" title="View Inquiries"><i class="fas fa-envelope"></i></a>
                                                    <a href="#" class="btn btn-sm btn-outline-warning" data-bs-toggle="tooltip" title="Promote"><i class="fas fa-ad"></i></a>
                                                    <a href="#" class="btn btn-sm btn-outline-danger" data-bs-toggle="tooltip" title="Remove"><i class="fas fa-trash-alt"></i></a>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <img src="https://images.unsplash.com/photo-1580273916550-e323be2ae537?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=120&q=80" class="rounded me-3" style="width: 60px; height: 40px; object-fit: cover;">
                                                    <div>
                                                        <h6 class="mb-0">2023 Tesla Model 3</h6>
                                                        <small class="text-muted">Long Range, Full Self-Driving</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>LKR 5009,700</td>
                                            <td>408</td>
                                            <td>18</td>
                                            <td><span class="badge bg-success">Active</span></td>
                                            <td>Apr 2, 2025</td>
                                            <td>
                                                <div class="listing-actions">
                                                    <a href="#" class="btn btn-sm btn-outline-primary" data-bs-toggle="tooltip" title="Edit"><i class="fas fa-edit"></i></a>
                                                    <a href="#" class="btn btn-sm btn-outline-success" data-bs-toggle="tooltip" title="View Inquiries"><i class="fas fa-envelope"></i></a>
                                                    <a href="#" class="btn btn-sm btn-outline-warning" data-bs-toggle="tooltip" title="Promote"><i class="fas fa-ad"></i></a>
                                                    <a href="#" class="btn btn-sm btn-outline-danger" data-bs-toggle="tooltip" title="Remove"><i class="fas fa-trash-alt"></i></a>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Recent inquiries and notifications -->
            <div class="row mt-4">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <div>Recent Inquiries</div>
                            <a href="#" class="btn btn-sm btn-primary">View All</a>
                        </div>
                        <div class="card-body p-0">
                            <div class="inquiry-item position-relative">
                                <div class="notification-dot"></div>
                                <div class="d-flex justify-content-between">
                                    <h6 class="mb-1">John Smith</h6>
                                    <small class="text-muted">2 hours ago</small>
                                </div>
                                <p class="mb-1">Interested in your 2023 Ford Mustang GT. Is it still available?</p>
                                <div class="d-flex justify-content-between align-items-center">
                                    <small class="text-muted">For: 2023 Ford Mustang GT</small>
                                    <a href="#" class="btn btn-sm btn-outline-primary">Reply</a>
                                </div>
                            </div>
                            
                            <div class="inquiry-item position-relative">
                                <div class="notification-dot"></div>
                                <div class="d-flex justify-content-between">
                                    <h6 class="mb-1">Emily Johnson</h6>
                                    <small class="text-muted">5 hours ago</small>
                                </div>
                                <p class="mb-1">Would you accept LKR 26,50000 for the Honda Accord?</p>
                                <div class="d-flex justify-content-between align-items-center">
                                    <small class="text-muted">For: 2022 Honda Accord Sport</small>
                                    <a href="#" class="btn btn-sm btn-outline-primary">Reply</a>
                                </div>
                            </div>
                            
                            <div class="inquiry-item">
                                <div class="d-flex justify-content-between">
                                    <h6 class="mb-1">Michael Brown</h6>
                                    <small class="text-muted">Yesterday</small>
                                </div>
                                <p class="mb-1">I'd like to schedule a test drive for the Tesla this weekend.</p>
                                <div class="d-flex justify-content-between align-items-center">
                                    <small class="text-muted">For: 2023 Tesla Model 3</small>
                                    <a href="#" class="btn btn-sm btn-outline-primary">Reply</a>
                                </div>
                            </div>
                            
                            <div class="text-center p-3">
                                <a href="#" class="btn btn-sm btn-outline-primary">View All Inquiries</a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <div>Recent Activities</div>
                            <a href="#" class="btn btn-sm btn-primary">View All</a>
                        </div>
                        <div class="card-body p-0">
                            <div class="notification-item">
                                <div class="d-flex justify-content-between">
                                    <h6 class="mb-1">Listing Promoted</h6>
                                    <small class="text-muted">3 hours ago</small>
                                </div>
                                <p class="mb-1">Your listing "2023 Tesla Model 3" has been promoted to featured status.</p>
                            </div>
                            
                            <div class="notification-item">
                                <div class="d-flex justify-content-between">
                                    <h6 class="mb-1">Price Update Recommended</h6>
                                    <small class="text-muted">Yesterday</small>
                                </div>
                                <p class="mb-1">Based on market analysis, we recommend reducing the price of "2022 Honda Accord Sport" by LKR 800,200.</p>
                            </div>
                            
                            <div class="notification-item">
                                <div class="d-flex justify-content-between">
                                    <h6 class="mb-1">Listing Anniversary</h6>
                                    <small class="text-muted">3 days ago</small>
                                </div>
                                <p class="mb-1">Your "2023 Ford Mustang GT" listing has been active for 30 days. Consider refreshing it.</p>
                            </div>
                            
                            <div class="notification-item">
                                <div class="d-flex justify-content-between">
                                    <h6 class="mb-1">System Notification</h6>
                                    <small class="text-muted">Apr 1, 2025</small>
                                </div>
                                <p class="mb-1">Your premium seller subscription will renew automatically on April 15, 2025.</p>
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
    
    <!-- Add New Listing Button -->
    <a href="#" class="btn-floating">
        <i class="fas fa-plus"></i>
    </a>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const toggleSidebarBtn = document.getElementById('toggleSidebar');
            const sidebar = document.querySelector('.sidebar');
            const content = document.querySelector('.content');
            
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
            
            // Initialize tooltips
            const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
            [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
            
            // Performance Chart
            const performanceCtx = document.getElementById('performanceChart').getContext('2d');
            const performanceChart = new Chart(performanceCtx, {
                type: 'line',
                data: {
                    labels: ['Mar 1', 'Mar 5', 'Mar 10', 'Mar 15', 'Mar 20', 'Mar 25', 'Apr 1', 'Apr 5'],
                    datasets: [{
                        label: 'Views',
                        data: [125, 210, 310, 245, 320, 350, 400, 450],
                        borderColor: '#3a86ff',
                        backgroundColor: 'rgba(58, 134, 255, 0.1)',
                        tension: 0.4,
                        fill: true
                    }, {
                        label: 'Inquiries',
                        data: [8, 12, 18, 15, 22, 24, 28, 30],
                        borderColor: '#ff006e',
                        backgroundColor: 'rgba(255, 0, 110, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        title: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
            
            // Distribution Chart
            const distributionCtx = document.getElementById('distributionChart').getContext('2d');
            const distributionChart = new Chart(distributionCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Sedans', 'SUVs', 'Trucks', 'Sports Cars', 'Electric'],
                    datasets: [{
                        data: [3, 4, 1, 2, 2],
                        backgroundColor: [
                            '#3a86ff',
                            '#ff006e',
                            '#38b000',
                            '#ffbe0b',
                            '#9d4edd'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'bottom',
                        }
                    }
                }
            });
        });
    </script>
</body>
</html>