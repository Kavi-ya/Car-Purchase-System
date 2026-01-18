<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="com.carpurchase.model.*" %>
<%
    // Check if user is logged in as admin
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || !"admin".equalsIgnoreCase(userRole)) {
        // For testing purposes only
        username = "admin";
        fullName = "Administrator";
        userRole = "admin";
        //response.sendRedirect("login.jsp");
        //return;
    }
    
    // Path to car_list.txt file
    String dataDir = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data";
    String carListFile = "car_list.txt";
    File file = new File(dataDir, carListFile);
    
    // Variables for file metadata
    String fileDateTime = "";
    String currentUserLogin = "";
    
    // Stats variables
    int totalCars = 0;
    int activeCars = 0;
    int pendingCars = 0;
    int soldCars = 0;
    
    // Car makes for chart
    Map<String, Integer> carMakes = new HashMap<>();
    
    // Load car data from file
    try {
        boolean inCarRecord = false;
        String currentStatus = "";
        String currentMake = "";
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            int lineCount = 0;
            
            while ((line = reader.readLine()) != null) {
                lineCount++;
                
                // Read file metadata from first two lines
                if (lineCount == 1 && line.startsWith("Current Date and Time")) {
                    fileDateTime = line.substring(line.indexOf(":")+1).trim();
                    continue;
                }
                if (lineCount == 2 && line.startsWith("Current User's Login")) {
                    currentUserLogin = line.substring(line.indexOf(":")+1).trim();
                    continue;
                }
                
                // Begin car record processing
                if (line.equals("==== CAR LISTING RECORD ====")) {
                    inCarRecord = true;
                    currentStatus = "";
                    currentMake = "";
                    continue;
                }
                
                if (inCarRecord) {
                    if (line.startsWith("Status: ")) {
                        currentStatus = line.substring("Status: ".length()).trim();
                    } else if (line.startsWith("Make: ")) {
                        currentMake = line.substring("Make: ".length()).trim();
                    } else if (line.equals("-----------------------------")) {
                        // End of car record, count it
                        if (!currentMake.isEmpty()) {
                            totalCars++;
                            
                            // Add to make statistics - handle case sensitivity
                            String normalizedMake = currentMake.trim();
                            carMakes.put(normalizedMake, carMakes.getOrDefault(normalizedMake, 0) + 1);
                            
                            // Count by status
                            if ("Active".equalsIgnoreCase(currentStatus)) {
                                activeCars++;
                            } else if ("Sold".equalsIgnoreCase(currentStatus)) {
                                soldCars++;
                            } else if ("Pending".equalsIgnoreCase(currentStatus)) {
                                pendingCars++;
                            }
                        }
                        
                        inCarRecord = false;
                    }
                }
            }
        }
        
        // If no cars found, provide placeholder data
        if (carMakes.isEmpty()) {
            carMakes.put("No Data", 1);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        // Set default data in case of error
        totalCars = 0;
        activeCars = 0;
        soldCars = 0;
        pendingCars = 0;
        carMakes.put("Error", 1);
    }
    
    // Get recent activities (placeholder)
    List<String> recentActivities = new ArrayList<>();
    recentActivities.add("User john123 registered - 2 hours ago");
    recentActivities.add("New car listing added by seller777 - 5 hours ago");
    recentActivities.add("Car ID #45781 marked as sold - 1 day ago");
    recentActivities.add("User profile updated by mary22 - 2 days ago");
    recentActivities.add("Administrative action: System backup - 3 days ago");
    
    // Prepare chart data as JSON strings
    StringBuilder labelJson = new StringBuilder("[");
    StringBuilder dataJson = new StringBuilder("[");
    
    int i = 0;
    for (Map.Entry<String, Integer> entry : carMakes.entrySet()) {
        if (i > 0) {
            labelJson.append(",");
            dataJson.append(",");
        }
        labelJson.append("\"").append(entry.getKey()).append("\"");
        dataJson.append(entry.getValue());
        i++;
    }
    
    labelJson.append("]");
    dataJson.append("]");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - CarTrader</title>
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
        
        .stat-card {
            transition: transform 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-card .card-body {
            padding: 20px;
        }
        
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-bottom: 15px;
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #6c757d;
            font-weight: 500;
        }
        
        .bg-primary-light {
            background-color: rgba(58, 134, 255, 0.1);
            color: var(--primary-color);
        }
        
        .bg-success-light {
            background-color: rgba(56, 176, 0, 0.1);
            color: var(--success-color);
        }
        
        .bg-warning-light {
            background-color: rgba(255, 190, 11, 0.1);
            color: var(--warning-color);
        }
        
        .bg-danger-light {
            background-color: rgba(217, 4, 41, 0.1);
            color: var(--danger-color);
        }
        
        .bg-info-light {
            background-color: rgba(13, 202, 240, 0.1);
            color: #0dcaf0;
        }
        
        .bg-secondary-light {
            background-color: rgba(255, 0, 110, 0.1);
            color: var(--secondary-color);
        }
        
        .activity-list {
            padding-left: 0;
            list-style: none;
        }
        
        .activity-item {
            padding: 15px;
            border-left: 3px solid var(--primary-color);
            background-color: #fff;
            margin-bottom: 10px;
            border-radius: 5px;
            transition: transform 0.2s;
        }
        
        .activity-item:hover {
            transform: translateX(5px);
        }
        
        .activity-time {
            color: #6c757d;
            font-size: 0.85rem;
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

        .metadata-card {
            background-color: #f8f9fa;
            border-left: 4px solid var(--admin-color);
        }
        
        .metadata-value {
            font-weight: 500;
            color: #333;
        }
        
        .chart-container {
            position: relative;
            height: 300px;
            width: 100%;
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
            <li class="nav-item active">
                <a class="nav-link active" href="admin-dashboard.jsp">
                    <i class="fas fa-tachometer-alt"></i> Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="user-management.jsp">
                    <i class="fas fa-users"></i> User Management
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="car-management.jsp">
                    <i class="fas fa-car"></i> Car Listings
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="AdminProfileServlet">
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
                <h2>Admin Dashboard</h2>
                <div>
                    <button class="btn btn-outline-secondary me-2">
                        <i class="fas fa-download me-1"></i> Export Report
                    </button>
                    <button class="btn btn-primary" onClick="window.location.reload();">
                        <i class="fas fa-redo me-1"></i> Refresh Data
                    </button>
                </div>
            </div>
            
            <!-- Stats Cards -->
            <div class="row mb-4">
                <div class="col-md-6 col-lg-3">
                    <div class="card stat-card h-100">
                        <div class="card-body">
                            <div class="stat-icon bg-primary-light">
                                <i class="fas fa-car-side"></i>
                            </div>
                            <div class="stat-value"><%= totalCars %></div>
                            <div class="stat-label">Total Cars</div>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6 col-lg-3">
                    <div class="card stat-card h-100">
                        <div class="card-body">
                            <div class="stat-icon bg-success-light">
                                <i class="fas fa-tags"></i>
                            </div>
                            <div class="stat-value"><%= activeCars %></div>
                            <div class="stat-label">Active Listings</div>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6 col-lg-3">
                    <div class="card stat-card h-100">
                        <div class="card-body">
                            <div class="stat-icon bg-warning-light">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div class="stat-value"><%= pendingCars %></div>
                            <div class="stat-label">Pending Vehicles</div>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6 col-lg-3">
                    <div class="card stat-card h-100">
                        <div class="card-body">
                            <div class="stat-icon bg-danger-light">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div class="stat-value"><%= soldCars %></div>
                            <div class="stat-label">Sold Vehicles</div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="row">
                <!-- Chart -->
                <div class="col-md-6">
                    <div class="card h-100">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">Car Makes Distribution</h5>
                        </div>
                        <div class="card-body d-flex align-items-center justify-content-center">
                            <div class="chart-container">
                                <canvas id="makeDistributionChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Recent Activity -->
                <div class="col-md-6">
                    <div class="card h-100">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">Recent Activity</h5>
                            <button class="btn btn-sm btn-outline-primary">View All</button>
                        </div>
                        <div class="card-body">
                            <ul class="activity-list">
                                <% for (String activity : recentActivities) { 
                                    String[] parts = activity.split(" - ");
                                    String activityText = parts[0];
                                    String activityTime = parts.length > 1 ? parts[1] : "";
                                %>
                                <li class="activity-item">
                                    <div><%= activityText %></div>
                                    <div class="activity-time"><i class="far fa-clock me-1"></i> <%= activityTime %></div>
                                </li>
                                <% } %>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="row mt-4">
                <!-- Quick Actions -->
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">Quick Actions</h5>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-sm-4">
                                    <a href="car-management.jsp" class="btn btn-light w-100 d-flex align-items-center justify-content-start p-3">
                                        <i class="fas fa-car me-3 text-primary"></i>
                                        <span>Manage Car Listings</span>
                                    </a>
                                </div>
                                <div class="col-sm-4">
                                    <a href="user-management.jsp" class="btn btn-light w-100 d-flex align-items-center justify-content-start p-3">
                                        <i class="fas fa-users me-3 text-success"></i>
                                        <span>Manage Users</span>
                                    </a>
                                </div>
                                <div class="col-sm-4">
                                    <a href="#" class="btn btn-light w-100 d-flex align-items-center justify-content-start p-3">
                                        <i class="fas fa-cog me-3 text-info"></i>
                                        <span>User Settings</span>
                                    </a>
                                </div>
                            </div>
                        </div>
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
    <script>
        // Prepare chart data
        var chartLabels = <%= labelJson %>;
        var chartData = <%= dataJson %>;
        
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
            
            // Chart colors
            const colors = [
                'rgb(54, 162, 235)',    // Blue
                'rgb(255, 99, 132)',    // Red
                'rgb(75, 192, 192)',    // Green
                'rgb(255, 206, 86)',    // Yellow
                'rgb(153, 102, 255)',   // Purple
                'rgb(255, 159, 64)',    // Orange
                'rgb(201, 203, 207)'    // Grey
            ];
            
            // Generate background colors for all data points
            const backgroundColors = [];
            for (let i = 0; i < chartData.length; i++) {
                backgroundColors.push(colors[i % colors.length]);
            }
            
            // Calculate total for percentages
            const dataTotal = chartData.reduce((sum, value) => sum + value, 0);
            
            // Create pie chart with simplified approach
            try {
                var ctx = document.getElementById('makeDistributionChart').getContext('2d');
                var myPieChart = new Chart(ctx, {
                    type: 'pie',
                    data: {
                        labels: chartLabels,
                        datasets: [{
                            data: chartData,
                            backgroundColor: backgroundColors,
                            borderWidth: 1,
                            borderColor: '#fff'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'right',
                                labels: {
                                    font: {
                                        size: 12
                                    }
                                }
                            },
                            tooltip: {
                                displayColors: false,
                                callbacks: {
                                    label: function(context) {
                                        var value = context.raw;
                                        var percentage = Math.round((value / dataTotal) * 100);
                                        return context.label + ': ' + value + ' cars (' + percentage + '%)';
                                    }
                                }
                            }
                        }
                    }
                });
            } catch(e) {
                console.error("Chart error:", e);
                document.querySelector('.chart-container').innerHTML = 
                    '<div class="alert alert-warning">Error loading chart. Please reload the page.</div>';
            }
        });
    </script>
</body>
</html>