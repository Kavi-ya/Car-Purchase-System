package com.carpurchase.model;

public class User {
    private String userId;
    private String registrationDate;
    private String fullName;
    private String email;
    private String phone;
    private String username;
    private String password;
    private String role;
    private String active;
    private String contactMethod;
    private String newsLetterSubscription;


    public User ()
    {
		this.userId = "";
		this.registrationDate = "";
		this.fullName = "";
		this.email = "";
		this.phone = "";
		this.username = "";
		this.password = "";
		this.role = "";
		this.active = "";
		this.contactMethod = "";
		this.newsLetterSubscription = "";

    }
    public User (String userId, String registrationDate, String fullName, String email, String phone, String username, String password, String role, String active, String contactMethod, String newsLetterSubscription) {
        this.userId = userId;
        this.registrationDate = registrationDate;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.username = username;
        this.password = password;
        this.role = role;
        this.active = active;
        this.contactMethod = contactMethod;
        this.newsLetterSubscription = newsLetterSubscription;
    }

    public String getUserId() {
        return userId;
    }
    public void setUserId(String userId) {
        this.userId = userId;
    }
    public String getRegistrationDate() {
        return registrationDate;
    }
    public void setRegistrationDate(String registrationDate) {
        this.registrationDate = registrationDate;
    }
    public String getFullName() {
        return fullName;
    }
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public String getPhone() {
        return phone;
    }
    public void setPhone(String phone) {
        this.phone = phone;
    }
    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public String getRole() {
        return role;
    }
    public void setRole(String role) {
        this.role = role;
    }
    public String getActive() {
        return active;
    }
    public void setActive(String active) {
        this.active = active;
    }
    public String getContactMethod() {
        return contactMethod;
    }
    public void setContactMethod(String contactMethod) {
        this.contactMethod = contactMethod;
    }
    public String getNewsLetterSubscription() {
        return newsLetterSubscription;
    }
    public void setNewsLetterSubscription(String newsLetterSubscription) {
        this.newsLetterSubscription = newsLetterSubscription;
    }
    
    @Override
    public String toString() {
        return userId + " ," +
                registrationDate + " ," +
                fullName + " ," +
                email + " ," +
                phone + " ," +
                username + " ," +
                password + " ," +
                role + " ," +
                active + " ," +
                contactMethod + " ," +
                newsLetterSubscription;

    }
}