<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
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
    
    // Generate a unique listing ID based on timestamp
    String listingId = "CAR" + System.currentTimeMillis();
    // Get current date for the form
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String currentDate = sdf.format(new java.util.Date());
    
    // Define the upload directory for images
    String uploadDirectory = application.getRealPath("/car_images");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Listing - CarTrader</title>
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
            margin-bottom: 20px;
        }
        
        .card-header {
            border-bottom: none;
            background: white;
            font-weight: 600;
            padding: 20px;
            border-radius: 10px 10px 0 0 !important;
        }
        
        .section-title {
            font-weight: 600;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        
        .form-label {
            font-weight: 500;
        }
        
        .form-control, .form-select {
            padding: 10px 15px;
            border-radius: 8px;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.25rem rgba(58, 134, 255, 0.25);
        }
        
        .image-preview {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 10px;
        }
        
        .preview-item {
            position: relative;
            width: 120px;
            height: 90px;
            border-radius: 8px;
            overflow: hidden;
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
        }
        
        .preview-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .preview-item .remove-btn {
            position: absolute;
            top: 5px;
            right: 5px;
            width: 20px;
            height: 20px;
            background-color: rgba(0,0,0,0.5);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            cursor: pointer;
        }
        
        .feature-checkbox {
            margin-right: 15px;
            margin-bottom: 10px;
        }
        
        .btn-submit {
            padding: 12px 20px;
            font-weight: 600;
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
        
        .page-header {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }
        
        .required-field::after {
            content: " *";
            color: var(--danger-color);
            font-weight: bold;
        }
        
        .dropzone {
            border: 2px dashed #ddd;
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            cursor: pointer;
            transition: border-color 0.3s;
        }
        
        .dropzone:hover, .dropzone.dragover {
            border-color: var(--primary-color);
        }
        
        .dropzone i {
            font-size: 2rem;
            color: #aaa;
            margin-bottom: 10px;
        }
        
        .dropzone p {
            margin-bottom: 0;
            color: #6c757d;
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
            <li class="nav-item active">
                <a class="nav-link active" href="add-listing.jsp">
                    <i class="fas fa-plus-circle"></i> Add New Listing
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="InquiryServlet">
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
            <!-- Page header -->
            <div class="page-header">
                <div class="d-flex justify-content-between align-items-center">
                    <h4 class="mb-0">Add New Vehicle Listing</h4>
                    <button type="button" class="btn btn-outline-secondary">
                        <i class="fas fa-question-circle me-2"></i> Help
                    </button>
                </div>
            </div>
            
            <!-- Add Listing Form -->
            <form id="addListingForm" action="AddListingServlet" method="post" enctype="multipart/form-data">
                <!-- Hidden fields for metadata -->
                <input type="hidden" name="listingId" value="<%= listingId %>">
                <input type="hidden" name="sellerId" value="<%= userId %>">
                <input type="hidden" name="listingDate" value="<%= currentDate %>">
                <input type="hidden" name="uploadDirectory" value="<%= uploadDirectory %>">
                
                <!-- Basic Information -->
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-info-circle me-2"></i> Basic Information
                    </div>
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="make" class="form-label required-field">Make</label>
                                <select class="form-select" id="make" name="make" required>
                                    <option value="">Select Make</option>
                                    <option value="Toyota">Toyota</option>
                                    <option value="Honda">Honda</option>
                                    <option value="BMW">BMW</option>
                                    <option value="Mercedes-Benz">Mercedes-Benz</option>
                                    <option value="Audi">Audi</option>
                                    <option value="Ford">Ford</option>
                                    <option value="Chevrolet">Chevrolet</option>
                                    <option value="Hyundai">Hyundai</option>
                                    <option value="Kia">Kia</option>
                                    <option value="Nissan">Nissan</option>
                                    <option value="Tesla">Tesla</option>
                                    <option value="Volkswagen">Volkswagen</option>
                                    <option value="Lexus">Lexus</option>
                                    <option value="Mazda">Mazda</option>
                                    <option value="Subaru">Subaru</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="otherMake" class="form-label">Other Make (if applicable)</label>
                                <input type="text" class="form-control" id="otherMake" name="otherMake">
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="model" class="form-label required-field">Model</label>
                                <input type="text" class="form-control" id="model" name="model" required>
                            </div>
                            <div class="col-md-6">
                                <label for="year" class="form-label required-field">Year</label>
                                <select class="form-select" id="year" name="year" required>
                                    <option value="">Select Year</option>
                                    <% 
                                        int currentYear = java.time.Year.now().getValue();
                                        for(int i = currentYear + 1; i >= 1970; i--) {
                                    %>
                                        <option value="<%= i %>"><%= i %></option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="bodyType" class="form-label required-field">Body Type</label>
                                <select class="form-select" id="bodyType" name="bodyType" required>
                                    <option value="">Select Body Type</option>
                                    <option value="Sedan">Sedan</option>
                                    <option value="SUV">SUV</option>
                                    <option value="Truck">Truck</option>
                                    <option value="Coupe">Coupe</option>
                                    <option value="Convertible">Convertible</option>
                                    <option value="Hatchback">Hatchback</option>
                                    <option value="Wagon">Wagon</option>
                                    <option value="Van">Van</option>
                                    <option value="Minivan">Minivan</option>
                                    <option value="Crossover">Crossover</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="trim" class="form-label">Trim Level</label>
                                <input type="text" class="form-control" id="trim" name="trim" placeholder="e.g. EX, LX, Limited, Sport">
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <label for="condition" class="form-label required-field">Condition</label>
                                <select class="form-select" id="condition" name="condition" required>
                                    <option value="">Select Condition</option>
                                    <option value="New">New</option>
                                    <option value="Used - Like New">Used - Like New</option>
                                    <option value="Used - Excellent">Used - Excellent</option>
                                    <option value="Used - Good">Used - Good</option>
                                    <option value="Used - Fair">Used - Fair</option>
                                    <option value="Used - Poor">Used - Poor</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="vin" class="form-label">VIN (Vehicle Identification Number)</label>
                                <input type="text" class="form-control" id="vin" name="vin" maxlength="17">
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Vehicle Details -->
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-car me-2"></i> Vehicle Details
                    </div>
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="mileage" class="form-label required-field">Mileage</label>
                                <div class="input-group">
                                    <input type="number" class="form-control" id="mileage" name="mileage" min="0" required>
                                    <span class="input-group-text">miles</span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label for="exteriorColor" class="form-label required-field">Exterior Color</label>
                                <input type="text" class="form-control" id="exteriorColor" name="exteriorColor" required>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="interiorColor" class="form-label">Interior Color</label>
                                <input type="text" class="form-control" id="interiorColor" name="interiorColor">
                            </div>
                            <div class="col-md-6">
                                <label for="transmission" class="form-label required-field">Transmission</label>
                                <select class="form-select" id="transmission" name="transmission" required>
                                    <option value="">Select Transmission</option>
                                    <option value="Automatic">Automatic</option>
                                    <option value="Manual">Manual</option>
                                    <option value="CVT">CVT</option>
                                    <option value="Automated Manual">Automated Manual (Dual-Clutch)</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="fuelType" class="form-label required-field">Fuel Type</label>
                                <select class="form-select" id="fuelType" name="fuelType" required>
                                    <option value="">Select Fuel Type</option>
                                    <option value="Gasoline">Gasoline</option>
                                    <option value="Diesel">Diesel</option>
                                    <option value="Hybrid">Hybrid</option>
                                    <option value="Plug-in Hybrid">Plug-in Hybrid</option>
                                    <option value="Electric">Electric</option>
                                    <option value="Hydrogen">Hydrogen</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="doors" class="form-label">Number of Doors</label>
                                <select class="form-select" id="doors" name="doors">
                                    <option value="">Select</option>
                                    <option value="2">2</option>
                                    <option value="3">3</option>
                                    <option value="4">4</option>
                                    <option value="5">5</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <label for="driveType" class="form-label">Drive Type</label>
                                <select class="form-select" id="driveType" name="driveType">
                                    <option value="">Select Drive Type</option>
                                    <option value="FWD">FWD (Front-Wheel Drive)</option>
                                    <option value="RWD">RWD (Rear-Wheel Drive)</option>
                                    <option value="AWD">AWD (All-Wheel Drive)</option>
                                    <option value="4WD">4WD (Four-Wheel Drive)</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="engine" class="form-label">Engine</label>
                                <input type="text" class="form-control" id="engine" name="engine" placeholder="e.g. 2.0L Turbo 4-cylinder">
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Listing Details -->
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-tag me-2"></i> Listing Details
                    </div>
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="title" class="form-label required-field">Listing Title</label>
                                <input type="text" class="form-control" id="title" name="title" required>
                                <small class="text-muted">Example: 2023 Toyota Camry XSE - Low Miles, One Owner</small>
                            </div>
                            <div class="col-md-6">
                                <label for="price" class="form-label required-field">Price (LKR)</label>
                                <div class="input-group">
                                    <span class="input-group-text">LKR</span>
                                    <input type="number" class="form-control" id="price" name="price" min="0" step="0.01" required>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="description" class="form-label required-field">Description</label>
                            <textarea class="form-control" id="description" name="description" rows="5" required></textarea>
                            <small class="text-muted">
                                Provide a detailed description of your vehicle including its condition, history, special features, and any other information potential buyers should know.
                            </small>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Features</label>
                            <div class="row">
                                <div class="col-md-3 col-sm-6">
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature1" name="features" value="Air Conditioning">
                                        <label class="form-check-label" for="feature1">Air Conditioning</label>
                                    </div>
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature2" name="features" value="Power Windows">
                                        <label class="form-check-label" for="feature2">Power Windows</label>
                                    </div>
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature3" name="features" value="Power Locks">
                                        <label class="form-check-label" for="feature3">Power Locks</label>
                                    </div>
                                </div>
                                <div class="col-md-3 col-sm-6">
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature4" name="features" value="Cruise Control">
                                        <label class="form-check-label" for="feature4">Cruise Control</label>
                                    </div>
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature5" name="features" value="Navigation System">
                                        <label class="form-check-label" for="feature5">Navigation System</label>
                                    </div>
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature6" name="features" value="Bluetooth">
                                        <label class="form-check-label" for="feature6">Bluetooth</label>
                                    </div>
                                </div>
                                <div class="col-md-3 col-sm-6">
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature7" name="features" value="Leather Seats">
                                        <label class="form-check-label" for="feature7">Leather Seats</label>
                                    </div>
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature8" name="features" value="Sunroof">
                                        <label class="form-check-label" for="feature8">Sunroof/Moonroof</label>
                                    </div>
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature9" name="features" value="Heated Seats">
                                        <label class="form-check-label" for="feature9">Heated Seats</label>
                                    </div>
                                </div>
                                <div class="col-md-3 col-sm-6">
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature10" name="features" value="Backup Camera">
                                        <label class="form-check-label" for="feature10">Backup Camera</label>
                                    </div>
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature11" name="features" value="Parking Sensors">
                                        <label class="form-check-label" for="feature11">Parking Sensors</label>
                                    </div>
                                    <div class="form-check feature-checkbox">
                                        <input class="form-check-input" type="checkbox" id="feature12" name="features" value="Premium Sound">
                                        <label class="form-check-label" for="feature12">Premium Sound</label>
                                    </div>
                                </div>
                            </div>
                            <div class="mt-2">
                                <label for="otherFeatures" class="form-label">Other Features</label>
                                <input type="text" class="form-control" id="otherFeatures" name="otherFeatures" placeholder="List other features separated by commas">
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Photos -->
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-images me-2"></i> Photos
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label required-field">Upload Vehicle Photos</label>
                            <div class="dropzone" id="photoDropzone">
                                <input type="file" id="photoInput" name="photos" multiple accept="image/*" style="display: none;">
                                <i class="fas fa-cloud-upload-alt"></i>
                                <p>Drag and drop photos here, or click to select files</p>
                                <small class="text-muted">Upload up to 10 high-quality images of your vehicle (max 5MB each)</small>
                            </div>
                            <div class="image-preview" id="imagePreview"></div>
                            <small class="text-muted mt-2">
                                <i class="fas fa-info-circle"></i> Images will be automatically renamed to include your car ID and stored in the car_images folder.
                            </small>
                        </div>
                    </div>
                </div>
                
                <!-- Contact Information -->
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-user me-2"></i> Contact Information
                    </div>
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="contactName" class="form-label required-field">Contact Name</label>
                                <input type="text" class="form-control" id="contactName" name="contactName" value="<%= fullName %>" required>
                            </div>
                            <div class="col-md-6">
                                <label for="contactEmail" class="form-label required-field">Email</label>
                                <input type="email" class="form-control" id="contactEmail" name="contactEmail" value="<%= session.getAttribute("email") %>" required>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <label for="contactPhone" class="form-label">Phone Number</label>
                                <input type="tel" class="form-control" id="contactPhone" name="contactPhone">
                            </div>
                            <div class="col-md-6">
                                <label for="location" class="form-label required-field">Location</label>
                                <input type="text" class="form-control" id="location" name="location" placeholder="City, State" required>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Submit Button -->
                <div class="d-flex justify-content-between mt-4 mb-4">
                    <button type="button" class="btn btn-outline-secondary" onclick="window.location.href='seller-dashboard.jsp'">
                        <i class="fas fa-arrow-left me-2"></i> Back to Dashboard
                    </button>
                    <div>
                        <button type="button" class="btn btn-outline-secondary me-2" id="saveDraft">
                            <i class="fas fa-save me-2"></i> Save as Draft
                        </button>
                        <button type="submit" class="btn btn-primary btn-submit">
                            <i class="fas fa-check-circle me-2"></i> Publish Listing
                        </button>
                    </div>
                </div>
            </form>
            
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
            
            // Make and other make field logic
            const makeSelect = document.getElementById('make');
            const otherMakeField = document.getElementById('otherMake');
            
            makeSelect.addEventListener('change', function() {
                if (this.value === 'Other') {
                    otherMakeField.required = true;
                    otherMakeField.parentElement.querySelector('label').classList.add('required-field');
                } else {
                    otherMakeField.required = false;
                    otherMakeField.parentElement.querySelector('label').classList.remove('required-field');
                }
            });
            
            // Auto-generate listing title
            const makeInput = document.getElementById('make');
            const modelInput = document.getElementById('model');
            const yearInput = document.getElementById('year');
            const titleInput = document.getElementById('title');
            
            function updateTitle() {
                if (makeInput.value && modelInput.value && yearInput.value) {
                    titleInput.value = yearInput.value + ' ' + makeInput.value + ' ' + modelInput.value;
                }
            }
            
            makeInput.addEventListener('change', updateTitle);
            modelInput.addEventListener('input', updateTitle);
            yearInput.addEventListener('change', updateTitle);
            
            // Photo upload functionality with tracking of file objects
            const dropzone = document.getElementById('photoDropzone');
            const photoInput = document.getElementById('photoInput');
            const imagePreview = document.getElementById('imagePreview');
            let uploadedFiles = []; // To keep track of the actual files
            
            dropzone.addEventListener('click', function() {
                photoInput.click();
            });
            
            dropzone.addEventListener('dragover', function(e) {
                e.preventDefault();
                dropzone.classList.add('dragover');
            });
            
            dropzone.addEventListener('dragleave', function() {
                dropzone.classList.remove('dragover');
            });
            
            dropzone.addEventListener('drop', function(e) {
                e.preventDefault();
                dropzone.classList.remove('dragover');
                
                if (e.dataTransfer.files) {
                    handleFiles(e.dataTransfer.files);
                }
            });
            
            photoInput.addEventListener('change', function() {
                handleFiles(this.files);
            });
            
            function handleFiles(files) {
                if (uploadedFiles.length + files.length > 10) {
                    alert('You can only upload up to 10 images');
                    return;
                }
                
                for (let i = 0; i < files.length; i++) {
                    if (!files[i].type.startsWith('image/')) {
                        continue;
                    }
                    
                    if (files[i].size > 5 * 1024 * 1024) { // 5MB
                        alert('File ' + files[i].name + ' is too large. Max file size is 5MB.');
                        continue;
                    }
                    
                    const fileIndex = uploadedFiles.length;
                    uploadedFiles.push(files[i]);
                    
                    const reader = new FileReader();
                    
                    reader.onload = function(e) {
                        const div = document.createElement('div');
                        div.className = 'preview-item';
                        div.dataset.index = fileIndex;
                        
                        const img = document.createElement('img');
                        img.src = e.target.result;
                        
                        const removeBtn = document.createElement('div');
                        removeBtn.className = 'remove-btn';
                        removeBtn.innerHTML = '<i class="fas fa-times"></i>';
                        removeBtn.addEventListener('click', function() {
                            // Remove this file from our array and from the preview
                            uploadedFiles[div.dataset.index] = null; // Mark as deleted
                            div.remove();
                        });
                        
                        div.appendChild(img);
                        div.appendChild(removeBtn);
                        imagePreview.appendChild(div);
                    };
                    
                    reader.readAsDataURL(files[i]);
                }
                
                // Create a new FileList to replace the input's files
                createFileInputWithFiles();
            }
            
            function createFileInputWithFiles() {
                // This is to prepare files for form submission
                const dataTransfer = new DataTransfer();
                uploadedFiles.forEach(file => {
                    if (file) dataTransfer.items.add(file);
                });
                
                // Replace the file input's files with our curated list
                photoInput.files = dataTransfer.files;
            }
            
            // Form validation
            const form = document.getElementById('addListingForm');
            
            form.addEventListener('submit', function(e) {
                // Prepare the actual files that will be submitted (removing any nulls)
                createFileInputWithFiles();
                
                // Check if at least one photo was added
                if (photoInput.files.length === 0) {
                    e.preventDefault();
                    alert('Please upload at least one photo of your vehicle');
                    return;
                }
                
                // Validate price
                const price = document.getElementById('price');
                if (price.value <= 0) {
                    e.preventDefault();
                    alert('Please enter a valid price');
                    price.focus();
                    return;
                }
                
                // Validate mileage for used cars
                const condition = document.getElementById('condition');
                const mileage = document.getElementById('mileage');
                
                if (condition.value.startsWith('Used') && mileage.value == 0) {
                    e.preventDefault();
                    alert('Please enter the vehicle mileage');
                    mileage.focus();
                    return;
                }
                
                // Add loading state to submit button
                const submitBtn = document.querySelector('button[type="submit"]');
                submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Publishing...';
                submitBtn.disabled = true;
                
                // Send all the selected files as multipart form data
                // The AddListingServlet will then handle renaming the files using the car ID
            });
            
            // Save draft functionality (just a placeholder - would need backend implementation)
            document.getElementById('saveDraft').addEventListener('click', function() {
                alert('Draft saving functionality would be implemented here');
            });
        });
    </script>
</body>
</html>