package com.carpurchase.servlets;

import java.io.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class InquiryServlet
 * Handles saving and retrieving car inquiries
 * Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-05-06 13:04:41
 * Current User's Login: IT24102083
 */
@WebServlet("/InquiryServlet")
public class InquiryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Hardcoded file path
    private static final String INQUIRIES_FILE = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp\\WEB-INF\\data\\MyInquiries.txt";
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public InquiryServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     * Handles loading user inquiries for display, for both buyers and sellers
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        String userRole = (String) session.getAttribute("userRole");
        
        if (userId == null || username == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Different behaviors based on user role
        if ("buyer".equalsIgnoreCase(userRole)) {
            // For buyers, get inquiries sent by them
            List<Map<String, String>> userInquiries = getUserInquiries(userId);
            request.setAttribute("inquiries", userInquiries);
            request.getRequestDispatcher("/MyInquiries.jsp").forward(request, response);
        } else if ("seller".equalsIgnoreCase(userRole)) {
            // For sellers, get inquiries sent to them
            List<Map<String, String>> sellerInquiries = getSellerInquiries(userId);
            
            // Apply filter if specified
            String filterParam = request.getParameter("filter");
            if (filterParam != null && !filterParam.isEmpty()) {
                List<Map<String, String>> filteredInquiries = new ArrayList<>();
                for (Map<String, String> inquiry : sellerInquiries) {
                    String status = inquiry.get("Status");
                    if ("pending".equalsIgnoreCase(filterParam) && "Pending".equalsIgnoreCase(status)) {
                        filteredInquiries.add(inquiry);
                    } else if ("replied".equalsIgnoreCase(filterParam) && "Replied".equalsIgnoreCase(status)) {
                        filteredInquiries.add(inquiry);
                    }
                }
                request.setAttribute("inquiries", filteredInquiries);
            } else {
                request.setAttribute("inquiries", sellerInquiries);
            }
            
            request.getRequestDispatcher("/inquiries.jsp").forward(request, response);
        } else {
            response.sendRedirect("login.jsp");
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     * Handles creating new inquiries and updating inquiry status/replies
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        String userRole = (String) session.getAttribute("userRole");
        
        if (userId == null || username == null) {
            // Check if this is an AJAX request or a form submission
            boolean isAjax = isAjaxRequest(request);
            if (isAjax) {
                sendTextResponse(response, false, "User not authenticated");
            } else {
                response.sendRedirect("login.jsp");
            }
            return;
        }
        
        // Determine the action based on parameters
        String updateInquiryId = request.getParameter("updateInquiry");
        String replyText = request.getParameter("replyText");
        String newStatus = request.getParameter("newStatus");
        
        // Check if this is an AJAX request or a form submission
        boolean isAjax = isAjaxRequest(request);
        
        if (updateInquiryId != null) {
            // This is an update to an existing inquiry (status change or reply)
            if ("seller".equalsIgnoreCase(userRole)) {
                // Only sellers can update inquiry status or add replies
                Map<String, String> inquiryDetails = getInquiryById(updateInquiryId);
                
                if (inquiryDetails == null) {
                    // Inquiry not found
                    if (!isAjax) {
                        response.sendRedirect("InquiryServlet?error=notfound");
                    } else {
                        sendTextResponse(response, false, "Inquiry not found");
                    }
                    return;
                }
                
                // Check if this inquiry belongs to this seller
                if (!userId.equals(inquiryDetails.get("SellerId"))) {
                    if (!isAjax) {
                        response.sendRedirect("InquiryServlet?error=unauthorized");
                    } else {
                        sendTextResponse(response, false, "You are not authorized to update this inquiry");
                    }
                    return;
                }
                
                // Check if trying to change status to "Pending" when there's already a reply
                if ("Pending".equalsIgnoreCase(newStatus) && inquiryDetails.containsKey("Reply") && inquiryDetails.get("Reply") != null && !inquiryDetails.get("Reply").isEmpty()) {
                    if (!isAjax) {
                        response.sendRedirect("InquiryServlet?error=hastreply");
                    } else {
                        sendTextResponse(response, false, "Cannot change status to Pending when a reply exists");
                    }
                    return;
                }
                
                boolean success = false;
                if (replyText != null && !replyText.isEmpty()) {
                    // Update with reply
                    success = updateInquiryWithReply(updateInquiryId, replyText, "Replied");
                } else if (newStatus != null && !newStatus.isEmpty()) {
                    // Just update status
                    success = updateInquiryStatus(updateInquiryId, newStatus);
                }
                
                if (!isAjax) {
                    // Form submission, just redirect without sending text response
                    if (success) {
                        // Successfully updated, redirect to inquiries page
                        response.sendRedirect("InquiryServlet");
                    } else {
                        // Failed to update, redirect with error
                        response.sendRedirect("InquiryServlet?updated=failed");
                    }
                } else {
                    // AJAX call, return JSON response
                    sendTextResponse(response, success, success ? "Inquiry updated successfully" : "Failed to update inquiry");
                }
            } else {
                // Buyers cannot update inquiry status
                if (!isAjax) {
                    response.sendRedirect("InquiryServlet?error=unauthorized");
                } else {
                    sendTextResponse(response, false, "You are not authorized to update inquiry status");
                }
            }
        } else {
            // This is a new inquiry submission
            String carId = request.getParameter("carId");
            String carTitle = request.getParameter("carTitle"); 
            String sellerId = request.getParameter("sellerId");
            String subject = request.getParameter("inquirySubject");
            String message = request.getParameter("inquiryMessage");
            String inquiryName = request.getParameter("inquiryName");
            String inquiryEmail = request.getParameter("inquiryEmail");
            String inquiryPhone = request.getParameter("inquiryPhone");
            
            if (carId == null || subject == null || message == null) {
                if (!isAjax) {
                    // Form submission with missing params
                    response.sendRedirect("view-car.jsp?id=" + (carId != null ? carId : "") + "&error=missing");
                } else {
                    // AJAX call with missing params
                    sendTextResponse(response, false, "Missing required parameters");
                }
                return;
            }
            
            boolean success = false;
            String responseMessage = "";
            
            try {
                // Generate unique inquiry ID
                String inquiryId = "INQ" + generateRandomId();
                
                // Get current date/time
                String inquiryDate = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) + " (UTC)";
                
                // Save inquiry
                Map<String, String> inquiry = new HashMap<>();
                inquiry.put("InquiryId", inquiryId);
                inquiry.put("UserId", userId);
                inquiry.put("CarId", carId);
                inquiry.put("CarTitle", carTitle);
                inquiry.put("SellerId", sellerId);
                inquiry.put("Subject", subject);
                inquiry.put("Message", message);
                inquiry.put("Name", inquiryName);
                inquiry.put("Email", inquiryEmail);
                inquiry.put("Phone", inquiryPhone != null ? inquiryPhone : "");
                inquiry.put("InquiryDate", inquiryDate);
                inquiry.put("Status", "Pending");
                
                success = saveInquiry(inquiry);
                responseMessage = success ? "Inquiry sent successfully" : "Failed to send inquiry";
                
            } catch (Exception e) {
                responseMessage = "Error: " + e.getMessage();
                e.printStackTrace();
            }
            
            if (!isAjax) {
                // Form submission
                if (success) {
                    response.sendRedirect("view-car.jsp?id=" + carId + "&sent=true");
                } else {
                    response.sendRedirect("view-car.jsp?id=" + carId + "&error=failed");
                }
            } else {
                // AJAX call
                sendTextResponse(response, success, responseMessage);
            }
        }
    }
    
    /**
     * Determine if request is an AJAX request
     */
    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        return "XMLHttpRequest".equals(requestedWith);
    }
    
    /**
     * Sends a simple text response
     */
    private void sendTextResponse(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        out.print("success=" + success + ";message=" + message);
        out.flush();
    }
    
    /**
     * Generates a random ID for inquiries
     */
    private String generateRandomId() {
        Random rand = new Random();
        return String.format("%08d", rand.nextInt(100000000));
    }
    
    /**
     * Gets all inquiries for a specific buyer
     */
    private List<Map<String, String>> getUserInquiries(String userId) {
        List<Map<String, String>> inquiries = new ArrayList<>();
        File file = new File(INQUIRIES_FILE);
        
        if (!file.exists()) {
            return inquiries;
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            Map<String, String> currentInquiry = null;
            boolean isRelevantUser = false;
            
            // Skip header lines
            boolean foundFirstInquiry = false;
            
            while ((line = reader.readLine()) != null) {
                if (!foundFirstInquiry && line.startsWith("InquiryId:")) {
                    foundFirstInquiry = true;
                }
                
                if (!foundFirstInquiry && !line.startsWith("InquiryId:")) {
                    continue;
                }
                
                // Empty line, continue
                if (line.trim().isEmpty()) {
                    continue;
                }
                
                // Start of a new inquiry
                if (line.startsWith("InquiryId:")) {
                    // If we were processing an inquiry for the user, add it to the list
                    if (currentInquiry != null && isRelevantUser) {
                        inquiries.add(currentInquiry);
                    }
                    
                    // Reset for new inquiry
                    currentInquiry = new HashMap<>();
                    isRelevantUser = false;
                    
                    String inquiryId = line.substring("InquiryId:".length()).trim();
                    currentInquiry.put("InquiryId", inquiryId);
                } else if (currentInquiry != null) {
                    if (line.startsWith("UserId:")) {
                        String inquiryUserId = line.substring("UserId:".length()).trim();
                        currentInquiry.put("UserId", inquiryUserId);
                        
                        // Check if this inquiry belongs to the user
                        isRelevantUser = inquiryUserId.equals(userId);
                    } else if (line.startsWith("CarId:")) {
                        currentInquiry.put("CarId", line.substring("CarId:".length()).trim());
                    } else if (line.startsWith("CarTitle:")) {
                        currentInquiry.put("CarTitle", line.substring("CarTitle:".length()).trim());
                    } else if (line.startsWith("SellerId:")) {
                        currentInquiry.put("SellerId", line.substring("SellerId:".length()).trim());
                    } else if (line.startsWith("Subject:")) {
                        currentInquiry.put("Subject", line.substring("Subject:".length()).trim());
                    } else if (line.startsWith("Message:")) {
                        currentInquiry.put("Message", line.substring("Message:".length()).trim());
                    } else if (line.startsWith("Name:")) {
                        currentInquiry.put("Name", line.substring("Name:".length()).trim());
                    } else if (line.startsWith("Email:")) {
                        currentInquiry.put("Email", line.substring("Email:".length()).trim());
                    } else if (line.startsWith("Phone:")) {
                        currentInquiry.put("Phone", line.substring("Phone:".length()).trim());
                    } else if (line.startsWith("InquiryDate:")) {
                        currentInquiry.put("InquiryDate", line.substring("InquiryDate:".length()).trim());
                    } else if (line.startsWith("Status:")) {
                        currentInquiry.put("Status", line.substring("Status:".length()).trim());
                    } else if (line.startsWith("Reply:")) {
                        currentInquiry.put("Reply", line.substring("Reply:".length()).trim());
                    } else if (line.startsWith("ReplyDate:")) {
                        currentInquiry.put("ReplyDate", line.substring("ReplyDate:".length()).trim());
                    }
                    
                    // Separator line, finish the current inquiry
                    if (line.startsWith("---------------------------------------")) {
                        if (currentInquiry != null && isRelevantUser) {
                            inquiries.add(currentInquiry);
                            currentInquiry = null;
                            isRelevantUser = false;
                        }
                    }
                }
            }
            
            // Add the last inquiry if it exists and belongs to the user
            if (currentInquiry != null && isRelevantUser) {
                inquiries.add(currentInquiry);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        return inquiries;
    }
    
    /**
     * Gets all inquiries for a specific seller
     */
    private List<Map<String, String>> getSellerInquiries(String sellerId) {
        List<Map<String, String>> inquiries = new ArrayList<>();
        File file = new File(INQUIRIES_FILE);
        
        if (!file.exists()) {
            return inquiries;
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            Map<String, String> currentInquiry = null;
            boolean isRelevantSeller = false;
            
            // Skip header lines
            boolean foundFirstInquiry = false;
            
            while ((line = reader.readLine()) != null) {
                if (!foundFirstInquiry && line.startsWith("InquiryId:")) {
                    foundFirstInquiry = true;
                }
                
                if (!foundFirstInquiry && !line.startsWith("InquiryId:")) {
                    continue;
                }
                
                // Empty line, continue
                if (line.trim().isEmpty()) {
                    continue;
                }
                
                // Start of a new inquiry
                if (line.startsWith("InquiryId:")) {
                    // If we were processing an inquiry for the seller, add it to the list
                    if (currentInquiry != null && isRelevantSeller) {
                        inquiries.add(currentInquiry);
                    }
                    
                    // Reset for new inquiry
                    currentInquiry = new HashMap<>();
                    isRelevantSeller = false;
                    
                    String inquiryId = line.substring("InquiryId:".length()).trim();
                    currentInquiry.put("InquiryId", inquiryId);
                } else if (currentInquiry != null) {
                    if (line.startsWith("SellerId:")) {
                        String inquirySellerId = line.substring("SellerId:".length()).trim();
                        currentInquiry.put("SellerId", inquirySellerId);
                        
                        // Check if this inquiry belongs to the seller
                        isRelevantSeller = inquirySellerId.equals(sellerId);
                    } else if (line.startsWith("UserId:")) {
                        currentInquiry.put("UserId", line.substring("UserId:".length()).trim());
                    } else if (line.startsWith("CarId:")) {
                        currentInquiry.put("CarId", line.substring("CarId:".length()).trim());
                    } else if (line.startsWith("CarTitle:")) {
                        currentInquiry.put("CarTitle", line.substring("CarTitle:".length()).trim());
                    } else if (line.startsWith("Subject:")) {
                        currentInquiry.put("Subject", line.substring("Subject:".length()).trim());
                    } else if (line.startsWith("Message:")) {
                        currentInquiry.put("Message", line.substring("Message:".length()).trim());
                    } else if (line.startsWith("Name:")) {
                        currentInquiry.put("Name", line.substring("Name:".length()).trim());
                    } else if (line.startsWith("Email:")) {
                        currentInquiry.put("Email", line.substring("Email:".length()).trim());
                    } else if (line.startsWith("Phone:")) {
                        currentInquiry.put("Phone", line.substring("Phone:".length()).trim());
                    } else if (line.startsWith("InquiryDate:")) {
                        currentInquiry.put("InquiryDate", line.substring("InquiryDate:".length()).trim());
                    } else if (line.startsWith("Status:")) {
                        currentInquiry.put("Status", line.substring("Status:".length()).trim());
                    } else if (line.startsWith("Reply:")) {
                        currentInquiry.put("Reply", line.substring("Reply:".length()).trim());
                    } else if (line.startsWith("ReplyDate:")) {
                        currentInquiry.put("ReplyDate", line.substring("ReplyDate:".length()).trim());
                    }
                    
                    // Separator line, finish the current inquiry
                    if (line.startsWith("---------------------------------------")) {
                        if (currentInquiry != null && isRelevantSeller) {
                            inquiries.add(currentInquiry);
                            currentInquiry = null;
                            isRelevantSeller = false;
                        }
                    }
                }
            }
            
            // Add the last inquiry if it exists and belongs to the seller
            if (currentInquiry != null && isRelevantSeller) {
                inquiries.add(currentInquiry);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        return inquiries;
    }
    
    /**
     * Get an inquiry by its ID
     */
    private Map<String, String> getInquiryById(String inquiryId) {
        File file = new File(INQUIRIES_FILE);
        
        if (!file.exists() || inquiryId == null) {
            return null;
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            Map<String, String> currentInquiry = null;
            boolean isTargetInquiry = false;
            
            // Skip header lines
            boolean foundFirstInquiry = false;
            
            while ((line = reader.readLine()) != null) {
                if (!foundFirstInquiry && line.startsWith("InquiryId:")) {
                    foundFirstInquiry = true;
                }
                
                if (!foundFirstInquiry && !line.startsWith("InquiryId:")) {
                    continue;
                }
                
                // Empty line, continue
                if (line.trim().isEmpty()) {
                    continue;
                }
                
                // Start of a new inquiry
                if (line.startsWith("InquiryId:")) {
                    // If we finished processing the target inquiry, return it
                    if (currentInquiry != null && isTargetInquiry) {
                        return currentInquiry;
                    }
                    
                    String id = line.substring("InquiryId:".length()).trim();
                    
                    // Check if this is the inquiry we're looking for
                    isTargetInquiry = id.equals(inquiryId);
                    
                    if (isTargetInquiry) {
                        // Reset and start collecting data
                        currentInquiry = new HashMap<>();
                        currentInquiry.put("InquiryId", id);
                    } else {
                        currentInquiry = null;
                    }
                } else if (currentInquiry != null && isTargetInquiry) {
                    // Parse inquiry fields
                    if (line.startsWith("UserId:")) {
                        currentInquiry.put("UserId", line.substring("UserId:".length()).trim());
                    } else if (line.startsWith("CarId:")) {
                        currentInquiry.put("CarId", line.substring("CarId:".length()).trim());
                    } else if (line.startsWith("CarTitle:")) {
                        currentInquiry.put("CarTitle", line.substring("CarTitle:".length()).trim());
                    } else if (line.startsWith("SellerId:")) {
                        currentInquiry.put("SellerId", line.substring("SellerId:".length()).trim());
                    } else if (line.startsWith("Subject:")) {
                        currentInquiry.put("Subject", line.substring("Subject:".length()).trim());
                    } else if (line.startsWith("Message:")) {
                        currentInquiry.put("Message", line.substring("Message:".length()).trim());
                    } else if (line.startsWith("Name:")) {
                        currentInquiry.put("Name", line.substring("Name:".length()).trim());
                    } else if (line.startsWith("Email:")) {
                        currentInquiry.put("Email", line.substring("Email:".length()).trim());
                    } else if (line.startsWith("Phone:")) {
                        currentInquiry.put("Phone", line.substring("Phone:".length()).trim());
                    } else if (line.startsWith("InquiryDate:")) {
                        currentInquiry.put("InquiryDate", line.substring("InquiryDate:".length()).trim());
                    } else if (line.startsWith("Status:")) {
                        currentInquiry.put("Status", line.substring("Status:".length()).trim());
                    } else if (line.startsWith("Reply:")) {
                        currentInquiry.put("Reply", line.substring("Reply:".length()).trim());
                    } else if (line.startsWith("ReplyDate:")) {
                        currentInquiry.put("ReplyDate", line.substring("ReplyDate:".length()).trim());
                    }
                    
                    // Separator line, finish the current inquiry
                    if (line.startsWith("---------------------------------------")) {
                        return currentInquiry;
                    }
                }
            }
            
            // If we get to the end of the file and have an inquiry, return it
            if (currentInquiry != null && isTargetInquiry) {
                return currentInquiry;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Updates just the status of an inquiry
     */
    private boolean updateInquiryStatus(String inquiryId, String newStatus) {
        File file = new File(INQUIRIES_FILE);
        
        if (!file.exists() || inquiryId == null || newStatus == null) {
            return false;
        }
        
        List<String> fileLines = new ArrayList<>();
        boolean updated = false;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            boolean inTargetInquiry = false;
            
            while ((line = reader.readLine()) != null) {
                // Check if we found the target inquiry
                if (line.startsWith("InquiryId:") && line.substring("InquiryId:".length()).trim().equals(inquiryId)) {
                    inTargetInquiry = true;
                }
                
                // Update the status if we're in the target inquiry
                if (inTargetInquiry && line.startsWith("Status:")) {
                    fileLines.add("Status: " + newStatus);
                    updated = true;
                } else {
                    fileLines.add(line);
                }
                
                // End of this inquiry
                if (line.startsWith("---------------------------------------")) {
                    inTargetInquiry = false;
                }
            }
            
            // Write the updated file if we found and updated the inquiry
            if (updated) {
                try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
                    for (String fileLine : fileLines) {
                        writer.write(fileLine);
                        writer.newLine();
                    }
                }
                return true;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Updates an inquiry with a reply and changes status
     */
    private boolean updateInquiryWithReply(String inquiryId, String replyText, String newStatus) {
        File file = new File(INQUIRIES_FILE);
        
        if (!file.exists() || inquiryId == null || replyText == null) {
            return false;
        }
        
        List<String> fileLines = new ArrayList<>();
        boolean updated = false;
        boolean hasReplyField = false;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            boolean inTargetInquiry = false;
            
            while ((line = reader.readLine()) != null) {
                // Check if we found the target inquiry
                if (line.startsWith("InquiryId:") && line.substring("InquiryId:".length()).trim().equals(inquiryId)) {
                    inTargetInquiry = true;
                }
                
                // Handle the line based on the field
                if (inTargetInquiry) {
                    if (line.startsWith("Reply:")) {
                        fileLines.add("Reply: " + replyText);
                        hasReplyField = true;
                        updated = true;
                        continue;
                    } else if (line.startsWith("ReplyDate:")) {
                        String currentDateTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) + " (UTC)";
                        fileLines.add("ReplyDate: " + currentDateTime);
                        continue;
                    } else if (line.startsWith("Status:") && newStatus != null) {
                        fileLines.add("Status: " + newStatus);
                        updated = true;
                        
                        // If we've updated the status but haven't seen a Reply field yet,
                        // add the reply fields after the status
                        if (!hasReplyField) {
                            String currentDateTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) + " (UTC)";
                            fileLines.add("Reply: " + replyText);
                            fileLines.add("ReplyDate: " + currentDateTime);
                            hasReplyField = true;
                        }
                        
                        continue;
                    }
                }
                
                fileLines.add(line);
                
                // End of this inquiry, check if we need to add reply fields
                if (inTargetInquiry && line.startsWith("---------------------------------------")) {
                    // If we haven't added a reply field and need to, add it before the separator
                    if (!hasReplyField) {
                        // Remove the separator line since we've already added it
                        fileLines.remove(fileLines.size() - 1);
                        
                        String currentDateTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) + " (UTC)";
                        fileLines.add("Reply: " + replyText);
                        fileLines.add("ReplyDate: " + currentDateTime);
                        if (newStatus != null) {
                            fileLines.add("Status: " + newStatus);
                        }
                        fileLines.add("---------------------------------------");
                        updated = true;
                    }
                    
                    inTargetInquiry = false;
                }
            }
            
            // Write the updated file if we found and updated the inquiry
            if (updated) {
                try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
                    for (String fileLine : fileLines) {
                        writer.write(fileLine);
                        writer.newLine();
                    }
                }
                return true;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Saves an inquiry to the file
     */
    private boolean saveInquiry(Map<String, String> inquiry) throws IOException {
        File file = new File(INQUIRIES_FILE);
        
        // Create directories if they don't exist
        File parent = file.getParentFile();
        if (!parent.exists()) {
            parent.mkdirs();
        }
        
        boolean fileExists = file.exists();
        
        try (FileWriter fw = new FileWriter(file, fileExists); 
             BufferedWriter writer = new BufferedWriter(fw)) {
            
            if (!fileExists) {
                // If file is new, write header
                writer.write("Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): " + 
                             LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                writer.newLine();
                writer.write("Current User's Login: " + inquiry.get("UserId"));
                writer.newLine();
            }
            
            // Write inquiry data
            writer.write("InquiryId: " + inquiry.get("InquiryId"));
            writer.newLine();
            writer.write("UserId: " + inquiry.get("UserId"));
            writer.newLine();
            writer.write("CarId: " + inquiry.get("CarId"));
            writer.newLine();
            writer.write("CarTitle: " + inquiry.get("CarTitle"));
            writer.newLine();
            writer.write("SellerId: " + inquiry.get("SellerId"));
            writer.newLine();
            writer.write("Subject: " + inquiry.get("Subject"));
            writer.newLine();
            writer.write("Message: " + inquiry.get("Message"));
            writer.newLine();
            writer.write("Name: " + inquiry.get("Name"));
            writer.newLine();
            writer.write("Email: " + inquiry.get("Email"));
            writer.newLine();
            writer.write("Phone: " + inquiry.get("Phone"));
            writer.newLine();
            writer.write("InquiryDate: " + inquiry.get("InquiryDate"));
            writer.newLine();
            writer.write("Status: " + inquiry.get("Status"));
            writer.newLine();
            
            // Add reply fields if they exist
            if (inquiry.containsKey("Reply") && inquiry.get("Reply") != null && !inquiry.get("Reply").isEmpty()) {
                writer.write("Reply: " + inquiry.get("Reply"));
                writer.newLine();
                writer.write("ReplyDate: " + inquiry.get("ReplyDate"));
                writer.newLine();
            }
            
            writer.write("---------------------------------------");
            writer.newLine();
        }
        
        return true;
    }
}