package com.carpurchase.servlets;

import com.carpurchase.model.User;
import com.carpurchase.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Servlet that handles user management operations.
 */
// @WebServlet("/admin/user-management")
public class UserManagementServlet extends HttpServlet {
    private UserService userService = new UserService();

    @Override
    public void init() throws ServletException {
        userService.initializeUserStore();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in as admin
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        String userRole = (String) session.getAttribute("userRole");
        
        if (username == null || !"admin".equalsIgnoreCase(userRole)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        String userId = request.getParameter("userid");
        
        // Process GET actions (delete, activate, deactivate)
        if (action != null && userId != null) {
            processAction(action, userId, request);
        }
        
        // Load all users for display
        List<User> users = userService.getAllUsers();
        
        // Sort users (admins first, then by username)
        Collections.sort(users, new Comparator<User>() {
            @Override
            public int compare(User u1, User u2) {
                if (u1.getRole().equals("admin") && !u2.getRole().equals("admin")) {
                    return -1;
                } else if (!u1.getRole().equals("admin") && u2.getRole().equals("admin")) {
                    return 1;
                } else {
                    return u1.getUsername().compareTo(u2.getUsername());
                }
            }
        });
        
        // Set attributes for the JSP
        request.setAttribute("users", users);
        try {
			request.setAttribute("userFilePath", userService.getClass().getDeclaredField("USER_FILE").get(null));
		} catch (IllegalArgumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (NoSuchFieldException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        // Forward to JSP
        request.getRequestDispatcher("/admin/user-management.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in as admin
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        String userRole = (String) session.getAttribute("userRole");
        
        if (username == null || !"admin".equalsIgnoreCase(userRole)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            addUser(request);
        } else if ("edit".equals(action)) {
            updateUser(request);
        }
        
        // Redirect back to the user management page
        response.sendRedirect(request.getContextPath() + "/admin/user-management");
    }
    
    private void processAction(String action, String userId, HttpServletRequest request) {
        User user = userService.getUserById(userId);
        boolean success = false;
        String message = "";
        
        if (user == null) {
            message = "User not found.";
            request.getSession().setAttribute("message", message);
            request.getSession().setAttribute("success", false);
            return;
        }
        
        if ("delete".equals(action)) {
            // Delete user
            if ("admin".equals(user.getRole())) {
                message = "Cannot delete admin user.";
                success = false;
            } else {
                success = userService.deleteUser(userId);
                message = success ? "User deleted successfully." : "Error deleting user.";
            }
        } else if ("activate".equals(action)) {
            // Activate user
            user.setActive(true);
            success = userService.updateUser(user);
            message = success ? "User activated successfully." : "Error activating user.";
        } else if ("deactivate".equals(action)) {
            // Deactivate user
            if ("admin".equals(user.getRole())) {
                message = "Cannot deactivate admin user.";
                success = false;
            } else {
                user.setActive(false);
                success = userService.updateUser(user);
                message = success ? "User deactivated successfully." : "Error deactivating user.";
            }
        }
        
        request.getSession().setAttribute("message", message);
        request.getSession().setAttribute("success", success);
    }
    
    private void addUser(HttpServletRequest request) {
        String newUsername = request.getParameter("newUsername");
        String newPassword = request.getParameter("newPassword");
        String newEmail = request.getParameter("newEmail");
        String newFullName = request.getParameter("newFullName");
        String newRole = request.getParameter("newRole");
        
        boolean success = false;
        String message = "";
        
        // Validate username is unique
        User existingUser = userService.getUserByUsername(newUsername);
        if (existingUser != null) {
            message = "Username already exists. Please choose a different username.";
        } else {
            // Create new user
            User newUser = new User();
            newUser.setUsername(newUsername);
            newUser.setPassword(newPassword); // In real app, this should be hashed
            newUser.setEmail(newEmail);
            newUser.setFullName(newFullName);
            newUser.setRole(newRole);
            newUser.setActive(true);
            
            success = userService.addUser(newUser);
            message = success ? "User added successfully!" : "Error adding user.";
        }
        
        request.getSession().setAttribute("message", message);
        request.getSession().setAttribute("success", success);
    }
    
    private void updateUser(HttpServletRequest request) {
        String editUserId = request.getParameter("editUserId");
        String editUsername = request.getParameter("editUsername");
        String editPassword = request.getParameter("editPassword");
        String editEmail = request.getParameter("editEmail");
        String editFullName = request.getParameter("editFullName");
        String editRole = request.getParameter("editRole");
        String editActive = request.getParameter("editActive");
        
        boolean success = false;
        String message = "";
        
        User user = userService.getUserById(editUserId);
        if (user != null) {
            // Check if username is changed and if it's unique
            if (!user.getUsername().equals(editUsername)) {
                User existingUser = userService.getUserByUsername(editUsername);
                if (existingUser != null) {
                    message = "Username already exists. Please choose a different username.";
                    request.getSession().setAttribute("message", message);
                    request.getSession().setAttribute("success", false);
                    return;
                } else {
                    user.setUsername(editUsername);
                }
            }
            
            // Only update password if provided
            if (editPassword != null && !editPassword.trim().isEmpty()) {
                user.setPassword(editPassword); // In real app, this should be hashed
            }
            
            user.setEmail(editEmail);
            user.setFullName(editFullName);
            user.setRole(editRole);
            user.setActive("on".equals(editActive));
            
            success = userService.updateUser(user);
            message = success ? "User updated successfully!" : "Error updating user.";
        } else {
            message = "User not found.";
        }
        
        request.getSession().setAttribute("message", message);
        request.getSession().setAttribute("success", success);
    }
}