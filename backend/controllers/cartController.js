const Vegetable = require('../models/vegetableModel');
const Wholeseller = require('../models/wholesellerModel');
const mongoose = require('mongoose');
const ObjectId = mongoose.Types.ObjectId;
const cors = require('cors');


exports.getCart = async (req, res) => {
  try {
    const { userId } = req.params;
    const wholeseller = await Wholeseller.findById(userId).populate({
      path: 'vegetablesCart.itemId',
      model: 'Vegetable',
      select: 'name unitprice image', // Select only the fields needed
    });

    if (!wholeseller) return res.status(404).json({ error: 'Wholeseller not found' });

    // Map cart items to include populated fields from Vegetable model
    const cartItems = wholeseller.vegetablesCart.map(item => ({
      itemId: item.itemId._id,
      name: item.itemId.name,
      quantity: item.quantity,
      unitprice: item.itemId.unitprice,
      image: item.itemId.image,
    }));

    res.json({ cartItems });
  } catch (error) {
    console.error('Error in getCart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};


exports.addToCart = async (req, res) => {
  try {
    const { userId } = req.params;
    const { itemId } = req.body;

    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) return res.status(404).json({ error: 'Wholeseller not found' });

    const selectedVegetable = await Vegetable.findById(itemId);
    if (!selectedVegetable) return res.status(404).json({ error: 'Vegetable not found' });

    const existingItem = wholeseller.vegetablesCart.find((item) => item.itemId.toString() === itemId);

    if (existingItem) {
      existingItem.quantity += 1;
    } else {
      wholeseller.vegetablesCart.push({
        itemId: selectedVegetable._id,
        quantity: 0,
      });
    }
    await wholeseller.save();
    res.json({ message: 'Item added to cart successfully', cart: wholeseller.vegetablesCart });
  } catch (error) {
    console.error('Error in addToCart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};


exports.updateCartItemQuantity = async (req, res) => {
  const { userId, itemId } = req.params;
  const { quantity } = req.body;

  console.log('userId:', userId);
  console.log('itemId:', itemId);
  console.log('quantity:', quantity);

  try {
    const user = await Wholeseller.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    const cartItem = user.vegetablesCart.find(item => item.itemId.toString() === itemId);
    if (!cartItem) {
      return res.status(404).json({ message: 'Item not found in cart' });
    }
    if (quantity === 0) {
      user.vegetablesCart = user.vegetablesCart.filter(item => item.itemId.toString() !== itemId);
    } else {
      // Update quantity if greater than 0
      cartItem.quantity = quantity;
    }
    await user.save();

    res.status(200).json({ message: 'Quantity updated successfully', cart: user.vegetablesCart });
  } catch (error) {
    console.error('Error in updateCartItemQuantity:', error);
    res.status(500).json({ message: 'Failed to update quantity', error });
  }
};



exports.saveCart = async (req, res) => {
  try {
    const { userId, cartItems } = req.body;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ message: 'Invalid user ID' });
    }

    const user = await Wholeseller.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found. Cannot save cart.' });
    }

    const missingFields = cartItems.some(item => item.unitprice === undefined);
    if (missingFields) {
      return res.status(400).json({ message: 'All items must include a unitprice.' });
    }

    user.vegetablesCart = cartItems.map(item => ({
      itemId: new mongoose.Types.ObjectId(item.itemId),
      quantity: item.quantity,
    }));

    await user.save();
    res.status(200).json({ message: 'Cart saved successfully', cart: user.vegetablesCart });
  } catch (error) {
    console.error('Error saving cart:', error);
    res.status(500).json({ message: 'Failed to save cart', error: error.message });
  }
};


exports.fetchCart = async (req, res) => {
  try {
    const { userId } = req.params;
    const wholeseller = await Wholeseller.findById(userId).populate({
      path: 'vegetablesCart.itemId',
      model: 'Vegetable',
      select: 'name unitprice image'
    });

    if (!wholeseller) return res.status(404).json({ error: 'User not found' });

    // Filter out any items where `itemId` is null
    const cartItems = wholeseller.vegetablesCart
      .filter(item => item.itemId !== null) // Ensure itemId is not null
      .map(item => ({
        itemId: item.itemId._id,
        name: item.itemId.name,
        quantity: item.quantity,
        unitprice: item.itemId.unitprice,
        image: item.itemId.image
      }));

    res.status(200).json({ cartItems });
  } catch (error) {
    console.error('Error in fetchCart:', error);
    res.status(500).json({ error: 'Failed to load cart' });
  }
};


exports.removeFromCart = async (req, res) => {
  try {
    const { userId, itemId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(userId) || !mongoose.Types.ObjectId.isValid(itemId)) {
      return res.status(400).json({ error: 'Invalid userId or itemId' });
    }

    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) {
      return res.status(404).json({ error: 'Wholeseller not found' });
    }

    const initialCartLength = wholeseller.vegetablesCart.length;
    wholeseller.vegetablesCart = wholeseller.vegetablesCart.filter((item) => item.itemId.toString() !== itemId);
    
    if (wholeseller.vegetablesCart.length === initialCartLength) {
      return res.status(404).json({ error: 'Item not found in cart' });
    }

    await wholeseller.save();
    res.status(200).json({ message: 'Item removed from cart', cart: wholeseller.vegetablesCart });
  } catch (error) {
    console.error('Error in removeFromCart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};
