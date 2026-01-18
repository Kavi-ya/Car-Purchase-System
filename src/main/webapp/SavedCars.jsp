<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.carpurchase.model.Car" %>

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
    
    // Get saved cars from request (set by servlet)
    List<Car> savedCars = (List<Car>) request.getAttribute("savedCars");
    
    // If accessed directly without going through the servlet, redirect to the servlet
    if (savedCars == null) {
        response.sendRedirect("SavedCarsServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Saved Cars - CarTrader</title>
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
        
        .remove-favorite-btn {
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
        
        .remove-favorite-btn:hover {
            background-color: white;
        }
        
        .remove-favorite-btn i {
            color: var(--danger-color);
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
            <li class="nav-item active">
                <a class="nav-link active" href="SavedCarsServlet">
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
            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>My Saved Cars</h2>
                <div>
                    <a href="browse-cars.jsp" class="btn btn-primary">
                        <i class="fas fa-search me-2"></i> Browse More Cars
                    </a>
                </div>
            </div>
            
            <!-- Stats Summary -->
            <div class="row mb-4">
                <div class="col-md-3 mb-3 mb-md-0">
                    <div class="card h-100">
                        <div class="card-body text-center">
                            <i class="fas fa-heart fa-2x text-danger mb-3"></i>
                            <h4><%= savedCars.size() %></h4>
                            <p class="text-muted mb-0">Cars Saved</p>
                        </div>
                    </div>
                </div>
                <% if (!savedCars.isEmpty()) { %>
                    <div class="col-md-3 mb-3 mb-md-0">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <%
                                    // Calculate average price
                                    double totalPrice = 0;
                                    for (Car car : savedCars) {
                                        totalPrice += car.getPrice();
                                    }
                                    double avgPrice = savedCars.isEmpty() ? 0 : totalPrice / savedCars.size();
                                %>
                                <i class="fas fa-dollar-sign fa-2x text-success mb-3"></i>
                                <h4>LKR <%= String.format("%,.0f", avgPrice) %></h4>
                                <p class="text-muted mb-0">Average Price</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3 mb-md-0">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <%
                                    // Find newest car (by year)
                                    int newestYear = 0;
                                    for (Car car : savedCars) {
                                        if (car.getYear() > newestYear) {
                                            newestYear = car.getYear();
                                        }
                                    }
                                %>
                                <i class="fas fa-calendar-alt fa-2x text-primary mb-3"></i>
                                <h4><%= newestYear %></h4>
                                <p class="text-muted mb-0">Newest Model</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <%
                                    // Calculate most common make
                                    Map<String, Integer> makeCounts = new HashMap<>();
                                    String mostCommonMake = "";
                                    int maxCount = 0;
                                    
                                    for (Car car : savedCars) {
                                        String make = car.getMake();
                                        int count = makeCounts.getOrDefault(make, 0) + 1;
                                        makeCounts.put(make, count);
                                        
                                        if (count > maxCount) {
                                            maxCount = count;
                                            mostCommonMake = make;
                                        }
                                    }
                                %>
                                <i class="fas fa-car fa-2x text-info mb-3"></i>
                                <h4><%= mostCommonMake %></h4>
                                <p class="text-muted mb-0">Favorite Brand</p>
                            </div>
                        </div>
                    </div>
                <% } else { %>
                    <div class="col-md-9">
                        <div class="card h-100">
                            <div class="card-body d-flex align-items-center justify-content-center">
                                <p class="text-muted mb-0">Start saving cars to see your statistics here</p>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
            
            <!-- Saved Cars List -->
            <div class="row" id="savedCarsGrid">
                <% if (savedCars.isEmpty()) { %>
                    <div class="col-12">
                        <div class="empty-state">
                            <i class="fas fa-heart-broken"></i>
                            <h3>No Saved Cars Yet</h3>
                            <p>You haven't saved any cars to your favorites. Browse cars and click the heart icon to save them here.</p>
                            <a href="browse-cars.jsp" class="btn btn-primary">
                                <i class="fas fa-search me-2"></i> Browse Cars Now
                            </a>
                        </div>
                    </div>
                <% } else { %>
                    <% for (Car car : savedCars) { %>
                        <div class="col-lg-4 col-md-6 mb-4">
                            <div class="card car-card h-100" data-car-id="<%= car.getId() %>">
                                <div style="position: relative;">
                                    <img src="<%= request.getContextPath() %>/<%= car.getPhotos().isEmpty() ? "car_images/default1.jpg" : car.getPhotos().get(0) %>" 
                                         class="card-img-top" alt="<%= car.getTitle() %>">
                                    
                                    <% if("New".equals(car.getCondition())) { %>
                                        <div class="car-badge badge-new">New</div>
                                    <% } %>
                                    
                                    <div class="remove-favorite-btn" data-car-id="<%= car.getId() %>">
                                        <i class="fas fa-heart"></i>
                                    </div>
                                </div>
                                
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <h5 class="card-title mb-0"><%= car.getYear() %> <%= car.getMake() %> <%= car.getModel() %></h5>
                                        <span class="car-price">LKR <%= String.format("%,.0f", car.getPrice()) %></span>
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
            
            // Handle remove from favorites
            const removeFavoriteButtons = document.querySelectorAll('.remove-favorite-btn');
            removeFavoriteButtons.forEach(function(btn) {
                btn.addEventListener('click', function() {
                    const carId = this.getAttribute('data-car-id');
                    removeFromFavorites(carId, this);
                });
            });
            
            // Add staggered animation to car cards
            const carCards = document.querySelectorAll('.car-card');
            carCards.forEach(function(card, index) {
                card.style.animationDelay = `${index * 0.1}s`;
            });
        });
        
        // Function to parse simple text response format "success=true;message=Car removed"
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
        
        // Function to remove car from favorites
        function removeFromFavorites(carId, btnElement) {
            // Show confirmation dialog
            if (!confirm('Are you sure you want to remove this car from your favorites?')) {
                return;
            }
            
            // Send AJAX request to remove car from favorites
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'SavedCarsServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            const response = parseTextResponse(xhr.responseText);
                            if (response.success) {
                                // Find and remove the car card from the UI
                                const carCard = btnElement.closest('.car-card');
                                if (carCard) {
                                    carCard.style.opacity = '0';
                                    setTimeout(() => {
                                        carCard.parentNode.remove();
                                        
                                        // Check if there are no more cars
                                        const remainingCards = document.querySelectorAll('.car-card');
                                        if (remainingCards.length === 0) {
                                            // Reload the page to show empty state
                                            window.location.reload();
                                        } else {
                                            // Update the count in stats
                                            updateStats();
                                        }
                                    }, 500);
                                }
                            } else {
                                alert('Error: ' + response.message);
                            }
                        } catch (e) {
                            alert('Error parsing response');
                        }
                    } else {
                        alert('Error: Server returned status ' + xhr.status);
                    }
                }
            };
            xhr.send('action=remove&carId=' + encodeURIComponent(carId));
        }
        
        // Function to update the stats after removing a car
        function updateStats() {
            const carCountElement = document.querySelector('.col-md-3:first-child h4');
            if (carCountElement) {
                const currentCount = parseInt(carCountElement.textContent) - 1;
                carCountElement.textContent = currentCount;
                
                // If there would be no more cars, reload to show empty state
                if (currentCount === 0) {
                    window.location.reload();
                }
            }
        }
    </script>
</body>
</html>