package com.carpurchase.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Custom linked list implementation for Car objects
 */
public class CarLinkedList {
    private Car head; // Head of the linked list
    private int size; // Size of the linked list
    
    public CarLinkedList() {
        this.head = null;
        this.size = 0;
    }
    
    /**
     * Adds a new car to the linked list
     * @param car The car to add
     */
    public void addCar(Car car) {
        // Add to the beginning of the linked list (O(1) operation)
        if (head == null) {
            head = car;
        } else {
            car.setNext(head);
            head = car;
        }
        size++;
    }
    
    /**
     * Gets all cars in the linked list
     * @return List of all cars
     */
    public List<Car> getAllCars() {
        List<Car> cars = new ArrayList<>();
        Car current = head;
        
        while (current != null) {
            cars.add(current);
            current = current.getNext();
        }
        
        return cars;
    }
    
    /**
     * Gets cars by seller ID
     * @param sellerId Seller's ID
     * @return List of cars owned by seller
     */
    public List<Car> getCarsBySellerID(String sellerId) {
        List<Car> cars = new ArrayList<>();
        Car current = head;
        
        while (current != null) {
            if (current.getSellerId().equals(sellerId)) {
                cars.add(current);
            }
            current = current.getNext();
        }
        
        return cars;
    }
    
    /**
     * Gets a car by ID
     * @param id Car ID to find
     * @return Car if found, null otherwise
     */
    public Car getCarById(String id) {
        Car current = head;
        
        while (current != null) {
            if (current.getId().equals(id)) {
                return current;
            }
            current = current.getNext();
        }
        
        return null;
    }
    
    /**
     * Updates a car in the list
     * @param updatedCar Car with updated values
     * @return true if car was found and updated, false otherwise
     */
    public boolean updateCar(Car updatedCar) {
        if (updatedCar == null || updatedCar.getId() == null) {
            return false;
        }
        
        boolean found = false;
        Car current = head;
        
        while (current != null) {
            if (current.getId().equals(updatedCar.getId())) {
                // Found the car to update
                // Preserve the next reference to maintain linked list structure
                updatedCar.setNext(current.getNext());
                
                // Now replace the current car with updatedCar in the linked list
                if (current == head) {
                    head = updatedCar;
                } else {
                    // Find the previous node to update its next pointer
                    Car prev = head;
                    while (prev != null && prev.getNext() != current) {
                        prev = prev.getNext();
                    }
                    if (prev != null) {
                        prev.setNext(updatedCar);
                    }
                }
                
                found = true;
                break;
            }
            current = current.getNext();
        }
        
        return found;
    }
    
    /**
     * Removes a car from the linked list
     * @param id ID of the car to remove
     * @return true if removed, false if not found
     */
    public boolean removeCar(String id) {
        if (head == null) {
            return false;
        }
        
        // Special case: remove head
        if (head.getId().equals(id)) {
            head = head.getNext();
            size--;
            return true;
        }
        
        // Search list for car
        Car current = head;
        while (current.getNext() != null) {
            if (current.getNext().getId().equals(id)) {
                current.setNext(current.getNext().getNext());
                size--;
                return true;
            }
            current = current.getNext();
        }
        
        return false;
    }
    
    /**
     * Clears the list and adds all cars from the provided list
     * @param cars List of cars to add
     */
    public void setAllCars(List<Car> cars) {
        // Clear the linked list
        head = null;
        size = 0;
        
        // Add all cars to the linked list
        for (Car car : cars) {
            car.setNext(null); // Clear any existing references
            if (head == null) {
                head = car;
            } else {
                car.setNext(head);
                head = car;
            }
            size++;
        }
    }
    
    /**
     * Converts the linked list to an array for sorting
     * @return Array of cars
     */
    public Car[] toArray() {
        Car[] array = new Car[size];
        Car current = head;
        int index = 0;
        
        while (current != null) {
            array[index++] = current;
            current = current.getNext();
        }
        
        return array;
    }
    
    /**
     * Gets the size of the linked list
     * @return Number of cars
     */
    public int getSize() {
        return size;
    }
    
    /**
     * Gets the head of the linked list
     * @return Head car node
     */
    public Car getHead() {
        return head;
    }
    
    /**
     * Searches for cars by make and/or model (case insensitive)
     * 
     * @param make Car make to search for (can be null)
     * @param model Car model to search for (can be null)
     * @return List of cars matching the search criteria
     */
    public List<Car> searchCars(String make, String model) {
        List<Car> results = new ArrayList<>();
        Car current = head;
        
        while (current != null) {
            boolean matchesMake = make == null || make.isEmpty() || 
                                 current.getMake().toLowerCase().contains(make.toLowerCase());
            boolean matchesModel = model == null || model.isEmpty() || 
                                  current.getModel().toLowerCase().contains(model.toLowerCase());
            
            if (matchesMake && matchesModel) {
                results.add(current);
            }
            
            current = current.getNext();
        }
        
        return results;
    }
}