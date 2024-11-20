const express = require('express');
const router = express.Router();
const { getNotifications, deleteNotification, createNotification } = require('../controllers/notificationController');

// Route to create a notification
router.post('/createNotification', createNotification);

// Route to fetch notifications for a specific user
router.get('/getNotifications/:userId', getNotifications);

// Route to delete a specific notification
router.delete('/deleteNotification/:userId/:id', deleteNotification);

module.exports = router;
