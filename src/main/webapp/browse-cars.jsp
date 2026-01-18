<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.carpurchase.model.Car" %>
<%@ page import="com.carpurchase.model.CarListManager" %>

<%!
    // Helper method for merge operation in sorting
    void merge(Car[] arr, int left, int mid, int right, boolean asc) {
        int n1 = mid - left + 1;
        int n2 = right - mid;
        
        Car[] L = new Car[n1];
        Car[] R = new Car[n2];
        
        for (int i = 0; i < n1; i++)
            L[i] = arr[left + i];
        for (int j = 0; j < n2; j++)
            R[j] = arr[mid + 1 + j];
        
        int i = 0, j = 0, k = left;
        while (i < n1 && j < n2) {
            if (asc) {
                if (L[i].getPrice() <= R[j].getPrice()) {
                    arr[k] = L[i];
                    i++;
                } else {
                    arr[k] = R[j];
                    j++;
                }
            } else {
                if (L[i].getPrice() >= R[j].getPrice()) {
                    arr[k] = L[i];
                    i++;
                } else {
                    arr[k] = R[j];
                    j++;
                }
            }
            k++;
        }
        
        while (i < n1) {
            arr[k] = L[i];
            i++;
            k++;
        }
        
        while (j < n2) {
            arr[k] = R[j];
            j++;
            k++;
        }
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
    
    // Get sorting preferences
    String sortOrder = request.getParameter("sort");
    boolean ascending = true; // default sorting order
    if (sortOrder != null && sortOrder.equals("desc")) {
        ascending = false;
    }
    
    // Get search parameters
    String searchMake = request.getParameter("make");
    String searchModel = request.getParameter("model");
    
    // Get all cars and sort them using merge sort
    CarListManager carManager = new CarListManager();
    List<Car> allCars;
    
    if (searchMake != null || searchModel != null) {
        // If search parameters provided, search and then sort
        allCars = carManager.searchCars(searchMake, searchModel);
        
        // Manual implementation of merge sort for the filtered list
        Car[] carsArray = allCars.toArray(new Car[0]);
        int n = carsArray.length;
        
        // Merge sort implementation (could be refactored to a utility class)
        for (int currSize = 1; currSize < n; currSize = 2 * currSize) {
            for (int leftStart = 0; leftStart < n - 1; leftStart += 2 * currSize) {
                int mid = Math.min(leftStart + currSize - 1, n - 1);
                int rightEnd = Math.min(leftStart + 2 * currSize - 1, n - 1);
                
                merge(carsArray, leftStart, mid, rightEnd, ascending);
            }
        }
        
        // Convert back to list
        allCars = Arrays.asList(carsArray);
    } else {
        // Get all cars sorted by price
        allCars = carManager.getAllCarsSortedByPrice(ascending);
    }
    
    // Get unique makes for filter dropdown
    Set<String> uniqueMakes = new HashSet<>();
    for (Car car : carManager.getAllCars()) {
        uniqueMakes.add(car.getMake());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Cars - CarTrader</title>
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
            overflow: hidden;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .car-card .card-img-top {
            height: 200px;
            object-fit: cover;
        }
        
        .car-price {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary-color);
        }
        
        .car-features {
            display: flex;
            justify-content: space-between;
            margin-top: 15px;
            font-size: 0.9rem;
            color: #6c757d;
        }
        
        .car-feature {
            display: flex;
            align-items: center;
        }
        
        .car-feature i {
            margin-right: 5px;
            color: var(--primary-color);
        }
        
        .filter-section {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }
        
        .filter-title {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 15px;
            color: var(--dark-color);
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
        
        .car-badge {
            position: absolute;
            top: 10px;
            left: 10px;
            padding: 5px 10px;
            border-radius: 5px;
            font-weight: 600;
            font-size: 12px;
            text-transform: uppercase;
        }
        
        .badge-new {
            background-color: var(--success-color);
            color: white;
        }
        
        .badge-featured {
            background-color: var(--warning-color);
            color: var(--dark-color);
        }
        
        .favorite-btn {
            position: absolute;
            top: 10px;
            right: 10px;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background-color: rgba(255,255,255,0.7);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .favorite-btn:hover {
            background-color: white;
        }
        
        .favorite-btn i {
            color: #6c757d;
            transition: all 0.3s;
        }
        
        .favorite-btn:hover i {
            color: var(--danger-color);
        }
        
        .favorite-btn.active i {
            color: var(--danger-color);
        }
        
        .no-results {
            text-align: center;
            padding: 40px 20px;
            background-color: white;
            border-radius: 10px;
            margin-top: 20px;
        }
        
        .no-results i {
            font-size: 3rem;
            color: #dee2e6;
            margin-bottom: 20px;
        }
        
        .no-results h3 {
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .no-results p {
            color: #6c757d;
        }
        
        .pagination-container {
            display: flex;
            justify-content: center;
            margin-top: 30px;
            margin-bottom: 20px;
        }
        
        .page-item.active .page-link {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .page-link {
            color: var(--primary-color);
        }
        
        .sort-info {
            font-size: 0.9rem;
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
            <li class="nav-item active">
                <a class="nav-link active" href="browse-cars.jsp">
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
                    <li><a class="dropdown-item" href="#"><i class="fas fa-cog"></i> Account Settings</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                </ul>
            </div>
        </div>
    </div>
    
    <!-- Content -->
    <div class="content">
        <div class="container-fluid">
            <!-- Browse Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>Browse Cars</h2>
                <div>
                    <a href="buyer-dashboard.jsp" class="btn btn-outline-secondary">
                        <i class="fas fa-chevron-left me-2"></i> Back to Dashboard
                    </a>
                </div>
            </div>
            
            <!-- Filters & Sort Section -->
            <div class="filter-section">
                <div class="row">
                    <div class="col-md-8">
                        <div class="filter-title">
                            <i class="fas fa-filter me-2"></i> Search and Filter
                        </div>
                        <form action="browse-cars.jsp" method="get" id="searchForm" class="row g-3">
                            <div class="col-md-4">
                                <select class="form-select" name="make" id="makeSelect">
                                    <option value="">Any Make</option>
                                    <% for(String make : uniqueMakes) { %>
                                        <option value="<%= make %>" <%= (searchMake != null && searchMake.equals(make)) ? "selected" : "" %>><%= make %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <input type="text" class="form-control" name="model" placeholder="Model" value="<%= searchModel != null ? searchModel : "" %>">
                            </div>
                            <input type="hidden" name="sort" value="<%= ascending ? "asc" : "desc" %>" id="sortField">
                            <div class="col-md-4">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-search me-2"></i> Search
                                </button>
                                <a href="browse-cars.jsp" class="btn btn-outline-secondary ms-2">
                                    <i class="fas fa-times me-2"></i> Clear
                                </a>
                            </div>
                        </form>
                    </div>
                    <div class="col-md-4">
                        <div class="filter-title">
                            <i class="fas fa-sort-amount-down me-2"></i> Sort By
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn <%= ascending ? "btn-primary" : "btn-outline-primary" %>" onclick="setSorting('asc')">
                                <i class="fas fa-sort-numeric-down me-2"></i> Price: Low to High
                            </button>
                            <button type="button" class="btn <%= !ascending ? "btn-primary" : "btn-outline-primary" %>" onclick="setSorting('desc')">
                                <i class="fas fa-sort-numeric-up me-2"></i> Price: High to Low
                            </button>
                        </div>
                        <div class="sort-info mt-2">
                            <i class="fas fa-info-circle me-1"></i> Sorted using Merge Sort algorithm
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Results Count -->
            <div class="d-flex justify-content-between mb-3 align-items-center">
                <div>
                    <h5 class="mb-0">Found <%= allCars.size() %> cars</h5>
                    <% if(searchMake != null || searchModel != null) { %>
                        <small class="text-muted">
                            Filtering by: <%= searchMake != null && !searchMake.isEmpty() ? searchMake : "" %> 
                            <%= searchModel != null && !searchModel.isEmpty() ? searchModel : "" %>
                        </small>
                    <% } %>
                </div>
                <div class="view-options">
                    <div class="btn-group" role="group">
                        <button type="button" class="btn btn-outline-secondary active" id="gridViewBtn">
                            <i class="fas fa-th-large"></i>
                        </button>
                        <button type="button" class="btn btn-outline-secondary" id="listViewBtn">
                            <i class="fas fa-list"></i>
                        </button>
                    </div>
                </div>
            </div>
            
            <!-- Car Listings -->
            <div class="row" id="carGrid">
                <% if(allCars.isEmpty()) { %>
                    <div class="col-12">
                        <div class="no-results">
                            <i class="fas fa-search"></i>
                            <h3>No Cars Found</h3>
                            <p>We couldn't find any cars matching your criteria. Please try broadening your search.</p>
                            <a href="browse-cars.jsp" class="btn btn-primary mt-3">Clear Filters</a>
                        </div>
                    </div>
                <% } else { %>
                    <% for (Car car : allCars) { %>
                        <div class="col-lg-4 col-md-6 mb-4">
                            <div class="card car-card h-100" data-car-id="<%= car.getId() %>">
                                <div style="position: relative;">
                                    <img src="<%= request.getContextPath() %>/<%= car.getPhotos().isEmpty() ? "car_images/default1.jpg" : car.getPhotos().get(0) %>" 
                                         class="card-img-top" alt="<%= car.getTitle() %>">
                                    
                                    <% if("New".equals(car.getCondition())) { %>
                                        <div class="car-badge badge-new">New</div>
                                    <% } %>
                                    
                                    <div class="favorite-btn" data-car-id="<%= car.getId() %>">
                                        <i class="far fa-heart"></i>
                                    </div>
                                </div>
                                
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <h5 class="card-title mb-0"><%= car.getYear() %> <%= car.getMake() %> <%= car.getModel() %></h5>
                                        <span class="car-price">$<%= String.format("%,.0f", car.getPrice()) %></span>
                                    </div>
                                    
                                    <p class="card-text text-muted">
                                        <%= car.getTrim() != null && !car.getTrim().isEmpty() ? car.getTrim() + " • " : "" %>
                                        <%= car.getBodyType() %>
                                    </p>
                                    
                                    <div class="car-features">
                                        <span class="car-feature">
                                            <i class="fas fa-tachometer-alt"></i>
                                            <%= String.format("%,d", car.getMileage()) %> mi
                                        </span>
                                        <span class="car-feature">
                                            <i class="fas fa-gas-pump"></i>
                                            <%= car.getFuelType() %>
                                        </span>
                                        <span class="car-feature">
                                            <i class="fas fa-cog"></i>
                                            <%= car.getTransmission() %>
                                        </span>
                                    </div>
                                    
                                    <hr>
                                    
                                    <div class="d-flex justify-content-between align-items-center">
                                        <small class="text-muted">
                                            <i class="fas fa-map-marker-alt me-1"></i> <%= car.getLocation() %>
                                        </small>
                                        <a href="view-car.jsp?id=<%= car.getId() %>" class="btn btn-sm btn-outline-primary">View Details</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            </div>
            
            <!-- Car Listings (List View) - Hidden by default -->
            <div class="car-list-view d-none" id="carList">
                <% if(!allCars.isEmpty()) { %>
                    <% for (Car car : allCars) { %>
                        <div class="card mb-3 car-card" data-car-id="<%= car.getId() %>">
                            <div class="row g-0">
                                <div class="col-md-4" style="position: relative;">
                                    <img src="<%= request.getContextPath() %>/<%= car.getPhotos().isEmpty() ? "car_images/default1.jpg" : car.getPhotos().get(0) %>" 
                                         class="img-fluid rounded-start" style="height: 100%; object-fit: cover;" 
                                         alt="<%= car.getTitle() %>">
                                    
                                    <% if("New".equals(car.getCondition())) { %>
                                        <div class="car-badge badge-new">New</div>
                                    <% } %>
                                    
                                    <div class="favorite-btn" data-car-id="<%= car.getId() %>">
                                        <i class="far fa-heart"></i>
                                    </div>
                                </div>
                                <div class="col-md-8">
                                    <div class="card-body">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <h5 class="card-title mb-0"><%= car.getYear() %> <%= car.getMake() %> <%= car.getModel() %></h5>
                                            <span class="car-price">$<%= String.format("%,.0f", car.getPrice()) %></span>
                                        </div>
                                        
                                        <p class="card-text text-muted">
                                            <%= car.getTrim() != null && !car.getTrim().isEmpty() ? car.getTrim() + " • " : "" %>
                                            <%= car.getBodyType() %>
                                        </p>
                                        
                                        <p class="card-text"><%= car.getDescription().length() > 100 ? car.getDescription().substring(0, 100) + "..." : car.getDescription() %></p>
                                        
                                        <div class="row mb-3">
                                            <div class="col-md-4">
                                                <span class="car-feature d-block mb-2">
                                                    <i class="fas fa-tachometer-alt"></i>
                                                    <%= String.format("%,d", car.getMileage()) %> miles
                                                </span>
                                            </div>
                                            <div class="col-md-4">
                                                <span class="car-feature d-block mb-2">
                                                    <i class="fas fa-gas-pump"></i>
                                                    <%= car.getFuelType() %>
                                                </span>
                                            </div>
                                            <div class="col-md-4">
                                                <span class="car-feature d-block mb-2">
                                                    <i class="fas fa-cog"></i>
                                                    <%= car.getTransmission() %>
                                                </span>
                                            </div>
                                        </div>
                                        
                                        <div class="d-flex justify-content-between align-items-center mt-3">
                                            <small class="text-muted">
                                                <i class="fas fa-map-marker-alt me-1"></i> <%= car.getLocation() %>
                                            </small>
                                            <div>
                                                <button class="btn btn-sm btn-outline-primary me-2">
                                                    <i class="fas fa-envelope me-1"></i> Contact Seller
                                                </button>
                                                <a href="view-car.jsp?id=<%= car.getId() %>" class="btn btn-sm btn-primary">View Details</a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            </div>
            
            <!-- Pagination if more than 12 cars -->
            <% if(allCars.size() > 12) { %>
                <div class="pagination-container">
                    <nav>
                        <ul class="pagination">
                            <li class="page-item disabled">
                                <a class="page-link" href="#" tabindex="-1">Previous</a>
                            </li>
                            <li class="page-item active"><a class="page-link" href="#">1</a></li>
                            <li class="page-item"><a class="page-link" href="#">2</a></li>
                            <li class="page-item"><a class="page-link" href="#">3</a></li>
                            <li class="page-item">
                                <a class="page-link" href="#">Next</a>
                            </li>
                        </ul>
                    </nav>
                </div>
            <% } %>
            
            <!-- Footer -->
            <footer class="mt-4">
                <div class="text-center text-muted">
                    <p>&copy; 2025 CarTrader. All rights reserved.</p>
                </div>
            </footer>
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
            
            // Toggle grid/list view
            const gridViewBtn = document.getElementById('gridViewBtn');
            const listViewBtn = document.getElementById('listViewBtn');
            const carGrid = document.getElementById('carGrid');
            const carList = document.getElementById('carList');
            
            gridViewBtn.addEventListener('click', function() {
                gridViewBtn.classList.add('active');
                listViewBtn.classList.remove('active');
                carGrid.classList.remove('d-none');
                carList.classList.add('d-none');
            });
            
            listViewBtn.addEventListener('click', function() {
                listViewBtn.classList.add('active');
                gridViewBtn.classList.remove('active');
                carList.classList.remove('d-none');
                carGrid.classList.add('d-none');
            });
            
            // Initialize favorite buttons with proper state and click handler
            const favoriteButtons = document.querySelectorAll('.favorite-btn');
            favoriteButtons.forEach(function(btn) {
                const carId = btn.getAttribute('data-car-id');
                checkIfCarSaved(carId, btn);
                
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    toggleFavorite(carId, this);
                });
            });
            
            // Add staggered animation to car cards
            const carCards = document.querySelectorAll('.car-card');
            carCards.forEach(function(card, index) {
                card.style.animationDelay = `${index * 0.1}s`;
            });
        });
        
        // Set sorting and submit form
        function setSorting(order) {
            document.getElementById('sortField').value = order;
            document.getElementById('searchForm').submit();
        }
        
        // Function to parse simple text response format "success=true;message=Car saved"
        function parseTextResponse(responseText) {
            const result = {};
            const parts = responseText.split(';');
            
            for (const part of parts) {
                const [key, value] = part.split('=');
                if (key === 'success') {
                    result[key] = value === 'true';
                } else {
                    result[key] = value;
                }
            }
            
            return result;
        }
        
        // Function to check if a car is saved
        function checkIfCarSaved(carId, btnElement) {
            const userId = '<%= userId %>'; // Get userId from session
            if (!userId) return;
            
            const xhr = new XMLHttpRequest();
            xhr.open('HEAD', 'SavedCarsServlet?userId=' + encodeURIComponent(userId) + '&carId=' + encodeURIComponent(carId), true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    const icon = btnElement.querySelector('i');
                    if (xhr.status === 200) {
                        // Car is saved, show filled heart
                        icon.classList.remove('far');
                        icon.classList.add('fas');
                        btnElement.classList.add('active');
                    } else {
                        // Car is not saved, show outline heart
                        icon.classList.remove('fas');
                        icon.classList.add('far');
                        btnElement.classList.remove('active');
                    }
                }
            };
            xhr.send();
        }
        
        // Function to toggle car favorite status
        function toggleFavorite(carId, btnElement) {
            const icon = btnElement.querySelector('i');
            const isSaved = icon.classList.contains('fas');
            const action = isSaved ? 'remove' : 'save';
            
            // Send AJAX request to save/unsave car
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'SavedCarsServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            const response = parseTextResponse(xhr.responseText);
                            if (response.success) {
                                // Toggle heart icon
                                if (action === 'save') {
                                    icon.classList.remove('far');
                                    icon.classList.add('fas');
                                    btnElement.classList.add('active');
                                } else {
                                    icon.classList.remove('fas');
                                    icon.classList.add('far');
                                    btnElement.classList.remove('active');
                                }
                            } else {
                                alert('Error: ' + response.message);
                            }
                        } catch (e) {
                            alert('Error parsing response: ' + e.message);
                        }
                    } else {
                        alert('Error: Server returned status ' + xhr.status);
                    }
                }
            };
            xhr.send('action=' + action + '&carId=' + encodeURIComponent(carId));
        }
    </script>
</body>
</html>