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
  updateDriverAvailability,  // Add this line
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

router.put('/profile/photo/:userId', updateProfilePhoto);

// Delete account
router.delete('/delete-account', deleteAccount);

// Get driver details
router.get('/drivers', getAvailableDrivers);

// Update driver availability
router.patch('/drivers/:driverId', updateDriverAvailability);  // Add this line

module.exports = router;
