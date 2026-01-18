<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%-- Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-05-06 12:51:20 --%>
<%-- Current User's Login: IT24102083 --%>

<%
    // Check if user is logged in as a seller
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");
    String userRole = (String) session.getAttribute("userRole");
    String userId = (String) session.getAttribute("userId");
    
    if(username == null || !userRole.equalsIgnoreCase("seller")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get inquiries from request (set by servlet)
    List<Map<String, String>> sellerInquiries = (List<Map<String, String>>) request.getAttribute("inquiries");
    
    // If accessed directly without going through the servlet, redirect to the servlet
    if (sellerInquiries == null) {
        response.sendRedirect("InquiryServlet");
        return;
    }
    
    // Get error/success messages if any
    String errorMessage = "";
    String error = request.getParameter("error");
    if ("notfound".equals(error)) {
        errorMessage = "Inquiry not found";
    } else if ("unauthorized".equals(error)) {
        errorMessage = "You are not authorized to update this inquiry";
    } else if ("hastreply".equals(error)) {
        errorMessage = "Cannot change status to Pending when a reply exists";
    }
    
    String successMessage = "";
    String updated = request.getParameter("updated");
    if ("success".equals(updated)) {
        successMessage = "Inquiry updated successfully";
    } else if ("failed".equals(updated)) {
        errorMessage = "Failed to update inquiry";
    }
    
    // Count inquiries by status
    int pendingCount = 0;
    int repliedCount = 0;
    int totalCount = sellerInquiries.size();
    
    for (Map<String, String> inquiry : sellerInquiries) {
        String status = inquiry.get("Status");
        if ("Pending".equalsIgnoreCase(status)) {
            pendingCount++;
        } else if ("Replied".equalsIgnoreCase(status)) {
            repliedCount++;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inquiries - CarTrader Seller</title>
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
        
        .inquiry-item {
            border-bottom: 1px solid #eee;
            padding: 20px;
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
        
        .status-badge {
            padding: 5px 10px;
            border-radius: 5px;
            font-weight: 600;
            font-size: 12px;
            text-transform: uppercase;
            display: inline-block;
        }
        
        .status-pending {
            background-color: rgba(255, 190, 11, 0.1);
            color: var(--warning-color);
        }
        
        .status-replied {
            background-color: rgba(56, 176, 0, 0.1);
            color: var(--success-color);
        }
        
        .inquiry-detail-section {
            margin-bottom: 20px;
        }
        
        .inquiry-detail-title {
            font-size: 14px;
            font-weight: 600;
            color: #6c757d;
            margin-bottom: 5px;
        }
        
        .reply-box {
            background-color: rgba(56, 176, 0, 0.05);
            border-radius: 10px;
            padding: 15px;
            border-left: 4px solid var(--success-color);
        }
        
        .message-box {
            background-color: rgba(58, 134, 255, 0.05);
            border-radius: 10px;
            padding: 15px;
            border-left: 4px solid var(--primary-color);
        }
        
        .status-filter-btn.active {
            font-weight: 600;
            color: var(--primary-color);
            text-decoration: underline;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }
        
        .empty-state i {
            font-size: 4rem;
            color: #dee2e6;
            margin-bottom: 20px;
        }
        
        .empty-state h4 {
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .empty-state p {
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
                <a class="nav-link" href="seller-dashboard.jsp">
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
            <li class="nav-item active">
                <a class="nav-link active" href="InquiryServlet">
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
                    <li><a class="dropdown-item" href="UserSettingsServlet"><i class="fas fa-user me-2"></i> My Profile</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="logout.jsp"><i class="fas fa-sign-out-alt me-2"></i> Logout</a></li>
                </ul>
            </div>
        </div>
    </div>
    
    <!-- Content -->
    <div class="content">
        <div class="container-fluid">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap">
                <h2 class="mb-3 mb-md-0">Customer Inquiries</h2>
                
                <div class="d-flex align-items-center">
                    <div class="me-3">
                        <a href="InquiryServlet" class="status-filter-btn <%= request.getParameter("filter") == null ? "active" : "" %>">
                            All (<%= totalCount %>)
                        </a> | 
                        <a href="InquiryServlet?filter=pending" class="status-filter-btn <%= "pending".equals(request.getParameter("filter")) ? "active" : "" %>">
                            Pending (<%= pendingCount %>)
                        </a> | 
                        <a href="InquiryServlet?filter=replied" class="status-filter-btn <%= "replied".equals(request.getParameter("filter")) ? "active" : "" %>">
                            Replied (<%= repliedCount %>)
                        </a>
                    </div>
                    
                    <div class="dropdown">
                        <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="sortDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-sort-amount-down me-1"></i> Sort
                        </button>
                        <ul class="dropdown-menu" aria-labelledby="sortDropdown">
                            <li><a class="dropdown-item" href="#">Newest First</a></li>
                            <li><a class="dropdown-item" href="#">Oldest First</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#">Status (Pending First)</a></li>
                        </ul>
                    </div>
                </div>
            </div>
            
            <% if (!errorMessage.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert" id="errorAlert">
                    <strong><i class="fas fa-exclamation-circle me-2"></i></strong> <%= errorMessage %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            
            <% if (!successMessage.isEmpty()) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert" id="successAlert">
                    <strong><i class="fas fa-check-circle me-2"></i></strong> <%= successMessage %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            
            <!-- Stats cards -->
            <div class="row mb-4">
                <div class="col-md-4 col-sm-6">
                    <div class="stats-card">
                        <div class="stats-details">
                            <h3><%= totalCount %></h3>
                            <p>Total Inquiries</p>
                        </div>
                        <div class="stats-icon primary-bg">
                            <i class="fas fa-envelope"></i>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-4 col-sm-6">
                    <div class="stats-card">
                        <div class="stats-details">
                            <h3><%= pendingCount %></h3>
                            <p>Pending Replies</p>
                        </div>
                        <div class="stats-icon warning-bg">
                            <i class="fas fa-clock"></i>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-4 col-sm-6">
                    <div class="stats-card">
                        <div class="stats-details">
                            <h3><%= repliedCount %></h3>
                            <p>Replied Inquiries</p>
                        </div>
                        <div class="stats-icon success-bg">
                            <i class="fas fa-reply"></i>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Inquiries List -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">All Inquiries</h5>
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" id="autoRefreshSwitch">
                        <label class="form-check-label" for="autoRefreshSwitch">Auto-refresh</label>
                    </div>
                </div>
                <div class="card-body p-0">
                    <% if (sellerInquiries.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-envelope-open"></i>
                            <h4>No inquiries found</h4>
                            <p>When potential buyers send inquiries about your listings, they will appear here.</p>
                        </div>
                    <% } else { %>
                        <% 
                            for (Map<String, String> inquiry : sellerInquiries) {
                                String status = inquiry.get("Status");
                                String inquiryId = inquiry.get("InquiryId");
                                String carTitle = inquiry.get("CarTitle") != null ? inquiry.get("CarTitle") : "Unknown Vehicle";
                                String buyerName = inquiry.get("Name") != null ? inquiry.get("Name") : "Anonymous Buyer";
                                String inquiryDate = inquiry.get("InquiryDate") != null ? inquiry.get("InquiryDate") : "Unknown Date";
                                String existingReply = inquiry.get("Reply");
                                String replyDate = inquiry.get("ReplyDate");
                                
                                String formattedDate = inquiryDate;
                                try {
                                    if (inquiryDate.contains("(UTC)")) {
                                        formattedDate = inquiryDate.split("\\(UTC\\)")[0].trim();
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                        %>
                            <div class="inquiry-item" id="inquiry-<%= inquiryId %>">
                                <div class="row">
                                    <div class="col-md-9">
                                        <div class="d-flex justify-content-between align-items-start mb-2">
                                            <h5 class="mb-1"><%= inquiry.get("Subject") %></h5>
                                            <span class="status-badge <%= "Replied".equalsIgnoreCase(status) ? "status-replied" : "status-pending" %>">
                                                <%= status %>
                                            </span>
                                        </div>
                                        <p class="mb-1">From: <strong><%= buyerName %></strong> • <%= inquiry.get("Email") %></p>
                                        <p class="mb-3">Car: <strong><%= carTitle %></strong></p>
                                        <p class="mb-2 text-truncate" style="max-width: 100%;">
                                            <i class="fas fa-quote-left me-1 text-muted"></i>
                                            <%= inquiry.get("Message") %>
                                            <i class="fas fa-quote-right ms-1 text-muted"></i>
                                        </p>
                                        <div class="d-flex align-items-center mt-3">
                                            <small class="text-muted me-3">
                                                <i class="fas fa-clock me-1"></i> <%= formattedDate %>
                                            </small>
                                            <% if ("Pending".equalsIgnoreCase(status)) { %>
                                                <span class="badge bg-danger me-2">Requires Response</span>
                                            <% } %>
                                        </div>
                                    </div>
                                    <div class="col-md-3 text-md-end mt-3 mt-md-0">
                                        <button class="btn btn-primary mb-2" data-bs-toggle="modal" data-bs-target="#viewInquiryModal<%= inquiryId %>">
                                            <i class="fas fa-eye me-2"></i> View Details
                                        </button>
                                        <br>
                                        <% if ("Pending".equalsIgnoreCase(status)) { %>
                                            <form action="InquiryServlet" method="post" style="display:inline;">
                                                <input type="hidden" name="updateInquiry" value="<%= inquiryId %>">
                                                <input type="hidden" name="newStatus" value="Replied">
                                                <button type="submit" class="btn btn-outline-success">
                                                    <i class="fas fa-check me-2"></i> Mark as Replied
                                                </button>
                                            </form>
                                        <% } else if (existingReply == null || existingReply.isEmpty()) { %>
                                            <form action="InquiryServlet" method="post" style="display:inline;">
                                                <input type="hidden" name="updateInquiry" value="<%= inquiryId %>">
                                                <input type="hidden" name="newStatus" value="Pending">
                                                <button type="submit" class="btn btn-outline-warning">
                                                    <i class="fas fa-undo me-2"></i> Mark as Pending
                                                </button>
                                            </form>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Modal for this inquiry -->
                            <div class="modal fade" id="viewInquiryModal<%= inquiryId %>" tabindex="-1" aria-labelledby="viewInquiryModalLabel<%= inquiryId %>" aria-hidden="true">
                                <div class="modal-dialog modal-lg">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="viewInquiryModalLabel<%= inquiryId %>">Inquiry Details</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="d-flex justify-content-between align-items-center mb-3">
                                                <h5><%= inquiry.get("Subject") %></h5>
                                                <span class="status-badge <%= "Replied".equalsIgnoreCase(status) ? "status-replied" : "status-pending" %>">
                                                    <%= status %>
                                                </span>
                                            </div>
                                            
                                            <div class="row">
                                                <div class="col-md-6 inquiry-detail-section">
                                                    <div class="inquiry-detail-title">Buyer Information</div>
                                                    <p class="mb-1"><strong>Name:</strong> <%= buyerName %></p>
                                                    <p class="mb-1"><strong>Email:</strong> <%= inquiry.get("Email") %></p>
                                                    <% if (inquiry.get("Phone") != null && !inquiry.get("Phone").isEmpty()) { %>
                                                        <p class="mb-1"><strong>Phone:</strong> <%= inquiry.get("Phone") %></p>
                                                    <% } %>
                                                </div>
                                                <div class="col-md-6 inquiry-detail-section">
                                                    <div class="inquiry-detail-title">Inquiry Information</div>
                                                    <p class="mb-1"><strong>Date:</strong> <%= formattedDate %></p>
                                                    <p class="mb-1"><strong>Inquiry ID:</strong> <%= inquiryId %></p>
                                                    <p class="mb-1"><strong>Car:</strong> <%= carTitle %></p>
                                                </div>
                                            </div>
                                            
                                            <div class="inquiry-detail-section">
                                                <div class="inquiry-detail-title">Message</div>
                                                <div class="message-box">
                                                    <%= inquiry.get("Message") %>
                                                </div>
                                            </div>
                                            
                                            <div class="inquiry-detail-section">
                                                <div class="inquiry-detail-title">Your Reply</div>
                                                <% if (existingReply != null && !existingReply.isEmpty()) { %>
                                                    <div class="reply-box">
                                                        <%= existingReply %>
                                                        <% if (replyDate != null && !replyDate.isEmpty()) { %>
                                                            <div class="mt-3 text-muted">
                                                                <small><i class="fas fa-clock me-1"></i> Replied on: <%= replyDate.contains("(UTC)") ? replyDate.split("\\(UTC\\)")[0].trim() : replyDate %></small>
                                                            </div>
                                                        <% } %>
                                                    </div>
                                                <% } else { %>
                                                    <form action="InquiryServlet" method="post">
                                                        <input type="hidden" name="updateInquiry" value="<%= inquiryId %>">
                                                        <input type="hidden" name="newStatus" value="Replied">
                                                        <div class="mb-3">
                                                            <textarea class="form-control" id="replyText<%= inquiryId %>" name="replyText" rows="4" placeholder="Type your reply here..."></textarea>
                                                        </div>
                                                        <div class="d-flex justify-content-between">
                                                            <div>
                                                                <button type="button" class="btn btn-sm btn-outline-secondary me-2" onclick="insertTemplate('<%= inquiryId %>', 1)">
                                                                    Insert Template 1
                                                                </button>
                                                                <button type="button" class="btn btn-sm btn-outline-secondary" onclick="insertTemplate('<%= inquiryId %>', 2)">
                                                                    Insert Template 2
                                                                </button>
                                                            </div>
                                                            <button type="submit" class="btn btn-success">
                                                                <i class="fas fa-paper-plane me-2"></i> Send Reply
                                                            </button>
                                                        </div>
                                                    </form>
                                                <% } %>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                            <% if ("Pending".equalsIgnoreCase(status) && (existingReply == null || existingReply.isEmpty())) { %>
                                                <form action="InquiryServlet" method="post" style="display:inline;">
                                                    <input type="hidden" name="updateInquiry" value="<%= inquiryId %>">
                                                    <input type="hidden" name="newStatus" value="Replied">
                                                    <button type="submit" class="btn btn-primary">
                                                        Mark as Replied
                                                    </button>
                                                </form>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
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
            
            // Initialize tooltips
            const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
            const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
            
            // Auto-refresh checkbox
            const autoRefreshSwitch = document.getElementById('autoRefreshSwitch');
            if (autoRefreshSwitch) {
                autoRefreshSwitch.addEventListener('change', function() {
                    if (this.checked) {
                        // Refresh every 30 seconds
                        window.autoRefreshInterval = setInterval(function() {
                            window.location.reload();
                        }, 30000);
                    } else {
                        clearInterval(window.autoRefreshInterval);
                    }
                });
            }
            
            // Auto-dismiss alerts after 5 seconds
            setTimeout(function() {
                const successAlert = document.getElementById('successAlert');
                const errorAlert = document.getElementById('errorAlert');
                
                if (successAlert) {
                    const bsAlert = new bootstrap.Alert(successAlert);
                    bsAlert.close();
                }
                
                if (errorAlert) {
                    const bsAlert = new bootstrap.Alert(errorAlert);
                    bsAlert.close();
                }
            }, 5000);
            
            // Remove success/error parameters from URL if present
            const url = window.location.href;
            if (url.includes('updated=') || url.includes('error=')) {
                // Give a small delay to ensure user sees the message
                setTimeout(function() {
                    const baseUrl = url.split('?')[0]; // Get base URL without parameters
                    const urlParams = new URLSearchParams(window.location.search);
                    urlParams.delete('updated');
                    urlParams.delete('error');
                    
                    // Keep other parameters if they exist
                    const remainingParams = urlParams.toString();
                    const newUrl = baseUrl + (remainingParams ? '?' + remainingParams : '');
                    
                    window.history.replaceState({}, document.title, newUrl);
                }, 5000); // 5 seconds
            }
        });
        
        // Function to insert template text
        function insertTemplate(inquiryId, templateNum) {
            const textarea = document.getElementById(`replyText${inquiryId}`);
            let templateText = '';
            
            if (templateNum === 1) {
                templateText = "Thank you for your inquiry. I'd be happy to answer any questions you have about this vehicle. When would you like to schedule a viewing?";
            } else {
                templateText = "Thank you for your interest in our listing. This vehicle is still available. I'd be happy to arrange a test drive at your convenience. Please let me know what days and times work best for you.";
            }
            
            textarea.value = templateText;
        }
    </script>
</body>
</html>