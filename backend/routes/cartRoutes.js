const express = require('express');
const {
  getCart,
  addToCart,
  updateCartItemQuantity,
  removeFromCart,
  saveCart,
  fetchCart
} = require('../controllers/cartController');

const router = express.Router();
const Wholeseller = require('../models/wholesellerModel');

// Routes for cart operations
router.get('/', getCart); 
router.post('/cart/:itemId', addToCart);
router.put('/update-quantity/:userId/:itemId', updateCartItemQuantity); 
router.post('/save-cart', saveCart); 
router.get('/fetch-cart/:userId', fetchCart); 
router.delete('/remove-item/:userId/:itemId', removeFromCart);

// Route to clear all items in a wholeseller's cart
router.delete('/clear-cart/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    // Set the vegetablesCart array to an empty array for the specific wholeseller
    await Wholeseller.updateOne(
      { _id: userId },
      { $set: { vegetablesCart: [] } }
    );

    res.status(200).json({ message: "Cart cleared successfully" });
  } catch (error) {
    console.error("Error clearing cart:", error);
    res.status(500).json({ error: "Failed to clear cart" });
  }
});

module.exports = router;
