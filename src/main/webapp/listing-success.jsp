<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Check if user is logged in as a seller
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");
    String userRole = (String) session.getAttribute("userRole");
    
    if(username == null || !userRole.equalsIgnoreCase("seller")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Check if there is a listing ID in the request
    String listingId = request.getParameter("id");
    if(listingId == null || listingId.isEmpty()) {
        listingId = "Unknown";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Listing Added Successfully - CarTrader</title>
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
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .success-container {
            max-width: 650px;
            width: 100%;
            padding: 0 20px;
        }
        
        .success-card {
            background-color: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            padding: 40px;
            text-align: center;
            overflow: hidden;
        }
        
        .success-icon {
            width: 100px;
            height: 100px;
            background-color: rgba(56, 176, 0, 0.1);
            color: var(--success-color);
            font-size: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px auto;
        }
        
        .success-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 15px;
            color: var(--dark-color);
        }
        
        .success-message {
            color: #6c757d;
            margin-bottom: 30px;
            font-size: 18px;
        }
        
        .listing-id {
            background-color: rgba(58, 134, 255, 0.1);
            border-radius: 8px;
            padding: 12px 20px;
            margin-bottom: 30px;
            font-weight: 600;
            color: var(--primary-color);
            display: inline-block;
        }
        
        .actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 20px;
        }
        
        .btn-success-action {
            padding: 12px 20px;
            font-weight: 600;
            border-radius: 8px;
            text-decoration: none;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .btn-success-action:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }
        
        .confetti {
            position: absolute;
            width: 10px;
            height: 10px;
            background-color: #ffbe0b;
            border-radius: 50%;
            animation: confetti 3s ease-in-out infinite;
        }
        
        @keyframes confetti {
            0% {
                transform: translateY(0) rotate(0deg);
                opacity: 1;
            }
            100% {
                transform: translateY(100vh) rotate(720deg);
                opacity: 0;
            }
        }
        
        .confetti:nth-child(2n) {
            background-color: #3a86ff;
        }
        
        .confetti:nth-child(3n) {
            background-color: #ff006e;
        }
        
        .confetti:nth-child(4n) {
            background-color: #38b000;
        }
        
        /* Animation */
        .animate-success {
            animation: pop-in 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
            opacity: 0;
            transform: scale(0.8);
        }
        
        @keyframes pop-in {
            0% {
                opacity: 0;
                transform: scale(0.8);
            }
            100% {
                opacity: 1;
                transform: scale(1);
            }
        }
    </style>
</head>
<body>
    <div class="success-container">
        <div class="success-card animate-success">
            <div class="success-icon">
                <i class="fas fa-check"></i>
            </div>
            <h1 class="success-title">Listing Added Successfully!</h1>
            <p class="success-message">
                Your car listing has been published and is now live on CarTrader.
                Potential buyers can now view and inquire about your vehicle.
            </p>
            <div class="listing-id">
                Listing ID: <%= listingId %>
            </div>
            <div class="actions">
                <a href="seller-dashboard.jsp" class="btn btn-primary btn-success-action">
                    <i class="fas fa-tachometer-alt me-2"></i> Go to Dashboard
                </a>
                <a href="add-listing.jsp" class="btn btn-outline-primary btn-success-action">
                    <i class="fas fa-plus-circle me-2"></i> Add Another Listing
                </a>
            </div>
            <p class="mt-4 text-muted">
                Need help? <a href="#" class="text-decoration-none">Contact support</a>
            </p>
        </div>
    </div>
    
    <!-- Confetti animation -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Create confetti
            for (let i = 0; i < 50; i++) {
                createConfetti();
            }
        });
        
        function createConfetti() {
            const confetti = document.createElement('div');
            confetti.classList.add('confetti');
            
            // Random position
            confetti.style.left = Math.random() * 100 + 'vw';
            confetti.style.top = -20 + 'px';
            
            // Random size
            const size = Math.floor(Math.random() * 8) + 5;
            confetti.style.width = size + 'px';
            confetti.style.height = size + 'px';
            
            // Random delay
            confetti.style.animationDelay = Math.random() * 3 + 's';
            
            // Random duration
            confetti.style.animationDuration = Math.random() * 2 + 3 + 's';
            
            document.body.appendChild(confetti);
            
            // Remove after animation
            setTimeout(() => {
                confetti.remove();
            }, 5000);
        }
    </script>
</body>
</html>