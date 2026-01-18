<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.carpurchase.model.Car" %>
<%@ page import="com.carpurchase.model.CarListManager" %>

<%-- Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-05-06 09:18:20 --%>
<%-- Current User's Login: IT24102083 --%>

<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");
    String userRole = (String) session.getAttribute("userRole");
    String userId = (String) session.getAttribute("userId");
    
    if(username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get car ID from request
    String carId = request.getParameter("id");
    if(carId == null || carId.trim().isEmpty()) {
        response.sendRedirect("browse-cars.jsp");
        return;
    }
    
    // Get the car details
    CarListManager carManager = new CarListManager();
    Car car = carManager.getCarById(carId);
    
    if(car == null) {
        response.sendRedirect("browse-cars.jsp?error=notfound");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= car.getYear() %> <%= car.getMake() %> <%= car.getModel() %> - CarTrader</title>
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
        
        header {
            background-color: var(--dark-color);
            padding: 15px 0;
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        
        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: white;
            text-decoration: none;
            display: flex;
            align-items: center;
        }
        
        .logo:hover {
            color: white;
            opacity: 0.9;
        }
        
        .logo i {
            margin-right: 10px;
        }
        
        .user-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background-color: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            margin-right: 10px;
        }
        
        .main-content {
            padding: 30px 0;
        }
        
        .car-info-card {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .car-title {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 10px;
        }
        
        .car-price {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 20px;
        }
        
        .car-badges {
            margin-bottom: 20px;
        }
        
        .car-badge {
            display: inline-block;
            padding: 6px 12px;
            margin-right: 10px;
            margin-bottom: 10px;
            border-radius: 5px;
            font-weight: 600;
            font-size: 14px;
            text-transform: uppercase;
        }
        
        .badge-condition {
            background-color: rgba(58, 134, 255, 0.1);
            color: var(--primary-color);
        }
        
        .badge-year {
            background-color: rgba(56, 176, 0, 0.1);
            color: var(--success-color);
        }
        
        .badge-mileage {
            background-color: rgba(217, 4, 41, 0.1);
            color: var(--danger-color);
        }
        
        .car-gallery {
            margin-bottom: 30px;
        }
        
        .car-main-image {
            width: 100%;
            height: 400px;
            object-fit: cover;
            border-radius: 10px;
            margin-bottom: 15px;
        }
        
        .car-thumbnails {
            display: flex;
            gap: 10px;
            overflow-x: auto;
            padding-bottom: 10px;
        }
        
        .car-thumbnail {
            width: 100px;
            height: 75px;
            object-fit: cover;
            border-radius: 5px;
            cursor: pointer;
            opacity: 0.7;
            transition: opacity 0.3s;
        }
        
        .car-thumbnail:hover, .car-thumbnail.active {
            opacity: 1;
        }
        
        .specs-table {
            margin-bottom: 30px;
        }
        
        .specs-table .table {
            margin-bottom: 0;
        }
        
        .specs-table th {
            width: 30%;
            font-weight: 600;
        }
        
        .feature-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 30px;
        }
        
        .feature-item {
            background-color: rgba(58, 134, 255, 0.1);
            color: var(--primary-color);
            border-radius: 20px;
            padding: 5px 15px;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
        }
        
        .feature-item i {
            margin-right: 5px;
        }
        
        .action-buttons .btn {
            padding: 12px 25px;
            font-weight: 600;
            margin-right: 10px;
            margin-bottom: 10px;
        }
        
        .seller-info-card {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .seller-name {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .seller-info {
            margin-bottom: 20px;
        }
        
        .seller-info p {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .seller-info i {
            margin-right: 10px;
            width: 20px;
            color: var(--primary-color);
        }
        
        .inquiry-form .form-label {
            font-weight: 500;
        }
        
        .back-button {
            display: inline-flex;
            align-items: center;
            margin-bottom: 20px;
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 500;
        }
        
        .back-button i {
            margin-right: 10px;
        }
        
        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        
        @media (max-width: 768px) {
            .car-title {
                font-size: 1.5rem;
            }
            
            .car-price {
                font-size: 1.5rem;
            }
            
            .car-main-image {
                height: 300px;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header>
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <a href="index.jsp" class="logo">
                    <i class="fas fa-car-side"></i> CarTrader
                </a>
                
                <div class="dropdown">
                    <a href="#" class="text-white dropdown-toggle text-decoration-none" id="userDropdown" data-bs-toggle="dropdown">
                        <div class="d-flex align-items-center">
                            <div class="user-avatar">
                                <%= fullName.substring(0, 1).toUpperCase() %>
                            </div>
                            <span class="d-none d-md-inline"><%= fullName %></span>
                        </div>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="<%= userRole.equalsIgnoreCase("buyer") ? "buyer-dashboard.jsp" : "seller-dashboard.jsp" %>">Dashboard</a></li>
                        <% if(userRole.equalsIgnoreCase("buyer")) { %>
                            <li><a class="dropdown-item" href="SavedCarsServlet">Saved Cars</a></li>
                            <li><a class="dropdown-item" href="InquiryServlet">My Inquiries</a></li>
                        <% } %>
                        <li><a class="dropdown-item" href="#">My Profile</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="logout.jsp">Logout</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </header>
    
    <!-- Main Content -->
    <div class="main-content">
        <div class="container">
            <a href="browse-cars.jsp" class="back-button">
                <i class="fas fa-arrow-left"></i> Back to Browse Cars
            </a>
            
            <div class="row">
                <!-- Car Details -->
                <div class="col-lg-8">
                    <div class="car-info-card">
                        <div class="car-title"><%= car.getYear() %> <%= car.getMake() %> <%= car.getModel() %></div>
                        
                        <div class="car-badges">
                            <span class="car-badge badge-condition"><%= car.getCondition() %></span>
                            <span class="car-badge badge-year"><%= car.getYear() %></span>
                            <span class="car-badge badge-mileage"><%= String.format("%,d", car.getMileage()) %> miles</span>
                        </div>
                        
                        <div class="car-price">LKR<%= String.format("%,.0f", car.getPrice()) %></div>
                        
                        <div class="car-gallery">
                            <% 
                                String mainImage = "car_images/default1.jpg";
                                if(!car.getPhotos().isEmpty()) {
                                    mainImage = car.getPhotos().get(0);
                                }
                            %>
                            <img src="<%= mainImage %>" class="car-main-image" id="mainImage" alt="<%= car.getTitle() %>">
                            
                            <div class="car-thumbnails">
                                <% 
                                if(car.getPhotos().isEmpty()) { 
                                %>
                                    <img src="car_images/default1.jpg" class="car-thumbnail active" onclick="changeImage(this, 'car_images/default1.jpg')" alt="Default 1">
                                    <img src="car_images/default2.jpg" class="car-thumbnail" onclick="changeImage(this, 'car_images/default2.jpg')" alt="Default 2">
                                <% 
                                } else {
                                    boolean isFirst = true;
                                    for(String photo : car.getPhotos()) {
                                %>
                                    <img src="<%= photo %>" class="car-thumbnail <%= isFirst ? "active" : "" %>" 
                                         onclick="changeImage(this, '<%= photo %>')" alt="Car Photo">
                                <% 
                                        isFirst = false;
                                    }
                                } 
                                %>
                            </div>
                        </div>
                        
                        <div class="car-description mb-4">
                            <h3 class="section-title">Description</h3>
                            <p><%= car.getDescription() %></p>
                        </div>
                        
                        <div class="car-specs mb-4">
                            <h3 class="section-title">Specifications</h3>
                            <div class="specs-table">
                                <table class="table table-striped">
                                    <tbody>
                                        <tr>
                                            <th>Make</th>
                                            <td><%= car.getMake() %></td>
                                        </tr>
                                        <tr>
                                            <th>Model</th>
                                            <td><%= car.getModel() %></td>
                                        </tr>
                                        <tr>
                                            <th>Year</th>
                                            <td><%= car.getYear() %></td>
                                        </tr>
                                        <tr>
                                            <th>Body Type</th>
                                            <td><%= car.getBodyType() %></td>
                                        </tr>
                                        <tr>
                                            <th>Condition</th>
                                            <td><%= car.getCondition() %></td>
                                        </tr>
                                        <tr>
                                            <th>Mileage</th>
                                            <td><%= String.format("%,d", car.getMileage()) %> miles</td>
                                        </tr>
                                        <tr>
                                            <th>Exterior Color</th>
                                            <td><%= car.getExteriorColor() %></td>
                                        </tr>
                                        <% if(car.getInteriorColor() != null && !car.getInteriorColor().isEmpty()) { %>
                                        <tr>
                                            <th>Interior Color</th>
                                            <td><%= car.getInteriorColor() %></td>
                                        </tr>
                                        <% } %>
                                        <tr>
                                            <th>Transmission</th>
                                            <td><%= car.getTransmission() %></td>
                                        </tr>
                                        <tr>
                                            <th>Fuel Type</th>
                                            <td><%= car.getFuelType() %></td>
                                        </tr>
                                        <% if(car.getDoors() != null && !car.getDoors().isEmpty()) { %>
                                        <tr>
                                            <th>Doors</th>
                                            <td><%= car.getDoors() %></td>
                                        </tr>
                                        <% } %>
                                        <% if(car.getDriveType() != null && !car.getDriveType().isEmpty()) { %>
                                        <tr>
                                            <th>Drive Type</th>
                                            <td><%= car.getDriveType() %></td>
                                        </tr>
                                        <% } %>
                                        <% if(car.getEngine() != null && !car.getEngine().isEmpty()) { %>
                                        <tr>
                                            <th>Engine</th>
                                            <td><%= car.getEngine() %></td>
                                        </tr>
                                        <% } %>
                                        <% if(car.getVin() != null && !car.getVin().isEmpty()) { %>
                                        <tr>
                                            <th>VIN</th>
                                            <td><%= car.getVin() %></td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        
                        <% if(car.getFeatures() != null && !car.getFeatures().isEmpty()) { %>
                        <div class="car-features mb-4">
                            <h3 class="section-title">Features</h3>
                            <div class="feature-list">
                                <% for(String feature : car.getFeatures()) { %>
                                <div class="feature-item">
                                    <i class="fas fa-check"></i> <%= feature %>
                                </div>
                                <% } %>
                            </div>
                        </div>
                        <% } %>
                        
                        <div class="action-buttons">
                            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#inquiryModal">
                                <i class="fas fa-envelope me-2"></i> Contact Seller
                            </button>
                            <button class="btn btn-outline-primary" onclick="saveToFavorites('<%= car.getId() %>')">
                                <i class="fas fa-heart me-2"></i> Save to Favorites
                            </button>
                            <button class="btn btn-outline-secondary">
                                <i class="fas fa-share-alt me-2"></i> Share
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Seller Info -->
                <div class="col-lg-4">
                    <div class="seller-info-card">
                        <h3 class="seller-name">Seller Information</h3>
                        <div class="seller-info">
                            <p>
                                <i class="fas fa-user"></i>
                                <%= car.getContactName() %>
                            </p>
                            <p>
                                <i class="fas fa-map-marker-alt"></i>
                                <%= car.getLocation() %>
                            </p>
                            <p>
                                <i class="fas fa-phone"></i>
                                <%= (car.getContactPhone() != null && !car.getContactPhone().isEmpty()) ? car.getContactPhone() : "Not provided" %>
                            </p>
                            <p>
                                <i class="fas fa-envelope"></i>
                                <%= car.getContactEmail() %>
                            </p>
                        </div>
                        
                        <div class="listing-info">
                            <p><small class="text-muted">Listed on: <%= car.getListingDate() %></small></p>
                            <p><small class="text-muted">Listing ID: <%= car.getId() %></small></p>
                        </div>
                        
                        <button class="btn btn-primary w-100 mb-3" data-bs-toggle="modal" data-bs-target="#inquiryModal">
                            <i class="fas fa-envelope me-2"></i> Send Message
                        </button>
                        
                        <button class="btn btn-outline-primary w-100">
                            <i class="fas fa-phone me-2"></i> Request Call Back
                        </button>
                    </div>
                    
                    <div class="car-info-card">
                        <h3 class="section-title">Safety Tips</h3>
                        <ul class="mb-0">
                            <li>Meet the seller in a public place</li>
                            <li>Check the vehicle's history report</li>
                            <li>Inspect the vehicle before purchase</li>
                            <li>Test drive only when accompanied</li>
                            <li>Never wire money as a deposit</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Inquiry Modal -->
    <div class="modal fade" id="inquiryModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Contact Seller About This Car</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="inquiryForm">
                        <input type="hidden" name="carId" value="<%= car.getId() %>">
                        <input type="hidden" name="sellerId" value="<%= car.getSellerId() %>">
                        <input type="hidden" name="carTitle" value="<%= car.getYear() %> <%= car.getMake() %> <%= car.getModel() %>">
                        
                        <div class="mb-3">
                            <label for="inquiryName" class="form-label">Your Name</label>
                            <input type="text" class="form-control" id="inquiryName" name="inquiryName" value="<%= fullName %>" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="inquiryEmail" class="form-label">Your Email</label>
                            <input type="email" class="form-control" id="inquiryEmail" name="inquiryEmail" value="<%= session.getAttribute("email") != null ? session.getAttribute("email") : "" %>" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="inquiryPhone" class="form-label">Your Phone (Optional)</label>
                            <input type="tel" class="form-control" id="inquiryPhone" name="inquiryPhone">
                        </div>
                        
                        <div class="mb-3">
                            <label for="inquirySubject" class="form-label">Subject</label>
                            <select class="form-select" id="inquirySubject" name="inquirySubject" required>
                                <option value="Interested in <%= car.getYear() %> <%= car.getMake() %> <%= car.getModel() %>">I'm interested in this car</option>
                                <option value="Test Drive Request">I want to schedule a test drive</option>
                                <option value="Pricing Question">I have a question about the price</option>
                                <option value="Condition Question">I have a question about the condition</option>
                                <option value="Other Question">Other question</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="inquiryMessage" class="form-label">Message</label>
                            <textarea class="form-control" id="inquiryMessage" name="inquiryMessage" rows="4" required>Hi, I'm interested in your <%= car.getYear() %> <%= car.getMake() %> <%= car.getModel() %> listed for LKR<%= String.format("%,.0f", car.getPrice()) %>. Please contact me at your earliest convenience.</textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="submitInquiry()">Send Message</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Function to change main image when clicking on thumbnails
        function changeImage(thumbnail, imageSrc) {
            document.getElementById('mainImage').src = imageSrc;
            
            // Remove active class from all thumbnails
            document.querySelectorAll('.car-thumbnail').forEach(function(thumb) {
                thumb.classList.remove('active');
            });
            
            // Add active class to clicked thumbnail
            thumbnail.classList.add('active');
        }
        
        // Function to handle inquiry form submission
        function submitInquiry() {
            // Get form data
            const form = document.getElementById('inquiryForm');
            const formData = new FormData(form);
            
            // Convert FormData to URL-encoded string
            const urlEncodedData = new URLSearchParams(formData).toString();
            
            // Send AJAX request to save inquiry
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'InquiryServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            // Parse the text response format "success=true;message=Inquiry sent successfully"
                            const response = parseTextResponse(xhr.responseText);
                            
                            if (response.success) {
                                alert('Your message has been sent to the seller. They will contact you shortly.');
                                
                                // Close the modal
                                var modal = bootstrap.Modal.getInstance(document.getElementById('inquiryModal'));
                                modal.hide();
                            } else {
                                alert('Error: ' + response.message);
                            }
                        } catch (e) {
                            alert('Error processing the response');
                        }
                    } else {
                        alert('Error: Server returned status ' + xhr.status);
                    }
                }
            };
            xhr.send(urlEncodedData);
        }
        
        // Function to save car to favorites
        function saveToFavorites(carId) {
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
                                alert('Car saved to your favorites!');
                            } else {
                                alert('Error: ' + response.message);
                            }
                        } catch (e) {
                            alert('Error processing the response: ' + e.message);
                        }
                    } else {
                        alert('Error: Server returned status ' + xhr.status);
                    }
                }
            };
            xhr.send('action=save&carId=' + encodeURIComponent(carId));
        }
        
        // Function to parse simple text response format "success=true;message=Inquiry sent"
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
    </script>
</body>
</html>