const express = require('express');
const { getCart, addToCart, updateCartItemQuantity, removeFromCart } = require('../controllers/cartController');


const router = express.Router();


router.get('/cart', getCart); 
router.post('/cart/:itemId', addToCart); 
router.put('/cart/:itemId', updateCartItemQuantity); 
router.delete('/cart/:itemId', removeFromCart); 

module.exports = router;
