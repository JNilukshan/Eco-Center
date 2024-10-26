const express = require('express');
const { getCart, addToCart, updateCartItemQuantity, removeFromCart } = require('../controllers/cartController');


const router = express.Router();


router.get('/', getCart); // GET /api/cart
router.post('/add/:itemId', addToCart); // POST /api/cart/add/:itemId
router.put('/update', updateCartItemQuantity); // PUT /api/cart/update
router.delete('/remove/:itemId', removeFromCart); // DELETE /api/cart/remove/:itemId

module.exports = router;
