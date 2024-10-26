const express = require('express');
const {
  updateDriver,
  updateWholeseller,
  sendOtp,
  verifyOtp,
  resetPassword,
  login,
  createUser,
  getWholesellerProfile,
  getDriverProfile,
  updateProfilePhoto,
  deleteAccount,
  getAvailableDrivers,
} = require('../controllers/authController');

const router = express.Router();

// Define routes for authentication
router.post('/forgot-password', sendOtp);
router.post('/send-otp', sendOtp);
router.post('/verify-otp', verifyOtp);
router.post('/reset-password', resetPassword);
router.post('/login', login);
router.post('/create', createUser);

// Define routes for profile updates
router.put('/update/driver/:userId', updateDriver);
router.put('/update/wholeseller/:userId', updateWholeseller);

// Define routes for profile retrieval
router.get('/profile/wholeseller/:userId', getWholesellerProfile);  
router.get('/profile/driver/:userId', getDriverProfile);            

// Define route for updating profile photo
router.put('/profile/photo/:userId', updateProfilePhoto);

//delete account
router.delete('/delete-account', deleteAccount);

//get driver details
router.get('/drivers',getAvailableDrivers);

module.exports = router;
