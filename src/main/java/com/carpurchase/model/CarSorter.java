package com.carpurchase.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Provides sorting algorithms for Car objects
 */
public class CarSorter {
    
    /**
     * Sorts a list of cars by price using merge sort algorithm
     * 
     * @param carList The linked list of cars to sort
     * @param ascending true for ascending, false for descending order
     * @return List of sorted cars
     */
    public static List<Car> sortByPrice(CarLinkedList carList, boolean ascending) {
        // Convert linked list to array for merge sort
        Car[] carsArray = carList.toArray();
        
        // Apply merge sort
        mergeSortByPrice(carsArray, 0, carList.getSize() - 1, ascending);
        
        // Convert sorted array back to list
        List<Car> sortedCars = new ArrayList<>();
        for (Car car : carsArray) {
            sortedCars.add(car);
        }
        
        return sortedCars;
    }
    
    /**
     * Implementation of Merge Sort algorithm to sort cars by price
     * 
     * @param cars Array of cars to sort
     * @param left Start index
     * @param right End index
     * @param ascending true for ascending, false for descending order
     */
    private static void mergeSortByPrice(Car[] cars, int left, int right, boolean ascending) {
        if (left < right) {
            // Find the middle point
            int middle = left + (right - left) / 2;
            
            // Sort first and second halves
            mergeSortByPrice(cars, left, middle, ascending);
            mergeSortByPrice(cars, middle + 1, right, ascending);
            
            // Merge the sorted halves
            merge(cars, left, middle, right, ascending);
        }
    }
    
    /**
     * Merges two subarrays of cars sorted by price
     * 
     * @param cars Array of cars
     * @param left Start index
     * @param middle Middle index
     * @param right End index
     * @param ascending true for ascending, false for descending order
     */
    private static void merge(Car[] cars, int left, int middle, int right, boolean ascending) {
        // Find sizes of two subarrays to be merged
        int n1 = middle - left + 1;
        int n2 = right - middle;
        
        // Create temp arrays
        Car[] leftArray = new Car[n1];
        Car[] rightArray = new Car[n2];
        
        // Copy data to temp arrays
        for (int i = 0; i < n1; ++i)
            leftArray[i] = cars[left + i];
        for (int j = 0; j < n2; ++j)
            rightArray[j] = cars[middle + 1 + j];
        
        // Merge the temp arrays
        int i = 0, j = 0;
        int k = left;
        
        while (i < n1 && j < n2) {
            if (ascending) {
                if (leftArray[i].getPrice() <= rightArray[j].getPrice()) {
                    cars[k] = leftArray[i];
                    i++;
                } else {
                    cars[k] = rightArray[j];
                    j++;
                }
            } else {
                if (leftArray[i].getPrice() >= rightArray[j].getPrice()) {
                    cars[k] = leftArray[i];
                    i++;
                } else {
                    cars[k] = rightArray[j];
                    j++;
                }
            }
            k++;
        }
        
        // Copy remaining elements of leftArray[] if any
        while (i < n1) {
            cars[k] = leftArray[i];
            i++;
            k++;
        }
        
        // Copy remaining elements of rightArray[] if any
        while (j < n2) {
            cars[k] = rightArray[j];
            j++;
            k++;
        }
    }
}