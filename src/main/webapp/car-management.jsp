<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="com.carpurchase.model.Car" %>
<%@ page import="com.carpurchase.model.CarListManager" %>

<%
    // Check if user is logged in as admin
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || !"admin".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Process car actions
    String action = request.getParameter("action");
    String carId = request.getParameter("id");
    String message = "";
    boolean success = false;
    
    CarListManager carManager = new CarListManager();
    
    if (action != null && carId != null) {
        try {
            if ("delete".equals(action)) {
                // Delete car
                carManager.deleteCar(carId);
                success = true;
                message = "Car listing deleted successfully.";
            } else if ("activate".equals(action)) {
                // Activate car (set status to Active)
                Car car = carManager.getCarById(carId);
                car.setStatus("Active");
                carManager.updateCar(car);
                success = true;
                message = "Car listing activated successfully.";
            } else if ("deactivate".equals(action)) {
                // Deactivate car (set status to Pending)
                Car car = carManager.getCarById(carId);
                car.setStatus("Pending");
                carManager.updateCar(car);
                success = true;
                message = "Car listing deactivated successfully.";
            } else if ("sold".equals(action)) {
                // Mark car as sold
                Car car = carManager.getCarById(carId);
                car.setStatus("Sold");
                carManager.updateCar(car);
                success = true;
                message = "Car listing marked as sold.";
            }
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
        }
    }
    
    // Get all cars
    List<Car> allCars = carManager.getAllCars();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Car Management - CarTrader Admin</title>
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
        
        .status-badge {
            padding: 5px 10px;
            font-size: 0.75rem;
            font-weight: 600;
            border-radius: 50px;
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
        
        .table td {
            vertical-align: middle;
        }
        
        .car-image {
            width: 80px;
            height: 60px;
            object-fit: cover;
            border-radius: 4px;
        }
        
        .action-btn {
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
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
            <li class="nav-item">
                <a class="nav-link" href="user-management.jsp">
                    <i class="fas fa-users"></i> User Management
                </a>
            </li>
            <li class="nav-item active">
                <a class="nav-link active" href="car-management.jsp">
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
                <h2>Car Listings Management</h2>
            </div>
            
            <!-- Status Messages -->
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= success ? "success" : "danger" %> alert-dismissible fade show" role="alert">
                    <i class="fas fa-<%= success ? "check" : "exclamation" %>-circle me-2"></i> <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            
            <!-- Filter Cards -->
            <div class="row mb-4">
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-body py-3">
                            <div class="row g-3 align-items-center">
                                <div class="col-md-5">
                                    <div class="search-container">
                                        <i class="fas fa-search search-icon"></i>
                                        <input type="text" id="carSearchInput" class="form-control" placeholder="Search cars...">
                                    </div>
                                </div>
                                <div class="col-md-auto">
                                    <div class="btn-group" role="group">
                                        <input type="radio" class="btn-check" name="statusFilter" id="all" value="all" checked>
                                        <label class="btn btn-outline-secondary" for="all">All</label>
                                        
                                        <input type="radio" class="btn-check" name="statusFilter" id="active" value="Active">
                                        <label class="btn btn-outline-success" for="active">Active</label>
                                        
                                        <input type="radio" class="btn-check" name="statusFilter" id="pending" value="Pending">
                                        <label class="btn btn-outline-warning" for="pending">Pending</label>
                                        
                                        <input type="radio" class="btn-check" name="statusFilter" id="sold" value="Sold">
                                        <label class="btn btn-outline-danger" for="sold">Sold</label>
                                    </div>
                                </div>
                                <div class="col-md-auto ms-auto">
                                    <select class="form-select" id="sortSelect">
                                        <option value="newest">Newest First</option>
                                        <option value="oldest">Oldest First</option>
                                        <option value="price_high">Price: High to Low</option>
                                        <option value="price_low">Price: Low to High</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Car List Table -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">All Car Listings</h5>
                    <button class="btn btn-sm btn-outline-primary" onclick="window.location.reload();">
                        <i class="fas fa-sync-alt me-1"></i> Refresh
                    </button>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table id="carTable" class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Image</th>
                                    <th>Title</th>
                                    <th>Make / Model</th>
                                    <th>Year</th>
                                    <th>Price</th>
                                    <th>Seller</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Car car : allCars) { 
                                    String firstPhotoUrl = car.getPhotos() != null && !car.getPhotos().isEmpty() ? 
                                        car.getPhotos().get(0) : "assets/img/no-image.png";
                                %>
                                <tr>
                                    <td><small><%= car.getId() %></small></td>
                                    <td>
                                        <img src="<%= firstPhotoUrl %>" class="car-image" alt="<%= car.getTitle() %>">
                                    </td>
                                    <td><strong><%= car.getTitle() %></strong></td>
                                    <td><%= car.getMake() %> / <%= car.getModel() %></td>
                                    <td><%= car.getYear() %></td>
                                    <td>LKR<%= String.format("%,.2f", car.getPrice()) %></td>
                                    <td><%= car.getContactName() %></td>
                                    <td>
                                        <% if ("Active".equalsIgnoreCase(car.getStatus())) { %>
                                            <span class="status-badge status-active">Active</span>
                                        <% } else if ("Pending".equalsIgnoreCase(car.getStatus())) { %>
                                            <span class="status-badge status-pending">Pending</span>
                                        <% } else if ("Sold".equalsIgnoreCase(car.getStatus())) { %>
                                            <span class="status-badge status-sold">Sold</span>
                                        <% } else { %>
                                            <span class="badge bg-secondary"><%= car.getStatus() %></span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <a href="car-details.jsp?id=<%= car.getId() %>" class="btn btn-sm btn-outline-primary action-btn">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            
                                            <a href="edit-listing.jsp?id=<%= car.getId() %>" class="btn btn-sm btn-outline-secondary action-btn">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            
                                            <% if (!"Active".equalsIgnoreCase(car.getStatus())) { %>
                                                <a href="car-management.jsp?action=activate&id=<%= car.getId() %>" 
                                                   class="btn btn-sm btn-outline-success action-btn"
                                                   onclick="return confirm('Activate this listing?')">
                                                    <i class="fas fa-check"></i>
                                                </a>
                                            <% } else { %>
                                                <a href="car-management.jsp?action=deactivate&id=<%= car.getId() %>" 
                                                   class="btn btn-sm btn-outline-warning action-btn"
                                                   onclick="return confirm('Deactivate this listing?')">
                                                    <i class="fas fa-pause"></i>
                                                </a>
                                            <% } %>
                                            
                                            <% if (!"Sold".equalsIgnoreCase(car.getStatus())) { %>
                                                <a href="car-management.jsp?action=sold&id=<%= car.getId() %>" 
                                                   class="btn btn-sm btn-outline-info action-btn"
                                                   onclick="return confirm('Mark this car as sold?')">
                                                    <i class="fas fa-dollar-sign"></i>
                                                </a>
                                            <% } %>
                                            
                                            <a href="car-management.jsp?action=delete&id=<%= car.getId() %>" 
                                               class="btn btn-sm btn-outline-danger action-btn"
                                               onclick="return confirm('Are you sure you want to delete this car listing? This action cannot be undone.')">
                                                <i class="fas fa-trash"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
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
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- DataTables -->
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize DataTable
            const carTable = $('#carTable').DataTable({
                "paging": true,
                "ordering": true,
                "info": true,
                "responsive": true,
                "lengthMenu": [10, 25, 50, 100],
                "language": {
                    "search": "Filter records:",
                    "lengthMenu": "Show _MENU_ cars per page",
                    "zeroRecords": "No matching cars found",
                    "info": "Showing _START_ to _END_ of _TOTAL_ cars",
                    "infoEmpty": "No cars available",
                    "infoFiltered": "(filtered from _MAX_ total cars)"
                }
            });
            
            // Connect the custom search box to DataTable
            $('#carSearchInput').on('keyup', function() {
                carTable.search(this.value).draw();
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
            
            // Filter by status
            $('input[name="statusFilter"]').on('change', function() {
                const filterValue = $(this).val();
                
                if (filterValue === 'all') {
                    carTable.column(7).search('').draw();
                } else {
                    carTable.column(7).search(filterValue).draw();
                }
            });
            
            // Sort options
            $('#sortSelect').on('change', function() {
                const sortOption = LKR(this).val();
                
                switch(sortOption) {
                    case 'newest':
                        // Assuming the newest cars have higher IDs
                        carTable.order([0, 'desc']).draw();
                        break;
                    case 'oldest':
                        carTable.order([0, 'asc']).draw();
                        break;
                    case 'price_high':
                        carTable.order([5, 'desc']).draw();
                        break;
                    case 'price_low':
                        carTable.order([5, 'asc']).draw();
                        break;
                    default:
                        carTable.order([0, 'desc']).draw();
                }
            });
        });
    </script>
</body>
</html>