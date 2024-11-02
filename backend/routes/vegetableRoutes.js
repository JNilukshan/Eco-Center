const express = require('express');
const router = express.Router();

const {
    getAllVegetables,
    getVegetableById,
    updateVegetableQuantity
} = require('../controllers/vegetableController');

// Vegetable routes
router.get('/', getAllVegetables);
router.get('/:id', getVegetableById);
router.put('/:id/quantity', updateVegetableQuantity);

module.exports = router;