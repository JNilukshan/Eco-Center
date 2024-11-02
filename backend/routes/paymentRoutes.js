const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');

router.post('/create-checkout-session', paymentController.createCheckoutSession);
// router.post('/notification/createNotification/:userId', paymentController.createNotification);

module.exports = router;