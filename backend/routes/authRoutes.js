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
  logout,
  deleteAccount
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
router.get('/profile/wholeseller/:userId', getWholesellerProfile);  // Corrected to router.get
router.get('/profile/driver/:userId', getDriverProfile);            // Corrected to router.get

// Define route for updating profile photo
router.put('/profile/photo/:userId', updateProfilePhoto);

// Define route for logout
router.post('/logout', logout);

router.delete('/delete-account', deleteAccount);

module.exports = router;
