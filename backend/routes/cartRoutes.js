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

router.get('/', getCart); 
router.post('/cart/:itemId', addToCart);
router.put('/cart/:itemId', updateCartItemQuantity);
router.post('/save-cart', saveCart); 
router.get('/fetch-cart/:userId', fetchCart); 
router.delete('/remove-item/:userId/:itemId', removeFromCart);

module.exports = router;
