<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - CarTrader</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #3a86ff;
            --secondary-color: #ff006e;
            --dark-color: #212529;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background-image: url('https://images.unsplash.com/photo-1557702899-2e98d8bf3d7a?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1650&q=80');
            background-size: cover;
            background-position: center;
            padding: 15px;
            position: relative;
        }
        
        .login-container {
            width: 100%;
            max-width: 360px; /* Reduced from 450px */
            padding: 0;
            margin: 15px auto;
        }
        
        .card {
            border: none;
            border-radius: 12px; /* Reduced from 15px */
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            background-color: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(5px);
        }
        
        .card-header {
            background-color: var(--primary-color);
            color: white;
            text-align: center;
            padding: 15px 12px; /* Reduced from 25px 15px */
            border-bottom: none;
        }
        
        .card-header .logo {
            font-size: 1.5rem; /* Reduced from 1.8rem */
            font-weight: bold;
            margin-bottom: 5px; /* Reduced from 10px */
        }
        
        .card-header p {
            margin-bottom: 0;
            opacity: 0.9;
            font-size: 0.85rem; /* Added smaller font size */
        }
        
        .card-body {
            padding: 18px 15px; /* Reduced from 30px 20px */
        }
        
        .form-floating {
            margin-bottom: 14px; /* Reduced from 20px */
        }
        
        .form-floating label {
            color: #6c757d;
            font-size: 0.9rem; /* Added smaller font size */
        }
        
        .form-control {
            padding: 0.6rem 0.75rem; /* Reduced padding */
            font-size: 0.9rem; /* Smaller font size */
        }
        
        .form-floating > .form-control {
            height: calc(2.5rem + 2px); /* Reduced height */
        }
        
        .form-floating > label {
            padding: 0.5rem 0.75rem; /* Adjusted padding */
        }
        
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(58, 134, 255, 0.25);
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
            padding: 7px; /* Reduced from 10px */
            font-weight: 600;
            transition: transform 0.3s, box-shadow 0.3s;
            font-size: 0.9rem; /* Smaller font size */
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(0, 0, 0, 0.2);
        }
        
        .divider {
            text-align: center;
            margin: 12px 0; /* Reduced from 20px */
            position: relative;
        }
        
        .divider:before {
            content: '';
            position: absolute;
            top: 50%;
            left: 0;
            width: 45%;
            height: 1px;
            background-color: #dee2e6;
        }
        
        .divider:after {
            content: '';
            position: absolute;
            top: 50%;
            right: 0;
            width: 45%;
            height: 1px;
            background-color: #dee2e6;
        }
        
        .divider span {
            display: inline-block;
            padding: 0 8px;
            background-color: #fff;
            position: relative;
            z-index: 1;
            color: #6c757d;
            font-size: 0.8rem; /* Smaller font size */
        }
        
        .social-login {
            display: flex;
            justify-content: center;
            gap: 12px; /* Reduced from 15px */
            margin-bottom: 12px; /* Reduced from 20px */
        }
        
        .social-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 36px; /* Reduced from 48px */
            height: 36px; /* Reduced from 48px */
            border-radius: 50%;
            border: 1px solid #dee2e6;
            font-size: 1rem; /* Reduced from 1.2rem */
            transition: transform 0.3s, background-color 0.3s;
        }
        
        .social-btn:hover {
            transform: translateY(-2px);
        }
        
        .facebook {
            color: #3b5998;
        }
        
        .facebook:hover {
            background-color: #3b5998;
            color: white;
        }
        
        .google {
            color: #db4437;
        }
        
        .google:hover {
            background-color: #db4437;
            color: white;
        }
        
        .twitter {
            color: #1da1f2;
        }
        
        .twitter:hover {
            background-color: #1da1f2;
            color: white;
        }
        
        .forgot-password {
            text-align: center;
            margin-top: 10px; /* Reduced from 15px */
        }
        
        .forgot-password a {
            color: var(--primary-color);
            text-decoration: none;
            transition: color 0.3s;
            font-size: 0.85rem; /* Smaller font size */
        }
        
        .forgot-password a:hover {
            color: #1a56cc;
            text-decoration: underline;
        }
        
        .register-link {
            text-align: center;
            padding: 10px; /* Reduced from 15px */
            background-color: #f8f9fa;
            border-top: 1px solid #dee2e6;
            font-size: 0.85rem; /* Smaller font size */
        }
        
        .register-link a {
            color: var(--primary-color);
            font-weight: 600;
            text-decoration: none;
        }
        
        .register-link a:hover {
            text-decoration: underline;
        }
        
        .input-group-text {
            cursor: pointer;
            background-color: white;
        }
        
        .error-message {
            color: #dc3545;
            font-size: 0.75rem; /* Reduced from 0.875rem */
            margin-top: 3px; /* Reduced from 5px */
            display: none;
        }
        
        .success-message {
            color: #198754;
            text-align: center;
            display: none;
            margin-bottom: 10px; /* Reduced from 15px */
            font-size: 0.85rem; /* Smaller font size */
        }
        
        .error-alert {
            color: #dc3545;
            text-align: center;
            margin-bottom: 10px; /* Reduced from 15px */
            padding: 8px; /* Reduced from 10px */
            border-radius: 5px;
            background-color: rgba(220, 53, 69, 0.1);
            border: 1px solid rgba(220, 53, 69, 0.2);
            font-size: 0.85rem; /* Smaller font size */
        }
        
        .floating-back {
            position: fixed;
            top: 15px;
            left: 15px;
            background-color: rgba(255, 255, 255, 0.8);
            border-radius: 50%;
            width: 40px; /* Reduced from 45px */
            height: 40px; /* Reduced from 45px */
            display: flex;
            justify-content: center;
            align-items: center;
            color: var(--dark-color);
            text-decoration: none;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, background-color 0.3s;
            z-index: 100;
        }
        
        .floating-back:hover {
            transform: translateY(-2px);
            background-color: white;
        }
        
        .form-check-input {
            width: 0.9em;
            height: 0.9em;
        }
        
        .form-check-label {
            font-size: 0.85rem; /* Smaller font size */
        }
        
        .forgot-link {
            font-size: 0.85rem; /* Smaller font size */
        }
        
        .d-flex.justify-content-between {
            margin-top: 8px !important; /* Reduced from mt-3 */
            margin-bottom: 12px !important; /* Reduced from mb-4 */
        }
        
        /* Animation classes */
        .slide-up {
            animation: slideUp 0.5s ease forwards;
        }
        
        @keyframes slideUp {
            0% {
                opacity: 0;
                transform: translateY(20px);
            }
            100% {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
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
        
        .shake {
            animation: shake 0.5s cubic-bezier(.36,.07,.19,.97) both;
        }
        
        @keyframes shake {
            10%, 90% { transform: translate3d(-1px, 0, 0); }
            20%, 80% { transform: translate3d(2px, 0, 0); }
            30%, 50%, 70% { transform: translate3d(-4px, 0, 0); }
            40%, 60% { transform: translate3d(4px, 0, 0); }
        }
        
        /* Responsive adjustments */
        @media (max-width: 576px) {
            .card-header {
                padding: 12px 10px;
            }
            
            .card-header .logo {
                font-size: 1.4rem;
            }
            
            .card-body {
                padding: 15px 12px;
            }
            
            .social-btn {
                width: 32px;
                height: 32px;
                font-size: 0.9rem;
            }
            
            .floating-back {
                width: 36px;
                height: 36px;
            }
        }
    </style>
</head>
<body>
    <a href="index.jsp" class="floating-back">
        <i class="fas fa-arrow-left"></i>
    </a>
    
    <div class="login-container">
        <div class="card slide-up">
            <div class="card-header">
                <div class="logo">
                    <i class="fas fa-car-side me-2"></i>CarTrader
                </div>
                <p>Welcome back! Please login</p>
            </div>
            <div class="card-body">
                <!-- Success message -->
                <div class="success-message fade-in" id="successMessage">
                    <i class="fas fa-check-circle me-2"></i>Login successful! Redirecting...
                </div>
                
                <!-- Error message from servlet -->
                <% if(request.getParameter("error") != null) { %>
                    <div class="error-alert fade-in">
                        <i class="fas fa-exclamation-circle me-2"></i>
                        <% if(request.getParameter("error").equals("invalid")) { %>
                            Invalid email or password. Please try again.
                        <% } else if(request.getParameter("error").equals("notfound")) { %>
                            Account not found. Please register first.
                        <% } else { %>
                            An error occurred. Please try again.
                        <% } %>
                    </div>
                <% } %>
                
                <!-- Login Form with action pointing to LoginServlet -->
                <form id="loginForm" action="LoginServlet" method="post">
                    <div class="form-floating mb-3">
                        <input type="text" class="form-control" id="usernameInput" name="username" placeholder="Username or Email" required>
                        <label for="usernameInput"><i class="fas fa-user me-2"></i>Username or Email</label>
                        <div class="error-message" id="usernameError">Please enter your username or email address.</div>
                    </div>
                    
                    <div class="form-floating">
                        <input type="password" class="form-control" id="passwordInput" name="password" placeholder="Password" required>
                        <label for="passwordInput"><i class="fas fa-lock me-2"></i>Password</label>
                        <div class="error-message" id="passwordError">Password must be at least 6 characters.</div>
                    </div>
                    
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="rememberMe" name="rememberMe">
                            <label class="form-check-label" for="rememberMe">
                                Remember me
                            </label>
                        </div>
                        <div>
                            <a href="#" class="forgot-link">Forgot password?</a>
                        </div>
                    </div>
                    
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="fas fa-sign-in-alt me-1"></i>Login
                    </button>
                </form>
                
                <div class="divider mt-3 mb-2">
                    <span>OR</span>
                </div>
                
                <div class="social-login">
                    <a href="#" class="social-btn facebook">
                        <i class="fab fa-facebook-f"></i>
                    </a>
                    <a href="#" class="social-btn google">
                        <i class="fab fa-google"></i>
                    </a>
                    <a href="#" class="social-btn twitter">
                        <i class="fab fa-twitter"></i>
                    </a>
                </div>
                
                <div class="forgot-password">
                    <a href="#">Forgot your password?</a>
                </div>
            </div>
            <div class="register-link">
                Don't have an account? <a href="register.jsp" id="registerLink">Register Now</a>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Custom JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const loginForm = document.getElementById('loginForm');
            const usernameInput = document.getElementById('usernameInput');
            const passwordInput = document.getElementById('passwordInput');
            const usernameError = document.getElementById('usernameError');
            const passwordError = document.getElementById('passwordError');
            const successMessage = document.getElementById('successMessage');
            const registerLink = document.getElementById('registerLink');
            
            // Add animation to form fields when focusing
            const formFields = document.querySelectorAll('.form-control');
            formFields.forEach(field => {
                field.addEventListener('focus', () => {
                    field.parentElement.classList.add('fade-in');
                });
            });
            
            // Username/Email validation with visual feedback
            usernameInput.addEventListener('blur', function() {
                if (usernameInput.value.trim() === '') {
                    usernameInput.classList.add('is-invalid');
                    usernameError.style.display = 'block';
                } else {
                    usernameInput.classList.remove('is-invalid');
                    usernameInput.classList.add('is-valid');
                    usernameError.style.display = 'none';
                }
            });
            
            // Password validation with visual feedback
            passwordInput.addEventListener('blur', function() {
                if (passwordInput.value.length < 6 && passwordInput.value !== '') {
                    passwordInput.classList.add('is-invalid');
                    passwordError.style.display = 'block';
                } else {
                    passwordInput.classList.remove('is-invalid');
                    if (passwordInput.value !== '') {
                        passwordInput.classList.add('is-valid');
                    }
                    passwordError.style.display = 'none';
                }
            });
            
            // Form submission client-side validation
            loginForm.addEventListener('submit', function(event) {
                let isValid = true;
                
                // Validate username/email
                if (usernameInput.value.trim() === '') {
                    usernameInput.classList.add('is-invalid');
                    usernameError.style.display = 'block';
                    isValid = false;
                }
                
                // Validate password
                if (passwordInput.value.length < 6) {
                    passwordInput.classList.add('is-invalid');
                    passwordError.style.display = 'block';
                    isValid = false;
                }
                
                if (!isValid) {
                    // Visual shake animation for invalid form
                    event.preventDefault(); // Prevent form submission
                    loginForm.classList.add('shake');
                    setTimeout(() => {
                        loginForm.classList.remove('shake');
                    }, 500);
                }
            });
            
            // Animation for register link
            registerLink.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-2px)';
                this.style.transition = 'transform 0.3s';
            });
            
            registerLink.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(0)';
            });
            
            // Focus animation for social buttons
            const socialBtns = document.querySelectorAll('.social-btn');
            socialBtns.forEach(btn => {
                btn.addEventListener('mouseenter', () => {
                    socialBtns.forEach(otherBtn => {
                        if (otherBtn !== btn) {
                            otherBtn.style.opacity = '0.5';
                            otherBtn.style.transition = 'opacity 0.3s';
                        }
                    });
                });
                
                btn.addEventListener('mouseleave', () => {
                    socialBtns.forEach(otherBtn => {
                        otherBtn.style.opacity = '1';
                    });
                });
            });
        });
    </script>
</body>
</html>