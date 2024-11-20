//const express = require('express');
// const router = express.Router();
// const paymentController = require('../controllers/paymentController');

// router.post('/create-checkout-session', paymentController.createCheckoutSession);
// router.post('/notification/createNotification/:userId', paymentController.createNotification);

// module.exports = router;

const express = require('express');
const router = express.Router();
const { processPayment } = require('../controllers/paymentController');

// Route to handle payment
router.post('/processPayment', processPayment);

module.exports = router;
