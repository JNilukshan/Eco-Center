const Driver = require('../models/driverModel');
const Wholeseller = require('../models/wholesellerModel');
const nodemailer = require('nodemailer');
const bcrypt = require('bcrypt');
const path = require('path');
const fs = require('fs');  

//register wholesellers and truckdrivers

exports.createUser = async (req, res) => {
  const { name, email, password, address,phone, vehicleType, vehicalnumber, role } = req.body;
  
  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    if (role === 'driver') {
      const newDriver = new Driver({
        name,
        email,
        role: 'driver',
        password: hashedPassword,
        address,
        phone,
        vehicleType,
        vehicalnumber,
      });

      await newDriver.save();
      res.status(201).json({message: 'Signup successful',userId: newDriver._id,role: newDriver.role,
      });

    }else if (role === 'wholeseller') {
      const newWholeseller = new Wholeseller({
        name,
        email,
        address,
        phone,
        role: 'wholeseller',
        password: hashedPassword,
      });

      await newWholeseller.save();
      res.status(201).json({message: 'Signup successful',userId: newWholeseller._id, role: newWholeseller.role, 
      });

    } else {
      return res.status(400).json({ message: 'Invalid role provided' });
    }
    
  } catch (error) {
    res.status(500).json({ message: 'Error creating user', error: error.message });
  }
};

//login wholeseller and driver
exports.login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const wholeseller = await Wholeseller.findOne({ email });
    const driver = await Driver.findOne({ email });

    let user = wholeseller || driver;

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    res.status(200).json({
      message: 'Login successful',
      userId: user._id,
      role: user.role   
    });
    
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error logging in' });
  }
};

//update wholeseller and driver
exports.updateWholeseller = async (req, res) => {
  const { userId } = req.params;
  const { name, role, address, email, password } = req.body;

  try {
    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) {
      return res.status(404).json({ message: 'Wholeseller not found' });
    }

    wholeseller.name = name || wholeseller.name;
    wholeseller.role = role || wholeseller.role;
    wholeseller.address = address || wholeseller.address;
    wholeseller.email = email || wholeseller.email;

    if (password) {
      wholeseller.password = await bcrypt.hash(password, 10);
    }

    await wholeseller.save();
    res.json({ message: 'User updated successfully', user: wholeseller });
  } catch (err) {
    console.error('Error updating wholeseller:', err);
    res.status(500).json({message: 'Error updating wholeseller',error: err.message});
  }
};

exports.updateDriver = async (req, res) => {
  const { userId } = req.params;
  const { name, email, password, address, role, vehicleType, licenseExpiryDate } = req.body;

  try {
    const driver = await Driver.findById(userId);
    if (!driver) {
      return res.status(404).json({ message: 'Driver not found' });
    }

    driver.name = name || driver.name;
    driver.email = email || driver.email;
    driver.address = address || driver.address;
    driver.role = role || driver.role;
    driver.vehicleType = vehicleType || driver.vehicleType;
    driver.vehicalnumber = vehicalnumber || driver.vehicalnumber;

    if (password) {
      driver.password = await bcrypt.hash(password, 10);
    }

    await driver.save();
    res.json({ message: 'User updated successfully', user: driver });
  } catch (err) {
    res.status(500).json({ message: 'Error updating driver', error: err.message });
  }
};


//logout
exports.logout = async (req, res) => {
  try {
    // Clear the session if it exists
    if (req.session) {
      req.session.destroy((err) => {
        if (err) {
          console.error("Failed to destroy session:", err);
          return res.status(500).json({ message: "Failed to log out" });
        }
      });
    }

    // Clear any cookies
    res.clearCookie('connect.sid');
    
    res.status(200).json({ message: "Logged out successfully" });
  } catch (error) {
    console.error("Error during logout:", error);
    res.status(500).json({ message: "Error during logout", error: error.message });
  }
};

// delete account 
exports.deleteAccount = async (req, res) => {
  const { userId, role } = req.body;

  try {
    let result;
    if (role === 'driver') {
      result = await Driver.findByIdAndDelete(userId);
    } else if (role === 'wholeseller') {
      result = await Wholeseller.findByIdAndDelete(userId);
    } else {
      return res.status(400).json({ message: 'Invalid user role' });
    }

    if (!result) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Clear session if it exists
    if (req.session) {
      req.session.destroy();
    }

    res.status(200).json({ message: 'Account successfully deleted' });
  } catch (error) {
    console.error("Error deleting account:", error);
    res.status(500).json({ message: 'Error deleting account', error: error.message });
  }
};



// Configure Nodemailer for sending OTPs
const transporter = nodemailer.createTransport({
  service: 'gmail',
  host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
  tls: {
    rejectUnauthorized: false,
  },
});



//send otp to email
exports.sendOtp = async (req, res) => {
  const { email } = req.body;

  try {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    const wholeseller = await Wholeseller.findOne({ email });
    const driver = await Driver.findOne({ email });

    if (!wholeseller && !driver) {
      return res.status(404).json({ message: 'Email not found' });
    }

    if (wholeseller) {
      wholeseller.otp = otp;
      await wholeseller.save();
    } else {
      driver.otp = otp;
      await driver.save();
    }

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Your OTP for Password Reset',
      text: `Your OTP is ${otp}. Please use it to reset your password.`,
    };

    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: 'OTP sent to your email.' });
  } catch (error) {
    console.error("Error sending OTP:", error);
    res.status(500).json({ message: 'Error sending OTP' });
  }
};

//veryfi otp
exports.verifyOtp = async (req, res) => {
  const { email, otp } = req.body;

  try {
    const wholeseller = await Wholeseller.findOne({ email });
    const driver = await Driver.findOne({ email });

    if (wholeseller && wholeseller.otp === otp) {
      return res.status(200).json({ message: 'OTP verified', userType: 'wholeseller' });
    }
    if (driver && driver.otp === otp) {
      return res.status(200).json({ message: 'OTP verified', userType: 'driver' });
    }

    res.status(400).json({ message: 'Invalid OTP' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error verifying OTP', error });
  }
};

//reset password
exports.resetPassword = async (req, res) => {
  const { email, newPassword } = req.body;

  try {
    const wholeseller = await Wholeseller.findOne({ email });
    const driver = await Driver.findOne({ email });

    let user = wholeseller || driver;

    if (!user) {
      return res.status(404).json({ message: 'Email not found' });
    }

    user.password = await bcrypt.hash(newPassword, 10);
    user.otp = null;
    await user.save();

    res.status(200).json({ message: 'Password has been reset successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error resetting password' });
  }
};

//getDriverProfile and getWholesellerProfile 
exports.getDriverProfile = async (req, res) => {
  const { userId } = req.params;
  try {
    const driver = await Driver.findById(userId);
    if (!driver) {
      return res.status(404).json({ message: 'Driver not found' });
    }
    
    const photoUrl = driver.photo 
      ? `${process.env.BASE_URL}/uploads/profile-photos/${driver.photo}`
      : null;

    res.json({ 
      user: {
        ...driver.toObject(),
        photoUrl
      }
    });
  } catch (err) {
    res.status(500).json({ message: 'Error fetching profile', error: err.message });
  }
};

exports.getWholesellerProfile = async (req, res) => {
  const { userId } = req.params;
  try {
    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) {
      return res.status(404).json({ message: 'Wholeseller not found' });
    }

    const photoUrl = wholeseller.photo 
      ? `${process.env.BASE_URL}/uploads/profile-photos/${wholeseller.photo}`
      : null;

    res.json({ 
      user: {
        ...wholeseller.toObject(),
        photoUrl
      }
    });
  } catch (err) {
    res.status(500).json({ message: 'Error fetching profile', error: err.message });
  }
};


// Update profile photo for driver or wholeseller
exports.updateProfilePhoto = async (req, res) => {
  try {
    if (!req.files || !req.files.photo) {
      return res.status(400).json({ message: 'No photo uploaded' });
    }

    const { userId } = req.params;
    const photoFile = req.files.photo;

    // Validate file type
    const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
    if (!allowedTypes.includes(photoFile.mimetype)) {
      return res.status(400).json({ 
        message: 'Invalid file type. Only JPG, JPEG and PNG allowed' 
      });
    }

    // Validate file size (5MB max)
    const maxSize = 5 * 1024 * 1024; // 5MB in bytes
    if (photoFile.size > maxSize) {
      return res.status(400).json({ 
        message: 'File too large. Maximum size is 5MB' 
      });
    }

    // Find user
    const driver = await Driver.findById(userId);
    const wholeseller = await Wholeseller.findById(userId);
    const user = driver || wholeseller;

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Create uploads directory if it doesn't exist
    const uploadsDir = path.join(__dirname, '../uploads/profile-photos');
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }

    // Generate unique filename
    const fileName = `${userId}-${Date.now()}${path.extname(photoFile.name)}`;
    const filePath = path.join(uploadsDir, fileName);

    // Delete old photo if it exists
    if (user.photo) {
      const oldPhotoPath = path.join(uploadsDir, user.photo);
      if (fs.existsSync(oldPhotoPath)) {
        fs.unlinkSync(oldPhotoPath);
      }
    }

    // Save new photo
    await photoFile.mv(filePath);

    // Update user's photo field with filename
    user.photo = fileName;
    await user.save();

    // Send success response with file path
    res.status(200).json({
      message: 'Profile photo updated successfully',
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        photo: fileName
      }
    });

  } catch (error) {
    console.error('Error updating profile photo:', error);
    res.status(500).json({
      message: 'Error updating profile photo',
      error: error.message
    });
  }
};


//fetch driver details
exports.getAvailableDrivers = async (req, res) => {
  try {
    const drivers = await Driver.find({}, 'name vehicleType phone address photoUrl');
    res.status(200).json(drivers);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching drivers', error });
  }
};




