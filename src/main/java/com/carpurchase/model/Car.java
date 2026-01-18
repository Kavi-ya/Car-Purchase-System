package com.carpurchase.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a car listing in the system
 */
public class Car {
    private String id;
    private String title;
    private String make;
    private String model;
    private int year;
    private String bodyType;
    private String condition;
    private String trim;
    private String vin;
    private int mileage;
    private String exteriorColor;
    private String interiorColor;
    private String transmission;
    private String fuelType;
    private String doors;
    private String driveType;
    private String engine;
    private double price;
    private String description;
    private List<String> features;
    private List<String> photos;
    private String sellerId;
    private String contactName;
    private String contactEmail;
    private String contactPhone;
    private String location;
    private String listingDate;
    private String status;
    
    // Linked list implementation - each car can reference the next car
    private Car next;
    
    // Constructor
    public Car(String id) {
        this.id = id;
        this.features = new ArrayList<>();
        this.photos = new ArrayList<>();
        this.status = "Active";
    }
    
    // Getters and setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMake() {
        return make;
    }

    public void setMake(String make) {
        this.make = make;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public String getBodyType() {
        return bodyType;
    }

    public void setBodyType(String bodyType) {
        this.bodyType = bodyType;
    }

    public String getCondition() {
        return condition;
    }

    public void setCondition(String condition) {
        this.condition = condition;
    }

    public String getTrim() {
        return trim;
    }

    public void setTrim(String trim) {
        this.trim = trim;
    }

    public String getVin() {
        return vin;
    }

    public void setVin(String vin) {
        this.vin = vin;
    }

    public int getMileage() {
        return mileage;
    }

    public void setMileage(int mileage) {
        this.mileage = mileage;
    }

    public String getExteriorColor() {
        return exteriorColor;
    }

    public void setExteriorColor(String exteriorColor) {
        this.exteriorColor = exteriorColor;
    }

    public String getInteriorColor() {
        return interiorColor;
    }

    public void setInteriorColor(String interiorColor) {
        this.interiorColor = interiorColor;
    }

    public String getTransmission() {
        return transmission;
    }

    public void setTransmission(String transmission) {
        this.transmission = transmission;
    }

    public String getFuelType() {
        return fuelType;
    }

    public void setFuelType(String fuelType) {
        this.fuelType = fuelType;
    }

    public String getDoors() {
        return doors;
    }

    public void setDoors(String doors) {
        this.doors = doors;
    }

    public String getDriveType() {
        return driveType;
    }

    public void setDriveType(String driveType) {
        this.driveType = driveType;
    }

    public String getEngine() {
        return engine;
    }

    public void setEngine(String engine) {
        this.engine = engine;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public List<String> getFeatures() {
        return features;
    }

    public void setFeatures(List<String> features) {
        this.features = features;
    }
    
    public void addFeature(String feature) {
        this.features.add(feature);
    }

    public List<String> getPhotos() {
        return photos;
    }

    public void setPhotos(List<String> photos) {
        this.photos = photos;
    }
    
    public void addPhoto(String photo) {
        this.photos.add(photo);
    }

    public String getSellerId() {
        return sellerId;
    }

    public void setSellerId(String sellerId) {
        this.sellerId = sellerId;
    }

    public String getContactName() {
        return contactName;
    }

    public void setContactName(String contactName) {
        this.contactName = contactName;
    }

    public String getContactEmail() {
        return contactEmail;
    }

    public void setContactEmail(String contactEmail) {
        this.contactEmail = contactEmail;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getListingDate() {
        return listingDate;
    }

    public void setListingDate(String listingDate) {
        this.listingDate = listingDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Car getNext() {
        return next;
    }

    public void setNext(Car next) {
        this.next = next;
    }
    
    // Format car data to store in text file
    public String toFileString() {
        StringBuilder sb = new StringBuilder();
        
        sb.append("==== CAR LISTING RECORD ====\n");
        sb.append("Listing ID: ").append(id != null ? id : "").append("\n");
        sb.append("Title: ").append(title != null ? title : "").append("\n");
        sb.append("Make: ").append(make != null ? make : "").append("\n");
        sb.append("Model: ").append(model != null ? model : "").append("\n");
        sb.append("Year: ").append(year).append("\n");
        sb.append("Body Type: ").append(bodyType != null ? bodyType : "").append("\n");
        sb.append("Condition: ").append(condition != null ? condition : "").append("\n");
        
        // Always include all fields with null checks
        sb.append("Trim: ").append(trim != null ? trim : "").append("\n");
        sb.append("VIN: ").append(vin != null ? vin : "").append("\n");
        sb.append("Mileage: ").append(mileage).append("\n");
        sb.append("Exterior Color: ").append(exteriorColor != null ? exteriorColor : "").append("\n");
        sb.append("Interior Color: ").append(interiorColor != null ? interiorColor : "").append("\n");
        sb.append("Transmission: ").append(transmission != null ? transmission : "").append("\n");
        sb.append("Fuel Type: ").append(fuelType != null ? fuelType : "").append("\n");
        sb.append("Doors: ").append(doors != null ? doors : "").append("\n");
        sb.append("Drive Type: ").append(driveType != null ? driveType : "").append("\n");
        sb.append("Engine: ").append(engine != null ? engine : "").append("\n");
        sb.append("Price: ").append(price).append("\n");
        sb.append("Description: ").append(description != null ? description : "").append("\n");
        
        // Features
        sb.append("Features: ");
        if (features != null && !features.isEmpty()) {
            sb.append(String.join(", ", features));
        }
        sb.append("\n");
        
        // Photos
        sb.append("Photos: ");
        if (photos != null && !photos.isEmpty()) {
            sb.append(String.join(", ", photos));
        }
        sb.append("\n");
        
        sb.append("Seller ID: ").append(sellerId != null ? sellerId : "").append("\n");
        sb.append("Contact Name: ").append(contactName != null ? contactName : "").append("\n");
        sb.append("Contact Email: ").append(contactEmail != null ? contactEmail : "").append("\n");
        sb.append("Contact Phone: ").append(contactPhone != null ? contactPhone : "").append("\n");
        sb.append("Location: ").append(location != null ? location : "").append("\n");
        sb.append("Listing Date: ").append(listingDate != null ? listingDate : "").append("\n");
        sb.append("Status: ").append(status != null ? status : "").append("\n");
        sb.append("-----------------------------\n");
        
        return sb.toString();
    }
}