const Vegetable = require('../models/vegetableModel');

// Get all vegetables
exports.getAllVegetables = async (req, res) => {
    try {
        const vegetables = await Vegetable.find({});
        res.status(200).json({
            success: true,
            data: vegetables
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching vegetables',
            error: error.message
        });
    }
};

// Get single vegetable by ID
exports.getVegetableById = async (req, res) => {
    try {
        const vegetable = await Vegetable.findById(req.params.id);
        if (!vegetable) {
            return res.status(404).json({
                success: false,
                message: 'Vegetable not found'
            });
        }
        res.status(200).json({
            success: true,
            data: vegetable
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching vegetable',
            error: error.message
        });
    }
};

// Update vegetable quantity
exports.updateVegetableQuantity = async (req, res) => {
    try {
        const { id } = req.params;
        const { quantity } = req.body;
        
        const vegetable = await Vegetable.findByIdAndUpdate(
            id,
            { quantity },
            { new: true }
        );
        
        if (!vegetable) {
            return res.status(404).json({
                success: false,
                message: 'Vegetable not found'
            });
        }
        
        res.status(200).json({
            success: true,
            data: vegetable
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating vegetable quantity',
            error: error.message
        });
    }
};