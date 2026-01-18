<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");
    String userRole = (String) session.getAttribute("userRole");
    
    if(username == null || !userRole.equalsIgnoreCase("buyer")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Buyer Dashboard - CarTrader</title>
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
        
        .car-favorite {
            position: absolute;
            top: 10px;
            right: 10px;
            background: white;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
        
        .car-favorite i {
            color: #6c757d;
            transition: all 0.3s;
        }
        
        .car-favorite:hover i {
            color: var(--danger-color);
        }
        
        .car-favorite.active i {
            color: var(--danger-color);
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
        
        .car-features {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        
        .car-feature {
            display: flex;
            align-items: center;
            font-size: 13px;
            color: #6c757d;
        }
        
        .car-feature i {
            margin-right: 5px;
            color: var(--primary-color);
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
                <a class="nav-link active" href="buyer-dashboard.jsp">
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
                <a class="nav-link" href="UserSettingsServlet">
                    <i class="fas fa-cog"></i> Settings
                </a>
            </li>
        </ul>
        
        <div class="sidebar-bottom">
            <div class="dropdown">
                <a href="#" class="user-menu dropdown-toggle" data-bs-toggle="dropdown">
                    <div class="user-avatar">
                    </div>
                    <div>
                        <div class="fw-bold"><%= fullName %></div>
                        <small class="text-muted"><%= username %></small>
                    </div>
                </a>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="#"><i class="fas fa-user"></i> My Profile</a></li>
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
            <!-- Header with welcome message and search -->
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
                                    <p>Here's what's happening with your car search today.</p>
                                </div>
                            </div>
                            
                            <div class="search-wrapper">
                                <form class="search-form">
                                    <i class="fas fa-search search-icon"></i>
                                    <input type="text" class="form-control" placeholder="Search for cars, brands, or models...">
                                </form>
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
                            <h3>24</h3>
                            <p>Saved Cars</p>
                        </div>
                        <div class="stats-icon primary-bg">
                            <i class="fas fa-heart"></i>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3 col-sm-6">
                    <div class="stats-card">
                        <div class="stats-details">
                            <h3>8</h3>
                            <p>Active Inquiries</p>
                        </div>
                        <div class="stats-icon success-bg">
                            <i class="fas fa-comment-dots"></i>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3 col-sm-6">
                    <div class="stats-card">
                        <div class="stats-details">
                            <h3>2</h3>
                            <p>Scheduled Test Drives</p>
                        </div>
                        <div class="stats-icon warning-bg">
                            <i class="fas fa-calendar-check"></i>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3 col-sm-6">
                    <div class="stats-card">
                        <div class="stats-details">
                            <h3>5</h3>
                            <p>Recent Views</p>
                        </div>
                        <div class="stats-icon danger-bg">
                            <i class="fas fa-eye"></i>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Recently added cars -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <div>Recently Added Cars</div>
                            <a href="#" class="btn btn-sm btn-primary">View All</a>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-4 mb-4 mb-md-0">
                                    <div class="card car-card h-100">
                                        <div class="car-image" style="background-image: url('https://images.unsplash.com/photo-1494976388531-d1058494cdd8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1650&q=80');">
                                            <div class="car-price">LKR 3200,000</div>
                                            <div class="car-favorite">
                                                <i class="far fa-heart"></i>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <div class="car-details">
                                                <h5>2023 Ford Mustang GT</h5>
                                                <p>Premium Package, Excellent Condition</p>
                                                <div class="car-features">
                                                    <span class="car-feature"><i class="fas fa-tachometer-alt"></i> 15,230 mi</span>
                                                    <span class="car-feature"><i class="fas fa-gas-pump"></i> Petrol</span>
                                                    <span class="car-feature"><i class="fas fa-cog"></i> Automatic</span>
                                                </div>
                                            </div>
                                            <a href="#" class="btn btn-primary btn-sm w-100">View Details</a>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="col-md-4 mb-4 mb-md-0">
                                    <div class="card car-card h-100">
                                        <div class="car-image" style="background-image: url('https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1650&q=80');">
                                            <div class="car-price">LKR 2800,000</div>
                                            <div class="car-favorite">
                                                <i class="far fa-heart"></i>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <div class="car-details">
                                                <h5>2022 Honda Accord Sport</h5>
                                                <p>Low miles, One owner, Like new</p>
                                                <div class="car-features">
                                                    <span class="car-feature"><i class="fas fa-tachometer-alt"></i> 8,765 mi</span>
                                                    <span class="car-feature"><i class="fas fa-gas-pump"></i> Hybrid</span>
                                                    <span class="car-feature"><i class="fas fa-cog"></i> CVT</span>
                                                </div>
                                            </div>
                                            <a href="#" class="btn btn-primary btn-sm w-100">View Details</a>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="col-md-4">
                                    <div class="card car-card h-100">
                                        <div class="car-image" style="background-image: url('https://images.unsplash.com/photo-1580273916550-e323be2ae537?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1650&q=80');">
                                            <div class="car-price">LKR 2500,000</div>
                                            <div class="car-favorite">
                                                <i class="far fa-heart"></i>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <div class="car-details">
                                                <h5>2023 Tesla Model 3</h5>
                                                <p>Long Range, Full Self-Driving</p>
                                                <div class="car-features">
                                                    <span class="car-feature"><i class="fas fa-tachometer-alt"></i> 3,450 mi</span>
                                                    <span class="car-feature"><i class="fas fa-bolt"></i> Electric</span>
                                                    <span class="car-feature"><i class="fas fa-cog"></i> Auto</span>
                                                </div>
                                            </div>
                                            <a href="#" class="btn btn-primary btn-sm w-100">View Details</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-4">
                                    <div class="card car-card h-100">
                                        <div class="car-image" style="background-image: url('https://images.unsplash.com/photo-1555652736-e92021d28a10?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D');">
                                            <div class="car-price">LKR 3000,000</div>
                                            <div class="car-favorite">
                                                <i class="far fa-heart"></i>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <div class="car-details">
                                                <h5>Audi A8 2022</h5>
                                                <p>Excellent Condition</p>
                                                <div class="car-features">
                                                    <span class="car-feature"><i class="fas fa-tachometer-alt"></i> 3500 mi</span>
                                                    <span class="car-feature"><i class="fas fa-bolt"></i> Petrol</span>
                                                    <span class="car-feature"><i class="fas fa-cog"></i> Auto</span>
                                                </div>
                                            </div>
                                            <a href="#" class="btn btn-primary btn-sm w-100">View Details</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Your notifications and recommended cars -->
            <div class="row mt-4">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">Recent Notifications</div>
                        <div class="card-body p-0">
                            <div class="notification-item position-relative">
                                <div class="notification-dot"></div>
                                <h6 class="mb-1">Price Drop Alert</h6>
                                <p class="mb-1">2021 BMW X5 price reduced by $2,500</p>
                                <small class="text-muted">2 hours ago</small>
                            </div>
                            
                            <div class="notification-item">
                                <h6 class="mb-1">New Match</h6>
                                <p class="mb-1">A new car matching your search criteria has been listed</p>
                                <small class="text-muted">Yesterday</small>
                            </div>
                            
                            <div class="notification-item">
                                <h6 class="mb-1">Inquiry Response</h6>
                                <p class="mb-1">Seller responded to your inquiry about 2022 Audi Q5</p>
                                <small class="text-muted">3 days ago</small>
                            </div>
                            
                            <div class="text-center p-3">
                                <a href="#" class="btn btn-sm btn-outline-primary">View All Notifications</a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6 mt-4 mt-md-0">
                    <div class="card">
                        <div class="card-header">Recommended For You</div>
                        <div class="card-body">
                            <div class="recommendation-item d-flex mb-3 pb-3 border-bottom">
                                <img src="https://images.unsplash.com/photo-1604410869154-3c16714cd476?q=80&w=1528&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Car" class="me-3 rounded" style="width: 80px; height: 60px; object-fit: cover;">
                                <div>
                                    <h6 class="mb-1">2015 Ford - GLC 300</h6>
                                    <p class="mb-1 small">Premium Package, Panoramic Roof</p>
                                    <div class="d-flex align-items-center">
                                        <span class="fw-bold text-primary me-3">LKR 1400,000</span>
                                        <a href="#" class="btn btn-sm btn-outline-primary">View</a>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="recommendation-item d-flex mb-3 pb-3 border-bottom">
                                <img src="https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Car" class="me-3 rounded" style="width: 80px; height: 60px; object-fit: cover;">
                                <div>
                                    <h6 class="mb-1">2023 Hyundai Tucson</h6>
                                    <p class="mb-1 small">Limited Edition, AWD, Hybrid</p>
                                    <div class="d-flex align-items-center">
                                        <span class="fw-bold text-primary me-3">LKR 1100,000</span>
                                        <a href="#" class="btn btn-sm btn-outline-primary">View</a>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="recommendation-item d-flex">
                                <img src="https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=300&q=80" alt="Car" class="me-3 rounded" style="width: 80px; height: 60px; object-fit: cover;">
                                <div>
                                    <h6 class="mb-1">2023 Toyota RAV4 Prime</h6>
                                    <p class="mb-1 small">XSE, Plugin Hybrid, Navigation</p>
                                    <div class="d-flex align-items-center">
                                        <span class="fw-bold text-primary me-3">LKR 2500,000</span>
                                        <a href="#" class="btn btn-sm btn-outline-primary">View</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Recent search activity -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">Your Recent Searches</div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Search Query</th>
                                            <th>Date</th>
                                            <th>Results</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>Honda Accord 2020-2023</td>
                                            <td>April 5, 2025</td>
                                            <td>24 cars found</td>
                                            <td>
                                                <a href="#" class="btn btn-sm btn-outline-primary me-1">Run Again</a>
                                                <a href="#" class="btn btn-sm btn-outline-danger">Delete</a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Tesla Model 3 Long Range</td>
                                            <td>April 3, 2025</td>
                                            <td>12 cars found</td>
                                            <td>
                                                <a href="#" class="btn btn-sm btn-outline-primary me-1">Run Again</a>
                                                <a href="#" class="btn btn-sm btn-outline-danger">Delete</a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>SUV under $30,000</td>
                                            <td>April 1, 2025</td>
                                            <td>48 cars found</td>
                                            <td>
                                                <a href="#" class="btn btn-sm btn-outline-primary me-1">Run Again</a>
                                                <a href="#" class="btn btn-sm btn-outline-danger">Delete</a>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
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
            
            // Car favorite toggle
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