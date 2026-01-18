<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - CarTrader</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #3a86ff;
            --secondary-color: #ff006e;
            --dark-color: #212529;
            --success-color: #20c997;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            background-image: url('https://images.unsplash.com/photo-1502161254066-6c74afbf07aa?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1650&q=80');
            background-size: cover;
            background-position: center;
            min-height: 100vh;
            display: flex;
            align-items: center;
            padding: 40px 0;
        }
        
        .register-container {
            width: 100%;
            max-width: 550px;
            margin: 0 auto;
            padding: 0 15px;
        }
        
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            background-color: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(5px);
        }
        
        .card-header {
            background-color: var(--primary-color);
            color: white;
            text-align: center;
            padding: 25px 20px;
            border-bottom: none;
        }
        
        .card-header .logo {
            font-size: 1.8rem;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .card-header p {
            margin-bottom: 0;
            opacity: 0.9;
        }
        
        .card-body {
            padding: 30px;
        }
        
        .form-floating {
            margin-bottom: 20px;
        }
        
        .form-floating label {
            color: #6c757d;
        }
        
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.25rem rgba(58, 134, 255, 0.25);
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
            padding: 12px;
            font-weight: 600;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        }
        
        .login-link {
            text-align: center;
            padding: 20px;
            background-color: #f8f9fa;
            border-top: 1px solid #dee2e6;
        }
        
        .login-link a {
            color: var(--primary-color);
            font-weight: 600;
            text-decoration: none;
        }
        
        .login-link a:hover {
            text-decoration: underline;
        }
        
        .error-message {
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 5px;
            display: none;
        }
        
        .success-message {
            color: #198754;
            text-align: center;
            display: none;
            margin-bottom: 15px;
        }
        
        .floating-back {
            position: absolute;
            top: 20px;
            left: 20px;
            background-color: rgba(255, 255, 255, 0.8);
            border-radius: 50%;
            width: 45px;
            height: 45px;
            display: flex;
            justify-content: center;
            align-items: center;
            color: var(--dark-color);
            text-decoration: none;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, background-color 0.3s;
        }
        
        .floating-back:hover {
            transform: translateY(-3px);
            background-color: white;
        }
        
        .password-strength {
            height: 5px;
            border-radius: 5px;
            margin-top: 5px;
            transition: width 0.3s;
            background-color: #e9ecef;
            position: relative;
        }
        
        .password-strength-indicator {
            position: absolute;
            top: 0;
            left: 0;
            height: 100%;
            border-radius: 5px;
            transition: width 0.3s, background-color 0.3s;
        }
        
        .password-strength-text {
            font-size: 0.8rem;
            margin-top: 5px;
            text-align: right;
        }
        
        .terms-check {
            margin-top: 10px;
            margin-bottom: 20px;
        }
        
        .terms-check label {
            font-size: 0.9rem;
        }
        
        .terms-check a {
            color: var(--primary-color);
            text-decoration: none;
        }
        
        .terms-check a:hover {
            text-decoration: underline;
        }
        
        /* Custom checkbox */
        .custom-checkbox {
            position: relative;
            padding-left: 30px;
            cursor: pointer;
            user-select: none;
            display: inline-block;
        }
        
        .custom-checkbox input {
            position: absolute;
            opacity: 0;
            cursor: pointer;
            height: 0;
            width: 0;
        }
        
        .checkmark {
            position: absolute;
            top: 0;
            left: 0;
            height: 20px;
            width: 20px;
            background-color: #fff;
            border: 2px solid #dee2e6;
            border-radius: 4px;
            transition: all 0.2s;
        }
        
        .custom-checkbox:hover input ~ .checkmark {
            border-color: var(--primary-color);
        }
        
        .custom-checkbox input:checked ~ .checkmark {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .checkmark:after {
            content: "";
            position: absolute;
            display: none;
        }
        
        .custom-checkbox input:checked ~ .checkmark:after {
            display: block;
        }
        
        .custom-checkbox .checkmark:after {
            left: 6px;
            top: 2px;
            width: 5px;
            height: 10px;
            border: solid white;
            border-width: 0 2px 2px 0;
            transform: rotate(45deg);
        }
        
        /* Role selection styles */
        .role-selection {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .role-card {
            flex: 1;
            border: 2px solid #dee2e6;
            border-radius: 10px;
            padding: 15px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            position: relative;
        }
        
        .role-card:hover {
            border-color: var(--primary-color);
            transform: translateY(-5px);
        }
        
        .role-card.selected {
            border-color: var(--primary-color);
            background-color: rgba(58, 134, 255, 0.05);
        }
        
        .role-card i {
            font-size: 2rem;
            margin-bottom: 10px;
            color: #6c757d;
            transition: color 0.3s;
        }
        
        .role-card.selected i {
            color: var(--primary-color);
        }
        
        .role-card h5 {
            font-weight: 600;
            margin-bottom: 5px;
        }
        
        .role-card p {
            font-size: 0.9rem;
            color: #6c757d;
            margin-bottom: 0;
        }
        
        .role-check {
            position: absolute;
            top: 10px;
            right: 10px;
            color: var(--primary-color);
            display: none;
        }
        
        .role-card.selected .role-check {
            display: block;
            animation: scaleIn 0.3s ease;
        }
        
        @keyframes scaleIn {
            from {
                transform: scale(0);
            }
            to {
                transform: scale(1);
            }
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
        
        /* Date input and timestamp */
        .timestamp {
            font-size: 0.8rem;
            color: #6c757d;
            text-align: center;
            margin-top: 10px;
            font-style: italic;
        }
    </style>
</head>
<body>
    <a href="index.jsp" class="floating-back">
        <i class="fas fa-arrow-left"></i>
    </a>
    
    <div class="register-container">
        <div class="card slide-up">
            <div class="card-header">
                <div class="logo">
                    <i class="fas fa-car-side me-2"></i>CarTrader
                </div>
                <p>Create your account to buy or sell cars</p>
            </div>
            <div class="card-body">
                <div class="success-message fade-in" id="successMessage">
                    <i class="fas fa-check-circle me-2"></i>Registration successful! Redirecting to login...
                </div>
                
                <!-- IMPORTANT: Fixed form with correct action and method -->
                <form id="registrationForm" action="RegisterServlet" method="post">
                    <!-- Step 1: Basic Info -->
                    <div id="step1Content">
                        <div class="form-floating mb-3">
                            <input type="text" class="form-control" id="fullNameInput" name="fullName" placeholder="Full Name" required>
                            <label for="fullNameInput"><i class="fas fa-user me-2"></i>Full Name</label>
                            <div class="error-message" id="nameError">Please enter your full name.</div>
                        </div>
                        
                        <div class="form-floating mb-3">
                            <input type="email" class="form-control" id="emailInput" name="email" placeholder="name@example.com" required>
                            <label for="emailInput"><i class="fas fa-envelope me-2"></i>Email address</label>
                            <div class="error-message" id="emailError">Please enter a valid email address.</div>
                        </div>
                        
                        <div class="form-floating">
                            <input type="tel" class="form-control" id="phoneInput" name="phone" placeholder="Phone Number" required>
                            <label for="phoneInput"><i class="fas fa-phone me-2"></i>Phone Number</label>
                            <div class="error-message" id="phoneError">Please enter a valid phone number.</div>
                        </div>
                        
                        <div class="d-flex justify-content-between mt-4">
                            <div></div>
                            <button type="button" class="btn btn-primary" id="nextToStep2">
                                Next <i class="fas fa-arrow-right ms-2"></i>
                            </button>
                        </div>
                    </div>
                    
                    <!-- Step 2: Security -->
                    <div id="step2Content" style="display: none;">
                        <div class="form-floating mb-3">
                            <input type="text" class="form-control" id="usernameInput" name="username" placeholder="Username" required>
                            <label for="usernameInput"><i class="fas fa-user-tag me-2"></i>Username</label>
                            <div class="error-message" id="usernameError">Username must be at least 4 characters and contain only letters, numbers, and underscores.</div>
                        </div>
                        
                        <div class="form-floating mb-1">
                            <input type="password" class="form-control" id="passwordInput" name="password" placeholder="Password" required>
                            <label for="passwordInput"><i class="fas fa-lock me-2"></i>Password</label>
                        </div>
                        
                        <div class="password-strength">
                            <div class="password-strength-indicator" id="passwordStrengthBar"></div>
                        </div>
                        <div class="password-strength-text" id="passwordStrengthText">Password strength</div>
                        <div class="error-message" id="passwordError">Password must be at least 8 characters with letters, numbers and special characters.</div>
                        
                        <div class="form-floating mt-3">
                            <input type="password" class="form-control" id="confirmPasswordInput" placeholder="Confirm Password" required>
                            <label for="confirmPasswordInput"><i class="fas fa-lock me-2"></i>Confirm Password</label>
                            <div class="error-message" id="confirmPasswordError">Passwords do not match.</div>
                        </div>
                        
                        <div class="d-flex justify-content-between mt-4">
                            <button type="button" class="btn btn-outline-secondary" id="backToStep1">
                                <i class="fas fa-arrow-left me-2"></i> Back
                            </button>
                            <button type="button" class="btn btn-primary" id="nextToStep3">
                                Next <i class="fas fa-arrow-right ms-2"></i>
                            </button>
                        </div>
                    </div>
                    
                    <!-- Step 3: Account Type and Preferences -->
                    <div id="step3Content" style="display: none;">
                        <h5 class="mb-3">Account Type</h5>
                        <div class="role-selection mb-4">
                            <div class="role-card" id="buyerRole">
                                <i class="fas fa-shopping-cart"></i>
                                <h5>Buyer</h5>
                                <p>I want to purchase a vehicle</p>
                                <div class="role-check"><i class="fas fa-check-circle"></i></div>
                                <!-- Fixed radio button with proper name -->
                                <input type="radio" name="userRole" id="buyingRadio" value="buyer" style="display:none;">
                            </div>
                            <div class="role-card" id="sellerRole">
                                <i class="fas fa-tag"></i>
                                <h5>Seller</h5>
                                <p>I want to sell my vehicle</p>
                                <div class="role-check"><i class="fas fa-check-circle"></i></div>
                                <!-- Fixed radio button with proper name -->
                                <input type="radio" name="userRole" id="sellingRadio" value="seller" style="display:none;">
                            </div>
                        </div>
                        <div class="error-message" id="roleError">Please select a role (Buyer or Seller).</div>
                        
                        <div class="mb-4">
                            <label class="form-label">Preferred contact method:</label>
                            <div class="d-flex gap-3 mt-2">
                                <div class="form-check">
                                    <!-- Fixed radio buttons with proper name and value -->
                                    <input class="form-check-input" type="radio" name="contactMethod" id="emailRadio" value="email" checked>
                                    <label class="form-check-label" for="emailRadio">Email</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="contactMethod" id="phoneRadio" value="phone">
                                    <label class="form-check-label" for="phoneRadio">Phone</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="contactMethod" id="bothRadio" value="both">
                                    <label class="form-check-label" for="bothRadio">Both</label>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Subscribe to newsletter:</label>
                            <div class="form-check form-switch">
                                <!-- Fixed checkbox with proper name and value -->
                                <input class="form-check-input" type="checkbox" name="newsletter" id="newsletterSwitch" value="Yes">
                                <label class="form-check-label" for="newsletterSwitch">Yes, send me updates about new cars and special offers</label>
                            </div>
                        </div>
                        
                        <div class="terms-check mb-4">
                            <label class="custom-checkbox">
                                <input type="checkbox" id="termsCheck" required>
                                <span class="checkmark"></span>
                                I agree to the <a href="#" data-bs-toggle="modal" data-bs-target="#termsModal">Terms and Conditions</a> and <a href="#" data-bs-toggle="modal" data-bs-target="#privacyModal">Privacy Policy</a>
                            </label>
                            <div class="error-message" id="termsError">You must agree to the terms and conditions.</div>
                        </div>
                        
                        <div class="d-flex justify-content-between">
                            <button type="button" class="btn btn-outline-secondary" id="backToStep2">
                                <i class="fas fa-arrow-left me-2"></i> Back
                            </button>
                            <button type="submit" class="btn btn-primary" id="submitBtn">
                                <i class="fas fa-user-plus me-2"></i> Create Account
                            </button>
                        </div>
                        
                        <div class="timestamp">
                            Registration Date: 2025-04-05 13:59:22 (UTC) | User: IT24102083
                        </div>
                    </div>
                </form>
            </div>
            <div class="login-link">
                Already have an account? <a href="login.jsp" id="loginLink">Login</a>
            </div>
        </div>
    </div>
    
    <!-- Terms and Conditions Modal -->
    <div class="modal fade" id="termsModal" tabindex="-1" aria-labelledby="termsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="termsModalLabel">Terms and Conditions</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <h6>1. Acceptance of Terms</h6>
                    <p>By accessing or using the CarTrader platform ("Platform"), you agree to be bound by these Terms and Conditions ("Terms"). If you do not agree to these Terms, please do not use the Platform.</p>
                    
                    <h6>2. User Accounts</h6>
                    <p>When you create an account on our Platform, you must provide accurate and complete information. You are responsible for safeguarding your account and for all activities that occur under your account.</p>
                    
                    <h6>3. Listing and Purchasing</h6>
                    <p>CarTrader is a platform that allows users to list, browse, and purchase second-hand vehicles. We do not own the vehicles listed on our Platform and are not a party to transactions between buyers and sellers.</p>
                    
                    <h6>4. User Content</h6>
                    <p>You retain ownership of the content you post on the Platform. However, by posting content, you grant us a non-exclusive, worldwide, royalty-free license to use, display, and distribute your content in connection with the Platform.</p>
                    
                    <h6>5. Prohibited Activities</h6>
                    <p>You agree not to engage in any of the following activities: (a) violating laws or regulations; (b) infringing the rights of others; (c) posting false or misleading information; (d) attempting to gain unauthorized access to the Platform or user accounts.</p>
                    
                    <h6>6. Disclaimer of Warranties</h6>
                    <p>The Platform is provided "as is" without warranties of any kind, either express or implied.</p>
                    
                    <h6>7. Limitation of Liability</h6>
                    <p>To the maximum extent permitted by law, CarTrader shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or relating to your use of the Platform.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Privacy Policy Modal -->
    <div class="modal fade" id="privacyModal" tabindex="-1" aria-labelledby="privacyModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="privacyModalLabel">Privacy Policy</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <h6>1. Information We Collect</h6>
                    <p>We collect personal information that you provide to us, such as your name, email address, phone number, and information about the vehicles you wish to buy or sell.</p>
                    
                    <h6>2. How We Use Your Information</h6>
                    <p>We use your information to provide and improve our services, to communicate with you, to process transactions, and for security and fraud prevention.</p>
                    
                    <h6>3. Information Sharing</h6>
                    <p>We may share your information with other users as necessary to facilitate transactions, with service providers who perform services on our behalf, and as required by law.</p>
                    
                    <h6>4. Your Choices</h6>
                    <p>You can access, update, or delete your personal information by logging into your account. You can also opt out of receiving marketing communications from us.</p>
                    
                    <h6>5. Security</h6>
                    <p>We implement reasonable measures to protect your personal information from unauthorized access and disclosure.</p>
                    
                    <h6>6. Changes to This Policy</h6>
                    <p>We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new Privacy Policy on this page.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Custom JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Form elements
            const registrationForm = document.getElementById('registrationForm');
            const fullNameInput = document.getElementById('fullNameInput');
            const emailInput = document.getElementById('emailInput');
            const phoneInput = document.getElementById('phoneInput');
            const usernameInput = document.getElementById('usernameInput');
            const passwordInput = document.getElementById('passwordInput');
            const confirmPasswordInput = document.getElementById('confirmPasswordInput');
            const termsCheck = document.getElementById('termsCheck');
            const buyingRadio = document.getElementById('buyingRadio');
            const sellingRadio = document.getElementById('sellingRadio');
            
            // Error messages
            const nameError = document.getElementById('nameError');
            const emailError = document.getElementById('emailError');
            const phoneError = document.getElementById('phoneError');
            const usernameError = document.getElementById('usernameError');
            const passwordError = document.getElementById('passwordError');
            const confirmPasswordError = document.getElementById('confirmPasswordError');
            const termsError = document.getElementById('termsError');
            const roleError = document.getElementById('roleError');
            
            // Step navigation buttons
            const nextToStep2Button = document.getElementById('nextToStep2');
            const nextToStep3Button = document.getElementById('nextToStep3');
            const backToStep1Button = document.getElementById('backToStep1');
            const backToStep2Button = document.getElementById('backToStep2');
            
            // Step content containers
            const step1Content = document.getElementById('step1Content');
            const step2Content = document.getElementById('step2Content');
            const step3Content = document.getElementById('step3Content');
            
            // Success message
            const successMessage = document.getElementById('successMessage');
            
            // Role selection cards
            const buyerRole = document.getElementById('buyerRole');
            const sellerRole = document.getElementById('sellerRole');
            
            // Role selection handling (mutually exclusive)
            buyerRole.addEventListener('click', function() {
                buyerRole.classList.add('selected');
                sellerRole.classList.remove('selected');
                buyingRadio.checked = true;
                sellingRadio.checked = false;
                roleError.style.display = 'none';
            });
            
            sellerRole.addEventListener('click', function() {
                sellerRole.classList.add('selected');
                buyerRole.classList.remove('selected');
                sellingRadio.checked = true;
                buyingRadio.checked = false;
                roleError.style.display = 'none';
            });
            
            // Step navigation
            nextToStep2Button.addEventListener('click', function() {
                if (validateStep1()) {
                    step1Content.style.display = 'none';
                    step2Content.style.display = 'block';
                } else {
                    step1Content.classList.add('shake');
                    setTimeout(() => {
                        step1Content.classList.remove('shake');
                    }, 500);
                }
            });
            
            backToStep1Button.addEventListener('click', function() {
                step2Content.style.display = 'none';
                step1Content.style.display = 'block';
            });
            
            nextToStep3Button.addEventListener('click', function() {
                if (validateStep2()) {
                    step2Content.style.display = 'none';
                    step3Content.style.display = 'block';
                } else {
                    step2Content.classList.add('shake');
                    setTimeout(() => {
                        step2Content.classList.remove('shake');
                    }, 500);
                }
            });
            
            backToStep2Button.addEventListener('click', function() {
                step3Content.style.display = 'none';
                step2Content.style.display = 'block';
            });
            
            // Validation for Step 1
            function validateStep1() {
                let isValid = true;
                
                // Validate full name
                if (fullNameInput.value.trim() === '') {
                    fullNameInput.classList.add('is-invalid');
                    nameError.style.display = 'block';
                    isValid = false;
                } else {
                    fullNameInput.classList.remove('is-invalid');
                    fullNameInput.classList.add('is-valid');
                    nameError.style.display = 'none';
                }
                
                // Validate email
                const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailPattern.test(emailInput.value)) {
                    emailInput.classList.add('is-invalid');
                    emailError.style.display = 'block';
                    isValid = false;
                } else {
                    emailInput.classList.remove('is-invalid');
                    emailInput.classList.add('is-valid');
                    emailError.style.display = 'none';
                }
                
                // Validate phone number
                const phonePattern = /^[0-9]{10,15}$/;
                if (!phonePattern.test(phoneInput.value.replace(/\D/g, ''))) {
                    phoneInput.classList.add('is-invalid');
                    phoneError.style.display = 'block';
                    isValid = false;
                } else {
                    phoneInput.classList.remove('is-invalid');
                    phoneInput.classList.add('is-valid');
                    phoneError.style.display = 'none';
                }
                
                return isValid;
            }
            
            // Validation for Step 2
            function validateStep2() {
                let isValid = true;
                
                // Validate username
                const usernamePattern = /^[a-zA-Z0-9_]{4,}$/;
                if (!usernamePattern.test(usernameInput.value)) {
                    usernameInput.classList.add('is-invalid');
                    usernameError.style.display = 'block';
                    isValid = false;
                } else {
                    usernameInput.classList.remove('is-invalid');
                    usernameInput.classList.add('is-valid');
                    usernameError.style.display = 'none';
                }
                
                // Validate password
                if (passwordStrength < 2) {
                    passwordInput.classList.add('is-invalid');
                    passwordError.style.display = 'block';
                    isValid = false;
                } else {
                    passwordInput.classList.remove('is-invalid');
                    passwordInput.classList.add('is-valid');
                    passwordError.style.display = 'none';
                }
                
                // Validate confirm password
                if (confirmPasswordInput.value !== passwordInput.value) {
                    confirmPasswordInput.classList.add('is-invalid');
                    confirmPasswordError.style.display = 'block';
                    isValid = false;
                } else {
                    confirmPasswordInput.classList.remove('is-invalid');
                    confirmPasswordInput.classList.add('is-valid');
                    confirmPasswordError.style.display = 'none';
                }
                
                return isValid;
            }
            
            // Validation for Step 3 (Role selection)
            function validateStep3() {
                let isValid = true;
                
                // Validate role selection (buyer/seller)
                if (!buyingRadio.checked && !sellingRadio.checked) {
                    roleError.style.display = 'block';
                    isValid = false;
                } else {
                    roleError.style.display = 'none';
                }
                
                // Validate terms acceptance
                if (!termsCheck.checked) {
                    termsError.style.display = 'block';
                    isValid = false;
                } else {
                    termsError.style.display = 'none';
                }
                
                return isValid;
            }
            
            // Password strength meter
            let passwordStrength = 0;
            const passwordStrengthBar = document.getElementById('passwordStrengthBar');
            const passwordStrengthText = document.getElementById('passwordStrengthText');
            
            passwordInput.addEventListener('input', function() {
                const password = passwordInput.value;
                
                // Calculate strength
                passwordStrength = 0;
                
                // Length check
                if (password.length >= 8) {
                    passwordStrength += 1;
                }
                
                // Contains lowercase and uppercase
                if (/[a-z]/.test(password) && /[A-Z]/.test(password)) {
                    passwordStrength += 1;
                }
                
                // Contains numbers
                if (/[0-9]/.test(password)) {
                    passwordStrength += 1;
                }
                
                // Contains special characters
                if (/[^a-zA-Z0-9]/.test(password)) {
                    passwordStrength += 1;
                }
                
                // Update strength indicator
                let strengthWidth = '0%';
                let strengthColor = '#e9ecef';
                let strengthText = 'Password strength';
                
                switch (passwordStrength) {
                    case 0:
                        strengthWidth = '0%';
                        strengthColor = '#e9ecef';
                        strengthText = 'Password strength';
                        break;
                    case 1:
                        strengthWidth = '25%';
                        strengthColor = '#dc3545'; // Danger - red
                        strengthText = 'Weak';
                        break;
                    case 2:
                        strengthWidth = '50%';
                        strengthColor = '#ffc107'; // Warning - yellow
                        strengthText = 'Fair';
                        break;
                    case 3:
                        strengthWidth = '75%';
                        strengthColor = '#0dcaf0'; // Info - blue
                        strengthText = 'Good';
                        break;
                    case 4:
                        strengthWidth = '100%';
                        strengthColor = '#20c997'; // Success - green
                        strengthText = 'Strong';
                        break;
                }
                
                passwordStrengthBar.style.width = strengthWidth;
                passwordStrengthBar.style.backgroundColor = strengthColor;
                passwordStrengthText.textContent = strengthText;
                passwordStrengthText.style.color = strengthColor;
            });
            
            // Form submission - MODIFIED TO ACTUALLY SUBMIT TO REGISTERSERVLET
            registrationForm.addEventListener('submit', function(event) {
                // Validate final step
                if (!validateStep3()) {
                    event.preventDefault(); // Prevent form submission if validation fails
                    step3Content.classList.add('shake');
                    setTimeout(() => {
                        step3Content.classList.remove('shake');
                    }, 500);
                    return;
                }
                
                // Show success message but still allow form to submit
                successMessage.style.display = 'block';
                
                // Form submits to RegisterServlet naturally since action and method are set
            });
            
            // Input field animation and real-time validation
            fullNameInput.addEventListener('blur', function() {
                if (fullNameInput.value.trim() !== '') {
                    fullNameInput.classList.add('is-valid');
                }
            });
            
            emailInput.addEventListener('blur', function() {
                const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (emailPattern.test(emailInput.value)) {
                    emailInput.classList.add('is-valid');
                    emailError.style.display = 'none';
                } else if (emailInput.value !== '') {
                    emailInput.classList.add('is-invalid');
                    emailError.style.display = 'block';
                }
            });
            
            phoneInput.addEventListener('blur', function() {
                const phonePattern = /^[0-9]{10,15}$/;
                if (phonePattern.test(phoneInput.value.replace(/\D/g, ''))) {
                    phoneInput.classList.add('is-valid');
                    phoneError.style.display = 'none';
                } else if (phoneInput.value !== '') {
                    phoneInput.classList.add('is-invalid');
                    phoneError.style.display = 'block';
                }
            });
            
            usernameInput.addEventListener('blur', function() {
                const usernamePattern = /^[a-zA-Z0-9_]{4,}$/;
                if (usernamePattern.test(usernameInput.value)) {
                    usernameInput.classList.add('is-valid');
                    usernameError.style.display = 'none';
                } else if (usernameInput.value !== '') {
                    usernameInput.classList.add('is-invalid');
                    usernameError.style.display = 'block';
                }
            });
            
            confirmPasswordInput.addEventListener('blur', function() {
                if (confirmPasswordInput.value === passwordInput.value && confirmPasswordInput.value !== '') {
                    confirmPasswordInput.classList.add('is-valid');
                    confirmPasswordError.style.display = 'none';
                } else if (confirmPasswordInput.value !== '') {
                    confirmPasswordInput.classList.add('is-invalid');
                    confirmPasswordError.style.display = 'block';
                }
            });
            
            // Phone number formatting
            phoneInput.addEventListener('input', function(e) {
                let x = e.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
                e.target.value = !x[2] ? x[1] : '(' + x[1] + ') ' + x[2] + (x[3] ? '-' + x[3] : '');
            });
            
            // Animation for login link
            const loginLink = document.getElementById('loginLink');
            loginLink.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-3px)';
                this.style.transition = 'transform 0.3s';
            });
            
            loginLink.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(0)';
            });
            
            // Calculate the height for role cards to be equal
            function setRoleCardHeight() {
                const roleCards = document.querySelectorAll('.role-card');
                let maxHeight = 0;
                
                // Reset heights
                roleCards.forEach(card => {
                    card.style.height = 'auto';
                    const height = card.offsetHeight;
                    maxHeight = height > maxHeight ? height : maxHeight;
                });
                
                // Set all cards to max height
                roleCards.forEach(card => {
                    card.style.height = `${maxHeight}px`;
                });
            }
            
            // Select buyer by default
            buyerRole.click();
            
            // Run once DOM is fully loaded
            setTimeout(setRoleCardHeight, 100);
            
            // Run on window resize
            window.addEventListener('resize', setRoleCardHeight);
        });
    </script>
</body>
</html>