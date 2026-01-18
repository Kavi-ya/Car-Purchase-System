<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CarTrader - Buy & Sell Used Cars</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- AOS library for scroll animations -->
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #3a86ff;
            --secondary-color: #ff006e;
            --dark-color: #212529;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow-x: hidden;
        }
        
        /* Updated navbar styles */
        .navbar {
            transition: all 0.4s;
            padding: 15px 0;
        }
        
        .navbar-scrolled {
            background-color: rgba(33, 37, 41, 0.95) !important;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.15);
            padding: 10px 0;
        }
        
        .navbar-brand {
            font-weight: 700;
            font-size: 1.5rem;
        }
        
        .navbar-brand i {
            color: var(--primary-color);
        }
        
        .navbar-nav .nav-link {
            font-weight: 600;
            color: rgba(255, 255, 255, 0.9);
            margin: 0 3px;
            position: relative;
            transition: all 0.3s ease;
        }
        
        .navbar-nav .nav-link:after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            background: var(--primary-color);
            left: 50%;
            bottom: 0;
            transform: translateX(-50%);
            transition: width 0.3s;
        }
        
        .navbar-nav .nav-link:hover:after,
        .navbar-nav .nav-link.active:after {
            width: 80%;
        }
        
        .navbar-nav .nav-link:hover,
        .navbar-nav .nav-link.active {
            color: #ffffff;
        }
        
        .dropdown-menu {
            border: none;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            padding: 10px;
            margin-top: 10px;
        }
        
        .dropdown-item {
            padding: 8px 15px;
            border-radius: 5px;
            transition: all 0.2s;
        }
        
        .dropdown-item:hover {
            background-color: rgba(58, 134, 255, 0.1);
        }
        
        .auth-buttons {
            display: flex;
            gap: 10px;
            margin-left: 15px;
        }
        
        .auth-buttons .btn {
            border-radius: 50px;
            padding: 8px 20px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .btn-register {
            background-color: transparent;
            border: 1px solid white;
            color: white;
        }
        
        .btn-register:hover {
            background-color: white;
            color: var(--dark-color);
            transform: translateY(-3px);
        }
        
        .hero-section {
            background: linear-gradient(rgba(0, 0, 0, 0.7), rgba(0, 0, 0, 0.7)), 
                       url('https://images.unsplash.com/photo-1603386329225-868f9b1ee6c9?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D');
            background-size: cover;
            background-position: center;
            height: 100vh;
            display: flex;
            align-items: center;
            color: white;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        }
        
        .car-card {
            transition: transform 0.4s, box-shadow 0.4s;
            border-radius: 10px;
            overflow: hidden;
        }
        
        .car-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.15);
        }
        
        .car-img-container {
            height: 200px;
            overflow: hidden;
        }
        
        .car-img-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.6s;
        }
        
        .car-card:hover .car-img-container img {
            transform: scale(1.1);
        }
        
        .price-tag {
            background-color: var(--secondary-color);
            color: white;
            font-weight: bold;
            position: absolute;
            top: 15px;
            right: 15px;
            padding: 5px 15px;
            border-radius: 30px;
            z-index: 1;
        }
        
        .search-form {
            background-color: rgba(255, 255, 255, 0.9);
            border-radius: 15px;
            padding: 30px;
            margin-top: 2rem;
            box-shadow: 0 5px 25px rgba(0, 0, 0, 0.2);
        }
        
        .stats-counter {
            background-color: var(--dark-color);
            padding: 60px 0;
            color: white;
        }
        
        .counter-number {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
            color: var(--primary-color);
        }
        
        .footer {
            background-color: var(--dark-color);
            color: #f8f9fa;
            padding: 60px 0 20px;
        }
        
        .footer-links a {
            color: #adb5bd;
            text-decoration: none;
            transition: color 0.3s;
        }
        
        .footer-links a:hover {
            color: var(--primary-color);
        }
        
        .social-icons i {
            font-size: 1.5rem;
            margin-right: 15px;
            transition: transform 0.3s;
        }
        
        .social-icons i:hover {
            transform: scale(1.2);
        }
        
        .carousel-caption {
            background-color: rgba(0, 0, 0, 0.7);
            border-radius: 10px;
            padding: 20px;
        }
    </style>
</head>
<body>
    <!-- Updated Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-transparent fixed-top">
        <div class="container">
            <a class="navbar-brand d-flex align-items-center" href="index.jsp">
                <i class="fas fa-car-side me-2"></i>
                <span>CarTrader</span>
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" 
                    aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav mx-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="index.jsp"><i class="fas fa-home me-1"></i> Home</a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="findCarsDropdown" role="button" 
                           data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-search me-1"></i> Find Cars
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="findCarsDropdown">
                            <li><a class="dropdown-item" href="browse-cars.jsp">Browse All</a></li>
                            <li><a class="dropdown-item" href="#">SUVs & Crossovers</a></li>
                            <li><a class="dropdown-item" href="#">Sedans & Coupes</a></li>
                            <li><a class="dropdown-item" href="#">Trucks & Vans</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#">Advanced Search</a></li>
                        </ul>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#"><i class="fas fa-tag me-1"></i> Sell Car</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#"><i class="fas fa-info-circle me-1"></i> About</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#"><i class="fas fa-phone-alt me-1"></i> Contact</a>
                    </li>
                </ul>
                <div class="auth-buttons">
                    <a class="btn btn-register" href="register.jsp"><i class="fas fa-user-plus me-1"></i> Register</a>
                    <a class="btn btn-primary" href="login.jsp"><i class="fas fa-sign-in-alt me-1"></i> Login</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="container">
            <div class="row">
                <div class="col-lg-7" data-aos="fade-right" data-aos-duration="1000">
                    <h1 class="display-4 fw-bold mb-3">Find Your Perfect Used Car</h1>
                    <p class="lead mb-4">Discover thousands of quality pre-owned vehicles from trusted sellers. Buy or sell with confidence on CarTrader.</p>
                    <div class="d-flex gap-3">
                        <a href="register.jsp" class="btn btn-primary btn-lg">
                            <i class="fas fa-search me-2"></i> Browse Cars
                        </a>
                        <a href="register.jsp" class="btn btn-outline-light btn-lg">
                            <i class="fas fa-tag me-2"></i> Sell Your Car
                        </a>
                    </div>
                </div>
                <div class="col-lg-5">
                    <div class="search-form" data-aos="fade-left" data-aos-duration="1000">
                        <h4 class="text-center mb-4">Quick Search</h4>
                        <form>
                            <div class="mb-3">
                                <select class="form-select">
                                    <option selected>Select Make</option>
                                    <option>Toyota</option>
                                    <option>Honda</option>
                                    <option>Ford</option>
                                    <option>BMW</option>
                                    <option>Mercedes</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <select class="form-select">
                                    <option selected>Select Model</option>
                                    <option>Any Model</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <select class="form-select">
                                    <option selected>Price Range</option>
                                    <option>Under LKR 50,000,000</option>
                                    <option>LKR 50,000,000 - LKR 10,000,000</option>
                                    <option>LKR 10,000,000 - LKR 20,000,000</option>
                                    <option>LKR 20,000,000 - LKR 30,000,000</option>
                                    <option>LKR 80,000,000+</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="fas fa-search me-2"></i> Search Cars
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Featured Cars Section -->
    <section class="py-5">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="fw-bold" data-aos="fade-up">Featured Cars</h2>
                <p class="text-muted" data-aos="fade-up" data-aos-delay="100">Handpicked quality vehicles for you to explore</p>
            </div>
            
            <div class="row g-4">
                <!-- Car Card 1 -->
                <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="100">
                    <div class="card car-card">
                        <div class="price-tag">$15,999</div>
                        <div class="car-img-container">
                            <img src="https://images.unsplash.com/photo-1580273916550-e323be2ae537?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=760&q=80" alt="Toyota Camry">
                        </div>
                        <div class="card-body">
                            <h5 class="card-title">2019 Toyota Camry SE</h5>
                            <div class="d-flex justify-content-between mb-3">
                                <span><i class="fas fa-tachometer-alt text-secondary me-2"></i>45,000 mi</span>
                                <span><i class="fas fa-gas-pump text-secondary me-2"></i>Hybrid</span>
                                <span><i class="fas fa-cog text-secondary me-2"></i>Automatic</span>
                            </div>
                            <p class="card-text text-muted">Well-maintained with full service history. Includes premium sound system and backup camera.</p>
                            <a href="#" class="btn btn-primary w-100">View Details</a>
                        </div>
                    </div>
                </div>
                
                <!-- Car Card 2 -->
                <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="200">
                    <div class="card car-card">
                        <div class="price-tag">$28,500</div>
                        <div class="car-img-container">
                            <img src="https://plus.unsplash.com/premium_photo-1664303847960-586318f59035?q=80&w=1548&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Honda CR-V">
                        </div>
                        <div class="card-body">
                            <h5 class="card-title">2020 Honda CR-V Touring</h5>
                            <div class="d-flex justify-content-between mb-3">
                                <span><i class="fas fa-tachometer-alt text-secondary me-2"></i>30,200 mi</span>
                                <span><i class="fas fa-gas-pump text-secondary me-2"></i>Gasoline</span>
                                <span><i class="fas fa-cog text-secondary me-2"></i>Automatic</span>
                            </div>
                            <p class="card-text text-muted">Single owner, accident-free with leather interior and all-wheel drive.</p>
                            <a href="#" class="btn btn-primary w-100">View Details</a>
                        </div>
                    </div>
                </div>
                
                <!-- Car Card 3 -->
                <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="300">
                    <div class="card car-card">
                        <div class="price-tag">$22,750</div>
                        <div class="car-img-container">
                            <img src="https://images.unsplash.com/photo-1552519507-da3b142c6e3d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=760&q=80" alt="Ford Mustang">
                        </div>
                        <div class="card-body">
                            <h5 class="card-title">2018 Ford Mustang GT</h5>
                            <div class="d-flex justify-content-between mb-3">
                                <span><i class="fas fa-tachometer-alt text-secondary me-2"></i>38,500 mi</span>
                                <span><i class="fas fa-gas-pump text-secondary me-2"></i>Gasoline</span>
                                <span><i class="fas fa-cog text-secondary me-2"></i>Manual</span>
                            </div>
                            <p class="card-text text-muted">5.0L V8, great condition, premium sports package with upgraded exhaust system.</p>
                            <a href="#" class="btn btn-primary w-100">View Details</a>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="text-center mt-5">
                <a href="#" class="btn btn-outline-dark btn-lg" data-aos="fade-up">
                    View All Cars <i class="fas fa-arrow-right ms-2"></i>
                </a>
            </div>
        </div>
    </section>

    <!-- Stats Counter Section -->
    <section class="stats-counter">
        <div class="container">
            <div class="row text-center">
                <div class="col-lg-3 col-md-6 mb-4 mb-lg-0" data-aos="fade-up">
                    <div class="counter-number" id="carsCounter">0</div>
                    <div>Cars Available</div>
                </div>
                <div class="col-lg-3 col-md-6 mb-4 mb-lg-0" data-aos="fade-up" data-aos-delay="100">
                    <div class="counter-number" id="customersCounter">0</div>
                    <div>Happy Customers</div>
                </div>
                <div class="col-lg-3 col-md-6 mb-4 mb-md-0" data-aos="fade-up" data-aos-delay="200">
                    <div class="counter-number" id="dealersCounter">0</div>
                    <div>Trusted Dealers</div>
                </div>
                <div class="col-lg-3 col-md-6" data-aos="fade-up" data-aos-delay="300">
                    <div class="counter-number" id="salesCounter">0</div>
                    <div>Cars Sold</div>
                </div>
            </div>
        </div>
    </section>

    <!-- How It Works -->
    <section class="py-5 bg-light">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="fw-bold" data-aos="fade-up">How It Works</h2>
                <p class="text-muted" data-aos="fade-up" data-aos-delay="100">Simple steps to find your dream car or sell your vehicle</p>
            </div>
            
            <div class="row g-4">
                <div class="col-md-4" data-aos="fade-up" data-aos-delay="100">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center mx-auto mb-4" style="width: 80px; height: 80px;">
                                <i class="fas fa-search fa-2x"></i>
                            </div>
                            <h4>Search Cars</h4>
                            <p class="text-muted">Browse our extensive inventory of verified pre-owned vehicles with detailed information and photos.</p>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-4" data-aos="fade-up" data-aos-delay="200">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center mx-auto mb-4" style="width: 80px; height: 80px;">
                                <i class="fas fa-car fa-2x"></i>
                            </div>
                            <h4>Book Test Drive</h4>
                            <p class="text-muted">Schedule a test drive with the seller at your convenient time and location.</p>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-4" data-aos="fade-up" data-aos-delay="300">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center mx-auto mb-4" style="width: 80px; height: 80px;">
                                <i class="fas fa-handshake fa-2x"></i>
                            </div>
                            <h4>Make a Deal</h4>
                            <p class="text-muted">Negotiate securely and complete the purchase with our guided process and documentation support.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="row">
                <div class="col-lg-4 mb-4 mb-lg-0">
                    <h5 class="text-white mb-4"><i class="fas fa-car-side me-2"></i> CarTrader</h5>
                    <p class="mb-4">Your trusted platform for buying and selling quality used cars. We connect car buyers and sellers nationwide.</p>
                    <div class="social-icons">
                        <a href="#"><i class="fab fa-facebook text-light"></i></a>
                        <a href="#"><i class="fab fa-twitter text-light"></i></a>
                        <a href="#"><i class="fab fa-instagram text-light"></i></a>
                        <a href="#"><i class="fab fa-linkedin text-light"></i></a>
                    </div>
                </div>
                <div class="col-lg-2 col-md-4 col-6 mb-4 mb-md-0">
                    <h5 class="text-white mb-4">Quick Links</h5>
                    <ul class="list-unstyled footer-links">
                        <li class="mb-2"><a href="#">Home</a></li>
                        <li class="mb-2"><a href="#">Find Cars</a></li>
                        <li class="mb-2"><a href="#">Sell Car</a></li>
                        <li class="mb-2"><a href="#">About Us</a></li>
                        <li class="mb-2"><a href="#">Contact</a></li>
                    </ul>
                </div>
                <div class="col-lg-2 col-md-4 col-6 mb-4 mb-md-0">
                    <h5 class="text-white mb-4">Services</h5>
                    <ul class="list-unstyled footer-links">
                        <li class="mb-2"><a href="#">Car Valuation</a></li>
                        <li class="mb-2"><a href="#">Car Insurance</a></li>
                        <li class="mb-2"><a href="#">Car Loans</a></li>
                        <li class="mb-2"><a href="#">Vehicle Inspection</a></li>
                        <li class="mb-2"><a href="#">Help Center</a></li>
                    </ul>
                </div>
                <div class="col-lg-4 col-md-4">
                    <h5 class="text-white mb-4">Newsletter</h5>
                    <p>Subscribe to get updates on new cars and special offers.</p>
                    <form class="mb-3">
                        <div class="input-group">
                            <input type="email" class="form-control" placeholder="Your Email">
                            <button class="btn btn-primary" type="submit">Subscribe</button>
                        </div>
                    </form>
                    <p><i class="fas fa-phone-alt me-2"></i> +1 (234) 567-8900</p>
                    <p><i class="fas fa-envelope me-2"></i> contact@cartrader.com</p>
                </div>
            </div>
            <hr class="my-4 bg-secondary">
            <div class="row">
                <div class="col-md-6 text-center text-md-start">
                    <p class="small text-muted mb-0">&copy; 2025 CarTrader. All rights reserved.</p>
                </div>
                <div class="col-md-6 text-center text-md-end">
                    <p class="small text-muted mb-0">
                        <a href="#" class="text-muted me-3">Privacy Policy</a>
                        <a href="#" class="text-muted me-3">Terms of Service</a>
                        <a href="#" class="text-muted">Sitemap</a>
                    </p>
                </div>
            </div>
        </div>
    </footer>

    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- AOS Animation Library -->
    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    <!-- Custom JavaScript -->
    <script>
        // Initialize AOS animation library
        AOS.init({
            once: true,
            duration: 1000
        });
        
        // Navbar scroll effect
        window.addEventListener('scroll', function() {
            const navbar = document.querySelector('.navbar');
            if (window.scrollY > 50) {
                navbar.classList.add('navbar-scrolled');
            } else {
                navbar.classList.remove('navbar-scrolled');
            }
        });
        
        // Counter animation
        function animateCounters() {
            const counters = document.querySelectorAll('.counter-number');
            const speed = 200;
            
            const values = [2500, 10000, 350, 15000]; // Target values for counters
            const ids = ['carsCounter', 'customersCounter', 'dealersCounter', 'salesCounter'];
            
            counters.forEach((counter, index) => {
                const updateCount = () => {
                    const target = values[index];
                    const count = +counter.innerText;
                    const increment = target / speed;
                    
                    if (count < target) {
                        counter.innerText = Math.ceil(count + increment);
                        setTimeout(updateCount, 1);
                    } else {
                        counter.innerText = target.toLocaleString();
                    }
                };
                
                updateCount();
            });
        }
        
        // Intersection Observer for counter animation
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    animateCounters();
                    observer.unobserve(entry.target);
                }
            });
        }, {threshold: 0.5});
        
        const statsSection = document.querySelector('.stats-counter');
        observer.observe(statsSection);
        
        // Car card hover effect - add pulse animation
        const carCards = document.querySelectorAll('.car-card');
        carCards.forEach(card => {
            card.addEventListener('mouseenter', () => {
                card.querySelector('.price-tag').style.transform = 'scale(1.1)';
            });
            
            card.addEventListener('mouseleave', () => {
                card.querySelector('.price-tag').style.transform = 'scale(1)';
            });
        });
        
        // Form field animation
        const formFields = document.querySelectorAll('.form-select, .form-control');
        formFields.forEach(field => {
            field.addEventListener('focus', () => {
                field.style.boxShadow = '0 0 0 0.25rem rgba(58, 134, 255, 0.25)';
                field.style.borderColor = 'var(--primary-color)';
            });
            
            field.addEventListener('blur', () => {
                field.style.boxShadow = '';
                field.style.borderColor = '';
            });
        });
    </script>
</body>
</html>