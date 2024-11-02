// authController.js

const Driver = require('../models/driverModel');
const Wholeseller = require('../models/wholesellerModel');
const nodemailer = require('nodemailer');
const bcrypt = require('bcrypt');
const path = require('path');
const fs = require('fs');

// Register wholesellers and truck drivers
exports.createUser = async (req, res) => {
  const { name, email, password, address, phone, vehicleType, vehicalnumber, role } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    if (role === 'driver') {
      const newDriver = new Driver({ name, email, role: 'driver', password: hashedPassword, address, phone, vehicleType, vehicalnumber });
      await newDriver.save();
      res.status(201).json({ message: 'Signup successful', userId: newDriver._id, role: newDriver.role });
    } else if (role === 'wholeseller') {
      const newWholeseller = new Wholeseller({ name, email, address, phone, role: 'wholeseller', password: hashedPassword });
      await newWholeseller.save();
      res.status(201).json({ message: 'Signup successful', userId: newWholeseller._id, role: newWholeseller.role });
    } else {
      res.status(400).json({ message: 'Invalid role provided' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error creating user', error: error.message });
  }
};

// Login for wholeseller and driver
exports.login = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await Wholeseller.findOne({ email }) || await Driver.findOne({ email });
    if (!user) return res.status(404).json({ message: 'User not found' });
    
    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ message: 'Invalid credentials' });

    res.status(200).json({ message: 'Login successful', userId: user._id, role: user.role });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error logging in' });
  }
};

// Update wholeseller and driver profiles
exports.updateWholeseller = async (req, res) => {
  const { userId } = req.params;
  const { name, address, email, password } = req.body;

  try {
    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) return res.status(404).json({ message: 'Wholeseller not found' });

    wholeseller.name = name || wholeseller.name;
    wholeseller.address = address || wholeseller.address;
    wholeseller.email = email || wholeseller.email;
    if (password) wholeseller.password = await bcrypt.hash(password, 10);

    await wholeseller.save();
    res.json({ message: 'User updated successfully', user: wholeseller });
  } catch (error) {
    console.error('Error updating wholeseller:', error);
    res.status(500).json({ message: 'Error updating wholeseller', error: error.message });
  }
};

exports.updateDriver = async (req, res) => {
  const { userId } = req.params;
  const { name, email, password, address } = req.body;

  try {
    const driver = await Driver.findById(userId);
    if (!driver) return res.status(404).json({ message: 'Driver not found' });

    driver.name = name || driver.name;
    driver.email = email || driver.email;
    driver.address = address || driver.address;
    if (password) driver.password = await bcrypt.hash(password, 10);

    await driver.save();
    res.json({ message: 'User updated successfully', user: driver });
  } catch (error) {
    res.status(500).json({ message: 'Error updating driver', error: error.message });
  }
};

// Fetch wholeseller profile
exports.getWholesellerProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) return res.status(404).json({ message: 'Wholeseller not found' });
    res.status(200).json(wholeseller);
  } catch (error) {
    console.error('Error fetching wholeseller profile:', error);
    res.status(500).json({ message: 'Error fetching wholeseller profile' });
  }
};

// Fetch driver profile
// In authController.js
exports.getDriverProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const driver = await Driver.findById(userId);
    if (!driver) return res.status(404).json({ message: 'Driver not found' });
    
    // Ensure photo field is included in the response
    res.status(200).json({
      name: driver.name,
      email: driver.email,
      address: driver.address,
      vehicleType: driver.vehicleType,
      phone: driver.phone,
      photo: driver.photo, // Send photo URL
    });
  } catch (error) {
    console.error('Error fetching driver profile:', error);
    res.status(500).json({ message: 'Error fetching driver profile' });
  }
};


// Delete account
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
    if (!result) return res.status(404).json({ message: 'User not found' });
    res.status(200).json({ message: 'Account successfully deleted' });
  } catch (error) {
    console.error("Error deleting account:", error);
    res.status(500).json({ message: 'Error deleting account', error: error.message });
  }
};





// Send OTP to email
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: { user: process.env.EMAIL_USER, pass: process.env.EMAIL_PASSWORD },
  tls: { rejectUnauthorized: false },
});

exports.sendOtp = async (req, res) => {
  const { email } = req.body;
  try {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const user = await Wholeseller.findOne({ email }) || await Driver.findOne({ email });
    if (!user) return res.status(404).json({ message: 'Email not found' });

    user.otp = otp;
    await user.save();

    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Your OTP for Password Reset',
      text: `Your OTP is ${otp}. Please use it to reset your password.`,
    });

    res.status(200).json({ message: 'OTP sent to your email.' });
  } catch (error) {
    console.error("Error sending OTP:", error);
    res.status(500).json({ message: 'Error sending OTP' });
  }
};

// Verify OTP
exports.verifyOtp = async (req, res) => {
  const { email, otp } = req.body;
  try {
    const user = await Wholeseller.findOne({ email }) || await Driver.findOne({ email });
    if (user && user.otp === otp) {
      return res.status(200).json({ message: 'OTP verified', userType: user.role });
    }
    res.status(400).json({ message: 'Invalid OTP' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error verifying OTP', error });
  }
};

// Reset password
exports.resetPassword = async (req, res) => {
  const { email, newPassword } = req.body;
  try {
    const user = await Wholeseller.findOne({ email }) || await Driver.findOne({ email });
    if (!user) return res.status(404).json({ message: 'Email not found' });

    user.password = await bcrypt.hash(newPassword, 10);
    user.otp = null;
    await user.save();

    res.status(200).json({ message: 'Password has been reset successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error resetting password' });
  }
};

// Update Profile Photo
// authController.js

exports.updateProfilePhoto = async (req, res) => {
  try {
    if (!req.files || !req.files.photo) {
      return res.status(400).json({ message: 'No photo uploaded' });
    }

    const { userId } = req.params;
    const photoFile = req.files.photo;
    const allowedExtensions = ['.jpg', '.jpeg', '.png'];
    const fileExtension = path.extname(photoFile.name).toLowerCase();

    if (!allowedExtensions.includes(fileExtension)) {
      return res.status(400).json({
        message: 'Invalid file extension. Only .jpg, .jpeg, and .png allowed',
      });
    }

    const maxSize = 7 * 1024 * 1024;
    if (photoFile.size > maxSize) {
      return res.status(400).json({ message: 'File too large. Maximum size is 7MB' });
    }

    const uploadsDir = path.join(__dirname, '../uploads/profile-photos');
    if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });

    const fileName = `${userId}-${Date.now()}${fileExtension}`;
    const filePath = path.join(uploadsDir, fileName);

    await photoFile.mv(filePath);

    // Check and update the user (either Driver or Wholeseller)
    let user = await Driver.findById(userId);
    if (!user) {
      user = await Wholeseller.findById(userId);
    }
    
    if (user) {
      user.photo = fileName; // Update the photo field in the database
      await user.save();
      return res.status(200).json({
        message: 'Profile photo updated successfully',
        photoUrl: fileName,
      });
    } else {
      return res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error('Error updating profile photo:', error);
    res.status(500).json({ message: 'Error updating profile photo', error: error.message });
  }
};


// Fetch driver details
exports.getAvailableDrivers = async (req, res) => {
  try {
    const drivers = await Driver.find({}, 'name vehicleType phone address photo');
    res.status(200).json(drivers);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching drivers', error });
  }
};
