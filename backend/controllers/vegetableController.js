const Vegetable = require('../models/vegetableModel');
const cors = require('cors');

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


exports.updateVegetableStock = async (req, res) => {
    try {
      const vegetableId = req.params.id;
      const { quantity } = req.body;
  
      // Find the vegetable by ID
      const vegetable = await Vegetable.findById(vegetableId);
      if (!vegetable) {
        return res.status(404).json({ message: 'Vegetable not found' });
      }
  
      // Subtract the ordered quantity from available stock
      vegetable.quantity -= quantity;
  
      // Ensure quantity does not go below zero
      if (vegetable.quantity < 0) {
        vegetable.quantity = 0;
      }
  
      // Save the updated stock
      await vegetable.save();
  
      res.status(200).json({
        message: 'Stock updated successfully',
        vegetable,
      });
    } catch (error) {
      console.error('Error updating stock:', error);
      res.status(500).json({ message: 'Failed to update stock', error });
    }
  };