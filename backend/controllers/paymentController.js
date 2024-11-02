const cors = require('cors');
require('dotenv').config(); // Load environment variables from .env file
const stripe = require('stripe')('sk_test_51QFpqSF5Av59QJJjF9CTBiPZB7WIwbwOR6hP8oRxsedHrS53nGVeQ90bSRuc4Bz4drFXkcyVuQDTdIBFp7fO0vfT00SUgrLjDR'); // Initialize Stripe with the secret key

// Placeholder for notification and booking models (if needed in the future)
// const Notification = require("../models/notificationSchema");
// const Booking = require("../models/bookingSchema");

exports.createCheckoutSession = async (req, res) => {
    const { netTotal } = req.body;
  
    if (!netTotal || typeof netTotal !== 'number') {
      return res.status(400).json({ error: "Invalid netTotal amount" });
    }
  
    try {
      // Create a checkout session with Stripe
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        line_items: [
          {
            price_data: {
              currency: 'usd',
              product_data: {
                name: 'Total Invoice Amount',
              },
              unit_amount: netTotal * 100, // Stripe expects the amount in cents
            },
            quantity: 1,
          },
        ],
        mode: 'payment',
        success_url: "http://localhost:5173/paymentSuccess", // Redirect on success
        cancel_url: "http://localhost:5173/paymentcancel", // Redirect on cancel
      });
  
      // Send the session ID back to the client
      res.json({ id: session.id });
    } catch (error) {
      console.error("Error creating checkout session:", error);
      res.status(500).json({ error: "Error creating checkout session" });
    }
  };


// exports.createNotification = async (req, res) => {
//   const { userId } = req.params;
//   const { mechanicId, bookingId, topic, message } = req.body;

//   try {
//     const newNotification = new Notification({
//       topic,
//       message,
//       recieverId: userId,
//       mechanicId: mechanicId,
//       bookingId: bookingId,
//     });
//     await newNotification.save();
//     return res.status(201).json({
//       status: "SUCCESS",
//       message: "Notification created successfully",
//     });
//   } catch (error) {
//     console.error(error);
//     return res.status(500).json({
//       status: "FAILED",
//       message: "An error occurred while creating notification",
//     });
//   }
// };