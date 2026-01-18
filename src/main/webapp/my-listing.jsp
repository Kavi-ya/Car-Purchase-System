<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.carpurchase.model.Car" %>
<%@ page import="com.carpurchase.model.CarListManager" %>

<%!
    // Helper method to read car-list.txt file and return user's car listings
    List<Car> getMyListings(String sellerId) {
        List<Car> myListings = new ArrayList<>();
        CarListManager carManager = new CarListManager();
        List<Car> allCars = carManager.getAllCars();
        
        for (Car car : allCars) {
            if (car.getSellerId() != null && car.getSellerId().equals(sellerId)) {
                myListings.add(car);
            }
        }
        return myListings;
    }
    
    // Helper method to delete a car by ID using the CarListManager
    boolean deleteCar(String carId) {
        CarListManager carManager = new CarListManager();
        return carManager.deleteCar(carId);
    }
    
 // Helper method to get proper image URL
    String getImageUrl(String relativePath) {
        if (relativePath == null || relativePath.isEmpty()) {
            return "car_images/default1.jpg"; // Default image
        }
        
        // If path doesn't start with context path already
        if (!relativePath.startsWith("/") && !relativePath.startsWith("http")) {
            return relativePath; // Return as is if it's already a full path
        }
        
        return relativePath;
    }
    
    // Truncate long text for display
    String truncateText(String text, int maxLength) {
        if (text == null) return "";
        return text.length() > maxLength ? text.substring(0, maxLength) + "..." : text;
    }
%>

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
    
    // Process delete action if requested
    String deleteCarId = request.getParameter("delete");
    String actionMessage = "";
    if (deleteCarId != null && !deleteCarId.isEmpty()) {
        boolean deleted = deleteCar(deleteCarId);
        if (deleted) {
            actionMessage = "<div class='alert alert-success'>Car listing deleted successfully.</div>";
        } else {
            actionMessage = "<div class='alert alert-danger'>Failed to delete car listing. Please try again.</div>";
        }
    }
    
    // Get user's car listings
    List<Car> myListings = getMyListings(userId);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Listings - CarTrader</title>
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
        
        .car-card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: transform 0.3s, box-shadow 0.3s;
            margin-bottom: 20px;
            overflow: hidden;
        }
        
        .car-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .car-img {
            height: 200px;
            object-fit: cover;
        }
        
        .car-price {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary-color);
        }
        
        .car-status {
            display: inline-block;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-active {
            background-color: rgba(56, 176, 0, 0.1);
            color: var(--success-color);
        }
        
        .status-pending {
            background-color: rgba(255, 190, 11, 0.1);
            color: var(--warning-color);
        }
        
        .status-sold {
            background-color: rgba(217, 4, 41, 0.1);
            color: var(--danger-color);
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
        
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            background-color: white;
            border-radius: 10px;
            margin-top: 20px;
        }
        
        .empty-state i {
            font-size: 3rem;
            color: #dee2e6;
            margin-bottom: 20px;
        }
        
        .empty-state h3 {
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .empty-state p {
            color: #6c757d;
        }
        
        .action-btns {
            display: flex;
            gap: 8px;
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
        
        /* Animation for card loading */
        .car-card {
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
        
        .stat-card {
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            text-align: center;
            margin-bottom: 20px;
            background-color: white;
        }
        
        .stat-card .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 10px;
            color: var(--primary-color);
        }
        
        .stat-card .stat-value {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .stat-card .stat-label {
            font-size: 0.9rem;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .delete-confirm-modal .modal-body {
            padding: 2rem;
            text-align: center;
        }
        
        .delete-confirm-modal .modal-footer {
            justify-content: center;
            padding: 1.5rem;
            border-top: 0;
        }
        
        .delete-confirm-modal .icon-warning {
            font-size: 4rem;
            color: var(--warning-color);
            margin-bottom: 1rem;
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
            <li class="nav-item active">
                <a class="nav-link active" href="my-listing.jsp">
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
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>My Listings</h2>
                <a href="add-listing.jsp" class="btn btn-primary">
                    <i class="fas fa-plus me-2"></i> Add New Listing
                </a>
            </div>
            
            <!-- Action message if any -->
            <%= actionMessage %>
            
            <!-- Summary Stats -->
            <div class="row mb-4">
                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-car"></i>
                        </div>
                        <div class="stat-value"><%= myListings.size() %></div>
                        <div class="stat-label">Total Listings</div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-eye"></i>
                        </div>
                        <div class="stat-value"><%
                            // Calculate total views (just a placeholder)
                            int totalViews = 0;
                            for (Car car : myListings) {
                                // Assuming there's a getViews method
                                // totalViews += car.getViews();
                                totalViews += new Random().nextInt(100); // For demo
                            }
                            out.print(totalViews);
                        %></div>
                        <div class="stat-label">Total Views</div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="stat-icon" style="color: var(--success-color);">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        <div class="stat-value"><%
                            // Count active listings
                            int activeListings = 0;
                            for (Car car : myListings) {
                                if ("Active".equalsIgnoreCase(car.getStatus())) {
                                    activeListings++;
                                }
                            }
                            out.print(activeListings);
                        %></div>
                        <div class="stat-label">Active Listings</div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="stat-icon" style="color: var(--warning-color);">
                            <i class="fas fa-envelope"></i>
                        </div>
                        <div class="stat-value">2</div>
                        <div class="stat-label">New Inquiries</div>
                    </div>
                </div>
            </div>
            
            <!-- Filter and Sort Options -->
            <div class="card mb-4">
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-8">
                            <div class="input-group">
                                <input type="text" class="form-control" placeholder="Search listings..." id="searchInput">
                                <button class="btn btn-outline-secondary" type="button">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <select class="form-select" id="statusFilter">
                                <option value="">All Statuses</option>
                                <option value="Active">Active</option>
                                <option value="Pending">Pending</option>
                                <option value="Sold">Sold</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Listings Table -->
            <div class="card">
                <div class="card-body">
                    <% if (myListings.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-car"></i>
                            <h3>No Listings Found</h3>
                            <p>You haven't created any car listings yet. Get started by adding your first car listing!</p>
                            <a href="add-listing.jsp" class="btn btn-primary mt-3">
                                <i class="fas fa-plus me-2"></i> Add New Listing
                            </a>
                        </div>
                    <% } else { %>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th style="width: 80px;"></th>
                                        <th>Vehicle</th>
                                        <th>Price</th>
                                        <th>Listed Date</th>
                                        <th>Status</th>
                                        <th>Views</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Car car : myListings) { %>
                                        <tr class="listing-row" data-status="<%= car.getStatus() %>">
                                            <td>
                                                <img src="${pageContext.request.contextPath}/<%= getImageUrl(car.getPhotos().isEmpty() ? "car_images/default1.jpg" : car.getPhotos().get(0)) %>" 
     											class="rounded" style="width: 70px; height: 50px; object-fit: cover;" 
     											alt="<%= car.getTitle() %>">
                                            </td>
                                            <td>
                                                <div class="fw-bold"><%= car.getYear() %> <%= car.getMake() %> <%= car.getModel() %></div>
                                                <div class="text-muted small"><%= truncateText(car.getTitle(), 40) %></div>
                                            </td>
                                            <td class="fw-bold">LKR <%= String.format("%,.0f", car.getPrice()) %></td>
                                            <td><%= car.getListingDate() %></td>
                                            <td>
                                                <% if ("Active".equalsIgnoreCase(car.getStatus())) { %>
                                                    <span class="car-status status-active">Active</span>
                                                <% } else if ("Pending".equalsIgnoreCase(car.getStatus())) { %>
                                                    <span class="car-status status-pending">Pending</span>
                                                <% } else if ("Sold".equalsIgnoreCase(car.getStatus())) { %>
                                                    <span class="car-status status-sold">Sold</span>
                                                <% } else { %>
                                                    <span class="car-status"><%= car.getStatus() %></span>
                                                <% } %>
                                            </td>
                                            <td><%= new Random().nextInt(100) %></td> <!-- Placeholder for views -->
                                            <td>
                                                <div class="action-btns">
                                                    <a href="view-car.jsp?id=<%= car.getId() %>" class="btn btn-sm btn-outline-primary" title="View">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <a href="edit-listing.jsp?id=<%= car.getId() %>" class="btn btn-sm btn-outline-secondary" title="Edit">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <button class="btn btn-sm btn-outline-danger" title="Delete"
                                                            onclick="confirmDelete('<%= car.getId() %>', '<%= car.getYear() %> <%= car.getMake() %> <%= car.getModel() %>')">
                                                        <i class="fas fa-trash-alt"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
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
    
    <!-- Delete Confirmation Modal -->
    <div class="modal fade delete-confirm-modal" id="deleteConfirmModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-body">
                    <i class="fas fa-exclamation-triangle icon-warning"></i>
                    <h4 class="mb-3">Delete Listing</h4>
                    <p>Are you sure you want to delete the listing for:</p>
                    <p class="fw-bold" id="deleteCarName"></p>
                    <p class="text-danger">This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <a href="#" id="confirmDeleteBtn" class="btn btn-danger">Delete Listing</a>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
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
            
            // Search functionality
            const searchInput = document.getElementById('searchInput');
            searchInput?.addEventListener('keyup', function() {
                const searchTerm = this.value.toLowerCase();
                const rows = document.querySelectorAll('.listing-row');
                
                rows.forEach(row => {
                    const vehicleText = row.querySelector('td:nth-child(2)').textContent.toLowerCase();
                    if (vehicleText.includes(searchTerm)) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            });
            
            // Status filter
            const statusFilter = document.getElementById('statusFilter');
            statusFilter?.addEventListener('change', function() {
                const selectedStatus = this.value.toLowerCase();
                const rows = document.querySelectorAll('.listing-row');
                
                rows.forEach(row => {
                    if (!selectedStatus || row.dataset.status.toLowerCase() === selectedStatus) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            });
        });
        
        // Function to show delete confirmation modal
        function confirmDelete(carId, carName) {
            document.getElementById('deleteCarName').textContent = carName;
            document.getElementById('confirmDeleteBtn').href = 'my-listing.jsp?delete=' + carId;
            
            const deleteModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
            deleteModal.show();
        }
    </script>
</body>
</html>