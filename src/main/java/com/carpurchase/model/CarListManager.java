package com.carpurchase.model;

import java.io.*;
import java.util.List;

/**
 * Manages the list of cars using a custom LinkedList implementation
 * and handles file I/O for car_list.txt with sorting capabilities
 */
public class CarListManager {
    private static final String DATA_DIR = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data";
    private static final String CAR_LIST_FILE = "car_list.txt";
    
    private CarLinkedList carList; // Our custom linked list for cars
    
    public CarListManager() {
        this.carList = new CarLinkedList();
        loadCarsFromFile(); // Load existing cars when manager is created
    }
    
    /**
     * Adds a new car to the linked list and saves to file
     * @param car The car to add
     */
    public void addCar(Car car) {
        carList.addCar(car);
        
        // Save to file
        saveToFile();
    }
    
    /**
     * Gets all cars in the linked list
     * @return List of all cars
     */
    public List<Car> getAllCars() {
        return carList.getAllCars();
    }
    
    /**
     * Gets cars by seller ID
     * @param sellerId Seller's ID
     * @return List of cars owned by seller
     */
    public List<Car> getCarsBySellerID(String sellerId) {
        return carList.getCarsBySellerID(sellerId);
    }
    
    /**
     * Gets a car by ID
     * @param id Car ID to find
     * @return Car if found, null otherwise
     */
    public Car getCarById(String id) {
        return carList.getCarById(id);
    }
    
    /**
     * Updates a car in the list
     * @param updatedCar Car with updated values
     * @return true if car was found and updated, false otherwise
     */
    public boolean updateCar(Car updatedCar) {
        boolean result = carList.updateCar(updatedCar);
        if (result) {
            rewriteFile();
        }
        return result;
    }
    
    /**
     * Removes a car from the linked list
     * @param id ID of the car to remove
     * @return true if removed, false if not found
     */
    public boolean removeCar(String id) {
        boolean result = carList.removeCar(id);
        if (result) {
            saveToFile();
        }
        return result;
    }
    
    /**
     * Deletes a car by ID - Added for compatibility with my-listing.jsp
     * @param carId ID of the car to delete
     * @return true if deleted, false if not found
     */
    public boolean deleteCar(String carId) {
        return removeCar(carId);
    }
    
    /**
     * Saves a list of cars to the file (used by external methods)
     * @param cars List of cars to save
     * @return true if successful, false otherwise
     */
    public boolean saveAllCars(List<Car> cars) {
        try {
            carList.setAllCars(cars);
            
            // Save to file
            rewriteFile();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Basic file save method
     */
    private void saveToFile() {
        rewriteFile(); // Just use our more reliable method
    }
    
    /**
     * More reliable method to completely rewrite the file with current car data
     */
    private void rewriteFile() {
        File dir = new File(DATA_DIR);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        
        File file = new File(dir, CAR_LIST_FILE);
        
        try {
            // Create a string builder to hold all the file content
            StringBuilder content = new StringBuilder();
            
            // Add each car's data
            List<Car> cars = carList.getAllCars();
            for (Car current : cars) {
                content.append("==== CAR LISTING RECORD ====\n");
                content.append("Listing ID: " + current.getId() + "\n");
                appendIfNotNull(content, "Title", current.getTitle());
                appendIfNotNull(content, "Make", current.getMake());
                appendIfNotNull(content, "Model", current.getModel());
                content.append("Year: " + current.getYear() + "\n");
                appendIfNotNull(content, "Body Type", current.getBodyType());
                appendIfNotNull(content, "Condition", current.getCondition());
                appendIfNotNull(content, "Trim", current.getTrim());
                appendIfNotNull(content, "VIN", current.getVin());
                content.append("Mileage: " + current.getMileage() + "\n");
                appendIfNotNull(content, "Exterior Color", current.getExteriorColor());
                appendIfNotNull(content, "Interior Color", current.getInteriorColor());
                appendIfNotNull(content, "Transmission", current.getTransmission());
                appendIfNotNull(content, "Fuel Type", current.getFuelType());
                appendIfNotNull(content, "Doors", current.getDoors());
                appendIfNotNull(content, "Drive Type", current.getDriveType());
                appendIfNotNull(content, "Engine", current.getEngine());
                content.append("Price: " + current.getPrice() + "\n");
                appendIfNotNull(content, "Description", current.getDescription());
                
                // Handle features
                if (current.getFeatures() != null && !current.getFeatures().isEmpty()) {
                    content.append("Features: ");
                    content.append(String.join(", ", current.getFeatures()));
                    content.append("\n");
                } else {
                    content.append("Features: \n");
                }
                
                // Handle photos
                if (current.getPhotos() != null && !current.getPhotos().isEmpty()) {
                    content.append("Photos: ");
                    content.append(String.join(", ", current.getPhotos()));
                    content.append("\n");
                } else {
                    content.append("Photos: \n");
                }
                
                appendIfNotNull(content, "Seller ID", current.getSellerId());
                appendIfNotNull(content, "Contact Name", current.getContactName());
                appendIfNotNull(content, "Contact Email", current.getContactEmail());
                appendIfNotNull(content, "Contact Phone", current.getContactPhone());
                appendIfNotNull(content, "Location", current.getLocation());
                appendIfNotNull(content, "Listing Date", current.getListingDate());
                appendIfNotNull(content, "Status", current.getStatus());
                content.append("-----------------------------\n");
            }
            
            // Write the content to the file
            try (FileWriter writer = new FileWriter(file, false)) {
                writer.write(content.toString());
            }
            
            System.out.println("Cars saved to file successfully (complete rewrite).");
            
        } catch (IOException e) {
            System.err.println("Error saving car list to file: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Helper method to append a field to the content only if it's not null
     */
    private void appendIfNotNull(StringBuilder content, String field, String value) {
        content.append(field).append(": ");
        if (value != null) {
            content.append(value);
        }
        content.append("\n");
    }
    
    /**
     * Loads cars from the car_list.txt file into the linked list
     * This method is improved to handle potential file format issues
     */
    private void loadCarsFromFile() {
        File file = new File(DATA_DIR, CAR_LIST_FILE);
        
        if (!file.exists()) {
            System.out.println("Car list file does not exist yet. Starting with empty list.");
            return;
        }
        
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            Car currentCar = null;
            boolean inRecord = false;
            boolean foundFirstRecord = false;
            
            while ((line = br.readLine()) != null) {
                line = line.trim();
                
                // Skip any lines before the first car record marker
                if (!foundFirstRecord && !line.equals("==== CAR LISTING RECORD ====")) {
                    // Skip this line - it's likely metadata
                    continue;
                }
                
                if (line.equals("==== CAR LISTING RECORD ====")) {
                    // Start of a new car record
                    foundFirstRecord = true;
                    inRecord = true;
                    continue;
                }
                
                if (line.equals("-----------------------------")) {
                    // End of a car record, add to linked list
                    if (currentCar != null) {
                        carList.addCar(currentCar);
                    }
                    inRecord = false;
                    currentCar = null;
                    continue;
                }
                
                // Process car data
                if (inRecord && line.contains(": ")) {
                    String[] parts = line.split(": ", 2);
                    if (parts.length == 2) {
                        String key = parts[0].trim();
                        String value = parts[1].trim();
                        
                        // Process key-value pair
                        if (key.equals("Listing ID")) {
                            currentCar = new Car(value);
                        } else if (currentCar != null) {
                            processCarField(currentCar, key, value);
                        }
                    }
                }
            }
            
            System.out.println("Loaded " + carList.getSize() + " cars from file.");
            
        } catch (IOException e) {
            System.err.println("Error loading car list from file: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Processes a key-value pair from the file and sets the appropriate field on the car
     */
    private void processCarField(Car car, String key, String value) {
        // Skip empty values
        if (value.isEmpty()) {
            return;
        }
        
        switch (key) {
            case "Title":
                car.setTitle(value);
                break;
            case "Make":
                car.setMake(value);
                break;
            case "Model":
                car.setModel(value);
                break;
            case "Year":
                try {
                    car.setYear(Integer.parseInt(value));
                } catch (NumberFormatException e) {
                    car.setYear(0);
                }
                break;
            case "Body Type":
                car.setBodyType(value);
                break;
            case "Condition":
                car.setCondition(value);
                break;
            case "Trim":
                car.setTrim(value);
                break;
            case "VIN":
                car.setVin(value);
                break;
            case "Mileage":
                try {
                    car.setMileage(Integer.parseInt(value));
                } catch (NumberFormatException e) {
                    car.setMileage(0);
                }
                break;
            case "Exterior Color":
                car.setExteriorColor(value);
                break;
            case "Interior Color":
                car.setInteriorColor(value);
                break;
            case "Transmission":
                car.setTransmission(value);
                break;
            case "Fuel Type":
                car.setFuelType(value);
                break;
            case "Doors":
                car.setDoors(value);
                break;
            case "Drive Type":
                car.setDriveType(value);
                break;
            case "Engine":
                car.setEngine(value);
                break;
            case "Price":
                try {
                    car.setPrice(Double.parseDouble(value));
                } catch (NumberFormatException e) {
                    car.setPrice(0);
                }
                break;
            case "Description":
                car.setDescription(value);
                break;
            case "Features":
                if (!value.isEmpty()) {
                    String[] features = value.split(", ");
                    for (String feature : features) {
                        car.addFeature(feature);
                    }
                }
                break;
            case "Photos":
                if (!value.isEmpty()) {
                    String[] photos = value.split(", ");
                    for (String photo : photos) {
                        car.addPhoto(photo);
                    }
                }
                break;
            case "Seller ID":
                car.setSellerId(value);
                break;
            case "Contact Name":
                car.setContactName(value);
                break;
            case "Contact Email":
                car.setContactEmail(value);
                break;
            case "Contact Phone":
                car.setContactPhone(value);
                break;
            case "Location":
                car.setLocation(value);
                break;
            case "Listing Date":
                car.setListingDate(value);
                break;
            case "Status":
                car.setStatus(value);
                break;
        }
    }
    
    /**
     * Gets the size of the linked list
     * @return Number of cars
     */
    public int getSize() {
        return carList.getSize();
    }
    
    /**
     * Gets all cars sorted by price using Merge Sort algorithm
     * 
     * @param ascending true for ascending, false for descending order
     * @return List of sorted cars
     */
    public List<Car> getAllCarsSortedByPrice(boolean ascending) {
        return CarSorter.sortByPrice(carList, ascending);
    }
    
    /**
     * Searches for cars by make and/or model (case insensitive)
     * 
     * @param make Car make to search for (can be null)
     * @param model Car model to search for (can be null)
     * @return List of cars matching the search criteria
     */
    public List<Car> searchCars(String make, String model) {
        return carList.searchCars(make, model);
    }
}