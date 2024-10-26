const Driver = require('../models/driverModel');
const Wholeseller = require('../models/wholesellerModel');
const nodemailer = require('nodemailer');
const bcrypt = require('bcrypt');


//register wholesellers and truckdrivers

exports.createUser = async (req, res) => {
  const { name, email, password, address, vehicleType, licenseExpiryDate, role } = req.body;
  
  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    if (role === 'driver') {
      const newDriver = new Driver({
        name,
        email,
        role: 'driver',
        password: hashedPassword,
        address,
        vehicleType,
        licenseExpiryDate,
      });

      await newDriver.save();
      res.status(201).json({message: 'Signup successful',userId: newDriver._id,role: newDriver.role,
      });

    }else if (role === 'wholeseller') {
      const newWholeseller = new Wholeseller({
        name,
        email,
        address,
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
    driver.licenseExpiryDate = licenseExpiryDate || driver.licenseExpiryDate;

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

// Update the delete account function
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
    console.error(error);
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

// Get user profile details (Driver or Wholeseller)
exports.getWholesellerProfile = async (req, res) => {
  const { userId } = req.params;
  try {
    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) {
      return res.status(404).json({ message: 'Wholeseller not found' });
    }
    res.json({ user: wholeseller });
  } catch (err) {
    res.status(500).json({ message: 'Error fetching profile', error: err.message });
  }
};

exports.getDriverProfile = async (req, res) => {
  const { userId } = req.params;
  try {
    const driver = await Driver.findById(userId);
    if (!driver) {
      return res.status(404).json({ message: 'Driver not found' });
    }
    res.json({ user: driver });
  } catch (err) {
    res.status(500).json({ message: 'Error fetching profile', error: err.message });
  }
};

// Update profile photo for driver or wholeseller
exports.updateProfilePhoto = async (req, res) => {
  const { userId } = req.params; 
  const { photo } = req.body; 

  try {
    
    const driver = await Driver.findById(userId);
    const wholeseller = await Wholeseller.findById(userId);

    let user = driver || wholeseller;
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Update the user's photo field with the base64 string
    user.photo = photo;
    await user.save();

    // Send a success response with the updated user data
    res.status(200).json({
    message: 'Profile photo updated successfully',
    user: {
      _id: user._id,
      name: user.name,
      email: user.email,
      photo: user.photo,  
    }
  });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: 'Error updating profile photo',
      error: error.message,
    });
  }
};

