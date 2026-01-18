<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.format.*" %>

<%!
    // Helper function to escape strings for JavaScript
    public String escapeJS(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
%>

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
    
    // Get inquiries from request (set by servlet)
    List<Map<String, String>> inquiries = (List<Map<String, String>>) request.getAttribute("inquiries");
    
    // If accessed directly without going through the servlet, redirect to the servlet
    if (inquiries == null) {
        response.sendRedirect("InquiryServlet");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Inquiries - CarTrader</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Same styles as before */
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
        
        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: transform 0.3s, box-shadow 0.3s;
            margin-bottom: 20px;
        }
        
        .inquiry-card {
            border-left: 5px solid var(--primary-color);
            transition: transform 0.2s;
        }
        
        .inquiry-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .inquiry-card.replied {
            border-left-color: var(--success-color);
        }
        
        .inquiry-status {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .status-pending {
            background-color: rgba(255, 190, 11, 0.1);
            color: var(--warning-color);
        }
        
        .status-replied {
            background-color: rgba(56, 176, 0, 0.1);
            color: var(--success-color);
        }
        
        .inquiry-date {
            color: #6c757d;
            font-size: 0.85rem;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background-color: white;
            border-radius: 10px;
            margin-top: 20px;
        }
        
        .empty-state i {
            font-size: 4rem;
            color: #dee2e6;
            margin-bottom: 20px;
        }
        
        .empty-state h3 {
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .empty-state p {
            color: #6c757d;
            margin-bottom: 25px;
        }
        
        /* Animation for card loading */
        .inquiry-card {
            animation: fadeIn 0.5s ease-in-out;
        }
        
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
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
    <!-- Sidebar toggle button -->
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
                <a class="nav-link active" href="InquiryServlet">
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
                        <%= fullName.substring(0, 1).toUpperCase() %>
                    </div>
                    <div>
                        <div class="fw-bold"><%= fullName %></div>
                        <small class="text-muted"><%= username %></small>
                    </div>
                </a>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="UserSettingsServlet"><i class="fas fa-user me-2"></i> My Profile</a></li>
                    <li><a class="dropdown-item" href="UserSettingsServlet"><i class="fas fa-cog me-2"></i> Account Settings</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="logout.jsp"><i class="fas fa-sign-out-alt me-2"></i> Logout</a></li>
                </ul>
            </div>
        </div>
    </div>
    
    <!-- Content -->
    <div class="content">
        <div class="container-fluid">
            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>My Inquiries</h2>
                <div>
                    <a href="browse-cars.jsp" class="btn btn-primary">
                        <i class="fas fa-search me-2"></i> Browse Cars
                    </a>
                </div>
            </div>
            
            <!-- Stats Summary -->
            <div class="row mb-4">
                <div class="col-md-3 mb-3 mb-md-0">
                    <div class="card h-100">
                        <div class="card-body text-center">
                            <i class="fas fa-clipboard-list fa-2x text-primary mb-3"></i>
                            <h4><%= inquiries.size() %></h4>
                            <p class="text-muted mb-0">Total Inquiries</p>
                        </div>
                    </div>
                </div>
                <% if (!inquiries.isEmpty()) { %>
                    <%
                        // Calculate stats
                        int pendingCount = 0;
                        int repliedCount = 0;
                        
                        for (Map<String, String> inquiry : inquiries) {
                            String status = inquiry.get("Status");
                            if ("Pending".equalsIgnoreCase(status)) {
                                pendingCount++;
                            } else if ("Replied".equalsIgnoreCase(status)) {
                                repliedCount++;
                            }
                        }
                    %>
                    <div class="col-md-3 mb-3 mb-md-0">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <i class="fas fa-clock fa-2x text-warning mb-3"></i>
                                <h4><%= pendingCount %></h4>
                                <p class="text-muted mb-0">Pending Responses</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3 mb-md-0">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <i class="fas fa-reply fa-2x text-success mb-3"></i>
                                <h4><%= repliedCount %></h4>
                                <p class="text-muted mb-0">Replied Inquiries</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <%
                                    // Find most recent inquiry
                                    String latestDate = "";
                                    if (!inquiries.isEmpty()) {
                                        latestDate = inquiries.get(0).get("InquiryDate");
                                        if (latestDate != null) {
                                            latestDate = latestDate.split("\\(UTC\\)")[0].trim();
                                        }
                                    }
                                %>
                                <i class="fas fa-calendar-alt fa-2x text-info mb-3"></i>
                                <h4 class="small"><%= latestDate %></h4>
                                <p class="text-muted mb-0">Latest Inquiry</p>
                            </div>
                        </div>
                    </div>
                <% } else { %>
                    <div class="col-md-9">
                        <div class="card h-100">
                            <div class="card-body d-flex align-items-center justify-content-center">
                                <p class="text-muted mb-0">You haven't sent any inquiries yet. Browse cars to contact sellers.</p>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
            
            <!-- Inquiries List -->
            <div class="row">
                <div class="col-12">
                    <% if (inquiries.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-clipboard"></i>
                            <h3>No Inquiries Yet</h3>
                            <p>You haven't sent any inquiries to car sellers. Browse listings and contact sellers about cars you're interested in.</p>
                            <a href="browse-cars.jsp" class="btn btn-sm btn-primary">
                                <i class="fas fa-search me-2"></i> Browse Cars Now
                            </a>
                        </div>
                    <% } else { %>
                        <div class="card mb-4">
                            <div class="card-header d-flex justify-content-between align-items-center bg-white">
                                <h5 class="mb-0">All Inquiries</h5>
                                <div class="btn-group" role="group">
                                    <button type="button" class="btn btn-sm btn-outline-secondary active" id="allInquiriesBtn">All</button>
                                    <button type="button" class="btn btn-sm btn-outline-secondary" id="pendingInquiriesBtn">Pending</button>
                                    <button type="button" class="btn btn-sm btn-outline-secondary" id="repliedInquiriesBtn">Replied</button>
                                </div>
                            </div>
                            <div class="card-body p-0">
                                <div class="list-group list-group-flush">
                                    <% 
                                    // Create JavaScript array to store inquiry data
                                    %>
                                    <script>
                                        // Initialize inquiry data array
                                        var inquiryData = [];
                                    </script>
                                    
                                    <% 
                                    for (int i = 0; i < inquiries.size(); i++) { 
                                        Map<String, String> inquiry = inquiries.get(i);
                                        String status = inquiry.get("Status");
                                        boolean isReplied = "Replied".equalsIgnoreCase(status);
                                        String inquiryId = inquiry.get("InquiryId");
                                        String subject = inquiry.get("Subject") != null ? inquiry.get("Subject") : "";
                                        String message = inquiry.get("Message") != null ? inquiry.get("Message") : "";
                                        String carTitle = inquiry.get("CarTitle") != null ? inquiry.get("CarTitle") : "Car information not available";
                                        String inquiryDate = inquiry.get("InquiryDate") != null ? inquiry.get("InquiryDate").split("\\(UTC\\)")[0].trim() : "Date not available";
                                        String reply = inquiry.get("Reply") != null ? inquiry.get("Reply") : "";
                                    %>
                                        <div class="list-group-item inquiry-card <%= isReplied ? "replied" : "" %>" 
                                             data-status="<%= status %>" id="inquiry-<%= i %>">
                                            <div class="d-flex justify-content-between align-items-start mb-2">
                                                <h5 class="mb-1">
                                                    <%= subject %>
                                                </h5>
                                                <span class="inquiry-status <%= isReplied ? "status-replied" : "status-pending" %>">
                                                    <%= status %>
                                                </span>
                                            </div>
                                            <p class="mb-1">
                                                <strong>Car:</strong> <%= carTitle %>
                                            </p>
                                            <p class="mb-3 text-truncate">
                                                <%= message %>
                                            </p>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <span class="inquiry-date">
                                                    <i class="fas fa-clock me-1"></i> <%= inquiryDate %>
                                                </span>
                                                <button type="button" class="btn btn-sm btn-outline-primary" 
                                                        onclick="showInquiryDetails(<%= i %>)">
                                                    View Details
                                                </button>
                                            </div>
                                        </div>
                                        
                                        <script>
                                            // Add inquiry data to JavaScript array
                                            inquiryData[<%= i %>] = {
                                                id: "<%= inquiryId %>",
                                                subject: "<%= escapeJS(subject) %>",
                                                message: "<%= escapeJS(message) %>",
                                                carTitle: "<%= escapeJS(carTitle) %>",
                                                date: "<%= inquiryDate %>",
                                                status: "<%= status %>",
                                                reply: "<%= escapeJS(reply) %>"
                                            };
                                        </script>
                                    <% } %>
                                </div>
                            </div>
                        </div>
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
    
    <!-- View Inquiry Modal -->
    <div class="modal fade" id="viewInquiryModal" tabindex="-1" aria-labelledby="inquiryModalTitle" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="inquiryModalTitle">Inquiry Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <h6>Car</h6>
                        <p id="modalCarTitle" class="fw-bold">Loading...</p>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <h6>Subject</h6>
                            <p id="modalSubject">Loading...</p>
                        </div>
                        <div class="col-md-6">
                            <h6>Date</h6>
                            <p id="modalDate">Loading...</p>
                        </div>
                    </div>
                    <div class="mb-3">
                        <div class="d-flex justify-content-between">
                            <h6>Message</h6>
                            <span id="modalStatus" class="inquiry-status status-pending">Pending</span>
                        </div>
                        <div class="card bg-light">
                            <div class="card-body">
                                <p id="modalMessage" class="mb-0">Loading...</p>
                            </div>
                        </div>
                    </div>
                    <div id="replySection" class="mb-3 d-none">
                        <h6>Seller's Reply</h6>
                        <div class="card">
                            <div class="card-body">
                                <p id="modalReply" class="mb-0">No reply yet.</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Initialize modal globally - this is the key fix
        var inquiryModal;
        
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize the modal once when page loads
            inquiryModal = new bootstrap.Modal(document.getElementById('viewInquiryModal'), {
                backdrop: 'static',
                keyboard: true
            });
            
            // Add event listener to clean up modal when it's hidden
            document.getElementById('viewInquiryModal').addEventListener('hidden.bs.modal', function() {
                // Remove any leftover modal backdrops
                const backdrops = document.getElementsByClassName('modal-backdrop');
                for (let i = 0; i < backdrops.length; i++) {
                    backdrops[i].parentNode.removeChild(backdrops[i]);
                }
                // Make sure body doesn't have modal-open class
                document.body.classList.remove('modal-open');
                // Remove any inline styles added to the body
                document.body.style.overflow = '';
                document.body.style.paddingRight = '';
            });
            
            // Toggle sidebar on mobile
            const toggleSidebarBtn = document.getElementById('toggleSidebar');
            const sidebar = document.querySelector('.sidebar');
            const content = document.querySelector('.content');
            
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
            
            // Filter buttons
            const allInquiriesBtn = document.getElementById('allInquiriesBtn');
            const pendingInquiriesBtn = document.getElementById('pendingInquiriesBtn');
            const repliedInquiriesBtn = document.getElementById('repliedInquiriesBtn');
            const inquiryCards = document.querySelectorAll('.inquiry-card');
            
            allInquiriesBtn.addEventListener('click', function() {
                allInquiriesBtn.classList.add('active');
                pendingInquiriesBtn.classList.remove('active');
                repliedInquiriesBtn.classList.remove('active');
                
                inquiryCards.forEach(function(card) {
                    card.style.display = 'block';
                });
            });
            
            pendingInquiriesBtn.addEventListener('click', function() {
                allInquiriesBtn.classList.remove('active');
                pendingInquiriesBtn.classList.add('active');
                repliedInquiriesBtn.classList.remove('active');
                
                inquiryCards.forEach(function(card) {
                    if (card.getAttribute('data-status') === 'Pending') {
                        card.style.display = 'block';
                    } else {
                        card.style.display = 'none';
                    }
                });
            });
            
            repliedInquiriesBtn.addEventListener('click', function() {
                allInquiriesBtn.classList.remove('active');
                pendingInquiriesBtn.classList.remove('active');
                repliedInquiriesBtn.classList.add('active');
                
                inquiryCards.forEach(function(card) {
                    if (card.getAttribute('data-status') === 'Replied') {
                        card.style.display = 'block';
                    } else {
                        card.style.display = 'none';
                    }
                });
            });
            
            // Add staggered animation to inquiry cards
            const cards = document.querySelectorAll('.inquiry-card');
            cards.forEach(function(card, index) {
                card.style.animationDelay = `${index * 0.1}s`;
            });
        });
        
        // Function to show inquiry details in modal
        function showInquiryDetails(index) {
            // Get inquiry data
            const data = inquiryData[index];
            
            // Update modal with inquiry data
            document.getElementById('modalSubject').textContent = data.subject;
            document.getElementById('modalMessage').textContent = data.message;
            document.getElementById('modalCarTitle').textContent = data.carTitle;
            document.getElementById('modalDate').textContent = data.date;
            
            // Update status badge
            const statusElement = document.getElementById('modalStatus');
            statusElement.textContent = data.status;
            
            if (data.status === 'Replied') {
                statusElement.className = 'inquiry-status status-replied';
                
                // Show reply section if inquiry has been replied to
                const replySection = document.getElementById('replySection');
                replySection.classList.remove('d-none');
                
                // Show the reply if it exists
                const modalReply = document.getElementById('modalReply');
                if (data.reply && data.reply.trim() !== '') {
                    modalReply.textContent = data.reply;
                } else {
                    modalReply.textContent = "No reply details available.";
                }
            } else {
                statusElement.className = 'inquiry-status status-pending';
                document.getElementById('replySection').classList.add('d-none');
            }
            
            // Use the global modal instance to show the modal
            inquiryModal.show();
        }
    </script>
</body>
</html>