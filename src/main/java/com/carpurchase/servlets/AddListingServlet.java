package com.carpurchase.servlets;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import com.carpurchase.model.Car;
import com.carpurchase.model.CarListManager;

/**
 * Servlet implementation class AddListingServlet
 * Handles the addition of new car listings using a LinkedList-based data structure
 * with file uploads to a fixed physical path
 */
@WebServlet("/AddListingServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class AddListingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Define a fixed physical location for car image uploads
    // This should be changed to match your server's directory structure
    private static final String UPLOAD_ROOT_PATH = "E:\\Exam-Result Management System\\Car_Purchase System\\src\\main\\webapp";
    private static final String UPLOAD_DIRECTORY = "car_images";
    
    // Counter for image naming
    private static int imageCounter = 1;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddListingServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            System.out.println("==== ADD LISTING PROCESSING STARTED ====");
            
            // Get current date time for logging
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String currentDateTime = sdf.format(new Date());
            System.out.println("Process started at: " + currentDateTime);
            
            // Check if user is logged in and is a seller
            HttpSession session = request.getSession();
            String username = (String) session.getAttribute("username");
            String userRole = (String) session.getAttribute("userRole");
            
            if (username == null || !userRole.equalsIgnoreCase("seller")) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Create a new Car object
            String listingId = request.getParameter("listingId");
            if (listingId == null || listingId.trim().isEmpty()) {
                listingId = "CAR" + System.currentTimeMillis();
            }
            
            // Reset image counter for each new car listing
            imageCounter = 1;
            
            Car car = new Car(listingId);
            
            // Basic Information
            String make = request.getParameter("make");
            if (make.equals("Other")) {
                make = request.getParameter("otherMake");
            }
            car.setMake(make);
            car.setModel(request.getParameter("model"));
            car.setYear(Integer.parseInt(request.getParameter("year")));
            car.setBodyType(request.getParameter("bodyType"));
            car.setCondition(request.getParameter("condition"));
            car.setTrim(request.getParameter("trim"));
            car.setVin(request.getParameter("vin"));
            
            // Vehicle Details
            car.setMileage(Integer.parseInt(request.getParameter("mileage")));
            car.setExteriorColor(request.getParameter("exteriorColor"));
            car.setInteriorColor(request.getParameter("interiorColor"));
            car.setTransmission(request.getParameter("transmission"));
            car.setFuelType(request.getParameter("fuelType"));
            car.setDoors(request.getParameter("doors"));
            car.setDriveType(request.getParameter("driveType"));
            car.setEngine(request.getParameter("engine"));
            
            // Listing Details
            car.setTitle(request.getParameter("title"));
            car.setPrice(Double.parseDouble(request.getParameter("price")));
            car.setDescription(request.getParameter("description"));
            
            // Features
            String[] featuresArray = request.getParameterValues("features");
            if (featuresArray != null) {
                car.setFeatures(new ArrayList<>(Arrays.asList(featuresArray)));
            }
            
            String otherFeatures = request.getParameter("otherFeatures");
            if (otherFeatures != null && !otherFeatures.trim().isEmpty()) {
                String[] otherFeaturesArray = otherFeatures.split(",");
                for (String feature : otherFeaturesArray) {
                    car.addFeature(feature.trim());
                }
            }
            
            // Process and save uploaded photos
            List<String> photoUrls = new ArrayList<>();
            Collection<Part> parts = request.getParts();
            boolean hasPhotos = false;
            
            for (Part part : parts) {
                if (part.getName().equals("photos") && part.getSize() > 0) {
                    hasPhotos = true;
                    String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                    String photoPath = uploadFile(part, fileName, listingId);
                    photoUrls.add(photoPath);
                    System.out.println("Uploaded photo: " + photoPath);
                }
            }
            
            // If no photos were uploaded, use default placeholders
            if (!hasPhotos) {
                photoUrls.add("car_images/default1.jpg");
                photoUrls.add("car_images/default2.jpg");
                System.out.println("No photos uploaded, using default placeholders");
            }
            
            car.setPhotos(photoUrls);
            
            // Contact Information
            car.setSellerId(request.getParameter("sellerId"));
            car.setContactName(request.getParameter("contactName"));
            car.setContactEmail(request.getParameter("contactEmail"));
            car.setContactPhone(request.getParameter("contactPhone"));
            car.setLocation(request.getParameter("location"));
            car.setListingDate(request.getParameter("listingDate"));
            car.setStatus("Active");
            
            // Add the car to the car list (LinkedList implementation)
            CarListManager carListManager = new CarListManager();
            carListManager.addCar(car);
            
            System.out.println("Car listing added successfully: " + car.getId());
            System.out.println("Process completed at: " + sdf.format(new Date()));
            System.out.println("==== ADD LISTING PROCESSING COMPLETED ====");
            
            // Redirect to success page with the listing ID
            response.sendRedirect("listing-success.jsp?id=" + listingId);
            
        } catch (Exception e) {
            System.err.println("Error in AddListingServlet: " + e.getMessage());
            e.printStackTrace();
            log("Error in AddListingServlet", e);
            response.sendRedirect("add-listing.jsp?error=system");
        } finally {
            out.close();
        }
    }
    
    /**
     * Handles file uploads for car images with sequential naming
     * 
     * @param part The file part from the multipart request
     * @param fileName Original filename of the uploaded file
     * @param listingId The listing ID to associate with the image
     * @return The path to the saved file
     */
    private String uploadFile(Part part, String fileName, String listingId) throws Exception {
        // Create the upload directory if it doesn't exist
        String uploadPath = UPLOAD_ROOT_PATH + File.separator + UPLOAD_DIRECTORY;
        
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
            System.out.println("Created upload directory: " + uploadPath);
        }
        
        // Get file extension
        String fileExtension = "";
        int i = fileName.lastIndexOf('.');
        if (i > 0) {
            fileExtension = fileName.substring(i);
        }
        
        // Create sequential name: carImg1, carImg2, etc.
        String newFileName = "carImg" + imageCounter + fileExtension;
        String filePath = uploadPath + File.separator + newFileName;
        
        // Check if file already exists, if so, add unique identifier
        File file = new File(filePath);
        if (file.exists()) {
            // If file exists with same name, add a timestamp to ensure uniqueness
            String timestamp = String.valueOf(System.currentTimeMillis()).substring(8);
            newFileName = "carImg" + imageCounter + "_" + timestamp + fileExtension;
            filePath = uploadPath + File.separator + newFileName;
        }
        
        // Save the file
        part.write(filePath);
        System.out.println("File saved to: " + filePath);
        
        // Increment counter for next image
        imageCounter++;
        
        // Return the relative path to be stored in the database
        return UPLOAD_DIRECTORY + "/" + newFileName;
    }
}