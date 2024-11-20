const express = require('express');
const router = express.Router();
const { createOrder, reduceStock, getOrdersByUserId, deleteOrderById } = require('../controllers/orderController');

router.post('/createOrder', createOrder);
router.post('/reduceStock', reduceStock);
router.get('/user/:userId', getOrdersByUserId);
router.delete('/:orderId', deleteOrderById);

module.exports = router;