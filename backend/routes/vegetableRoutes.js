const express = require('express');
const router = express.Router();

const {
    getAllVegetables,
    getVegetableById,
    updateVegetableQuantity,
    updateVegetableStock
} = require('../controllers/vegetableController');

// Vegetable routes
router.get('/', getAllVegetables);
router.get('/:id', getVegetableById);
router.put('/:id/quantity', updateVegetableQuantity);
router.put('/update-stock/:id', updateVegetableStock);


module.exports = router;