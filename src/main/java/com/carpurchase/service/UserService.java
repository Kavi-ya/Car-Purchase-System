package com.carpurchase.service;

import com.carpurchase.model.User;
import java.io.*;
import java.nio.file.*;
import java.util.*;

/**
 * Service class for managing user operations.
 */
public class UserService {
    private static final String DATA_DIR = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data";
    private static final String USER_FILE = DATA_DIR + File.separator + "users.txt";
    
    /**
     * Gets all users from the file.
     * 
     * @return List of all users.
     */
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        File file = new File(USER_FILE);
        
        if (!file.exists()) {
            return users;
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            User currentUser = null;
            boolean inUserRecord = false;
            
            // Skip metadata at beginning (Current Date and Current User lines)
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("Current Date") || line.startsWith("Current User")) {
                    continue;
                }
                
                if (line.equals("==== USER RECORD ====")) {
                    currentUser = new User();
                    inUserRecord = true;
                } else if (inUserRecord) {
                    if (line.startsWith("User ID: ")) {
                        currentUser.setId(line.substring("User ID: ".length()));
                    } else if (line.startsWith("Username: ")) {
                        currentUser.setUsername(line.substring("Username: ".length()));
                    } else if (line.startsWith("Password: ")) {
                        currentUser.setPassword(line.substring("Password: ".length()));
                    } else if (line.startsWith("Full Name: ")) {
                        currentUser.setFullName(line.substring("Full Name: ".length()));
                    } else if (line.startsWith("Email: ")) {
                        currentUser.setEmail(line.substring("Email: ".length()));
                    } else if (line.startsWith("Role: ")) {
                        currentUser.setRole(line.substring("Role: ".length()));
                    } else if (line.startsWith("Active: ")) {
                        currentUser.setActive(Boolean.parseBoolean(line.substring("Active: ".length())));
                    } else if (line.startsWith("Created Date: ")) {
                        currentUser.setCreatedDate(line.substring("Created Date: ".length()));
                    } else if (line.equals("-----------------------------")) {
                        users.add(currentUser);
                        inUserRecord = false;
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        return users;
    }
    
    /**
     * Gets a user by ID.
     * 
     * @param userId The ID of the user to find.
     * @return The User object if found, null otherwise.
     */
    public User getUserById(String userId) {
        for (User user : getAllUsers()) {
            if (user.getId().equals(userId)) {
                return user;
            }
        }
        return null;
    }
    
    /**
     * Gets a user by username.
     * 
     * @param username The username of the user to find.
     * @return The User object if found, null otherwise.
     */
    public User getUserByUsername(String username) {
        for (User user : getAllUsers()) {
            if (user.getUsername().equals(username)) {
                return user;
            }
        }
        return null;
    }
    
    /**
     * Adds a new user to the file.
     * 
     * @param user The user to add.
     * @return true if successful, false otherwise.
     */
    public boolean addUser(User user) {
        File file = new File(USER_FILE);
        File parent = file.getParentFile();
        
        if (!parent.exists()) {
            parent.mkdirs();
        }
        
        try {
            // Always use append mode
            try (FileWriter fw = new FileWriter(file, true); 
                 BufferedWriter writer = new BufferedWriter(fw)) {
                
                writer.write("==== USER RECORD ====");
                writer.newLine();
                writer.write("User ID: " + user.getId());
                writer.newLine();
                writer.write("Username: " + user.getUsername());
                writer.newLine();
                writer.write("Password: " + user.getPassword());
                writer.newLine();
                writer.write("Full Name: " + user.getFullName());
                writer.newLine();
                writer.write("Email: " + user.getEmail());
                writer.newLine();
                writer.write("Role: " + user.getRole());
                writer.newLine();
                writer.write("Active: " + user.isActive());
                writer.newLine();
                writer.write("Created Date: " + user.getCreatedDate());
                writer.newLine();
                writer.write("-----------------------------");
                writer.newLine();
                
                writer.flush();
                return true;
            }
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Updates an existing user.
     * 
     * @param updatedUser The updated user information.
     * @return true if successful, false otherwise.
     */
    public boolean updateUser(User updatedUser) {
        List<User> users = getAllUsers();
        boolean found = false;
        
        for (int i = 0; i < users.size(); i++) {
            if (users.get(i).getId().equals(updatedUser.getId())) {
                users.set(i, updatedUser);
                found = true;
                break;
            }
        }
        
        if (!found) {
            return false;
        }
        
        return saveAllUsers(users);
    }
    
    /**
     * Deletes a user by ID.
     * 
     * @param userId The ID of the user to delete.
     * @return true if successful, false otherwise.
     */
    public boolean deleteUser(String userId) {
        List<User> users = getAllUsers();
        boolean found = false;
        
        for (Iterator<User> iterator = users.iterator(); iterator.hasNext();) {
            User user = iterator.next();
            if (user.getId().equals(userId)) {
                iterator.remove();
                found = true;
                break;
            }
        }
        
        if (!found) {
            return false;
        }
        
        return saveAllUsers(users);
    }
    
    /**
     * Saves all users to the file.
     * 
     * @param users The list of users to save.
     * @return true if successful, false otherwise.
     */
    private boolean saveAllUsers(List<User> users) {
        File file = new File(USER_FILE);
        
        // First create a temp file
        File tempFile = new File(USER_FILE + ".tmp");
        
        try {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(tempFile))) {
                for (User user : users) {
                    writer.write("==== USER RECORD ====");
                    writer.newLine();
                    writer.write("User ID: " + user.getId());
                    writer.newLine();
                    writer.write("Username: " + user.getUsername());
                    writer.newLine();
                    writer.write("Password: " + user.getPassword());
                    writer.newLine();
                    writer.write("Full Name: " + user.getFullName());
                    writer.newLine();
                    writer.write("Email: " + user.getEmail());
                    writer.newLine();
                    writer.write("Role: " + user.getRole());
                    writer.newLine();
                    writer.write("Active: " + user.isActive());
                    writer.newLine();
                    writer.write("Created Date: " + user.getCreatedDate());
                    writer.newLine();
                    writer.write("-----------------------------");
                    writer.newLine();
                }
                writer.flush();
            }
            
            // Replace the original file with the temp file
            if (file.exists()) {
                file.delete();
            }
            
            boolean renameResult = tempFile.renameTo(file);
            
            if (!renameResult) {
                Files.copy(tempFile.toPath(), file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                tempFile.delete();
            }
            
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Initializes the user store with an admin user if needed.
     */
    public void initializeUserStore() {
        File file = new File(USER_FILE);
        
        if (!file.exists() || file.length() == 0) {
            try {
                File parent = file.getParentFile();
                if (!parent.exists()) {
                    parent.mkdirs();
                }
                
                if (!file.exists()) {
                    file.createNewFile();
                }
                
                // Create admin user
                User adminUser = new User();
                adminUser.setUsername("admin");
                adminUser.setPassword("admin123"); // Should be hashed in real app
                adminUser.setFullName("System Administrator");
                adminUser.setEmail("admin@cartrader.com");
                adminUser.setRole("admin");
                adminUser.setActive(true);
                
                addUser(adminUser);
                
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}