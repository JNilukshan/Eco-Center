const Vegetable = require('../models/vegetableModel');
const Wholeseller = require('../models/wholesellerModel');
const mongoose = require('mongoose');
const ObjectId = mongoose.Types.ObjectId;

// Get all items from the wholeseller's cart
exports.getCart = async (req, res) => {
  try {
    const { userId } = req.params;
    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) return res.status(404).json({ error: 'Wholeseller not found' });

    const allCartItems = wholeseller.vegetablesCart;
    const grandTotal = allCartItems.reduce((total, item) => total + item.unitprice * item.quantity, 0);

    res.json({ cartItems: allCartItems, grandTotal });
  } catch (error) {
    console.error('Error in getCart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Add an item to the wholeseller's cart
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
        name: selectedVegetable.name,
        quantity: 1,
        unitprice: selectedVegetable.unitprice,
      });
    }
    await wholeseller.save();
    res.json({ message: 'Item added to cart successfully', cart: wholeseller.vegetablesCart });
  } catch (error) {
    console.error('Error in addToCart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Update cart item quantity
exports.updateCartItemQuantity = async (req, res) => {
  try {
    const { userId, itemId } = req.params;
    const { quantity } = req.body;

    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) return res.status(404).json({ error: 'Wholeseller not found' });

    const cartItem = wholeseller.vegetablesCart.find((item) => item.itemId.toString() === itemId);
    if (!cartItem) return res.status(404).json({ error: 'Item not found in cart' });

    cartItem.quantity = quantity;
    if (quantity === 0) {
      wholeseller.vegetablesCart = wholeseller.vegetablesCart.filter((item) => item.itemId.toString() !== itemId);
    }
    await wholeseller.save();
    res.json({ message: 'Cart updated successfully', cart: wholeseller.vegetablesCart });
  } catch (error) {
    console.error('Error in updateCartItemQuantity:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};


exports.saveCart = async (req, res) => {
  try {
    const { userId, cartItems } = req.body;

    // Check if the user exists
    const user = await Wholeseller.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found. Cannot save cart.' });
    }

    // Map the cart items with necessary fields and convert itemId to ObjectId
    user.vegetablesCart = cartItems.map(item => ({
      itemId: new ObjectId(item.itemId), 
      name: item.name,
      quantity: item.quantity,
      unitprice: item.unitprice,
    }));

    // Save the updated cart to the database
    await user.save();

    // Respond with success message and updated cart
    res.status(200).json({ message: 'Cart saved successfully', cart: user.vegetablesCart });
  } catch (error) {
    console.error('Error saving cart:', error);
    res.status(500).json({ message: 'Failed to save cart', error: error.message });
  }
};


exports.fetchCart = async (req, res) => {
  try {
    const { userId } = req.params;
    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) return res.status(404).json({ error: 'User not found' });

    res.status(200).json({ cartItems: wholeseller.vegetablesCart });
  } catch (error) {
    console.error('Error in fetchCart:', error);
    res.status(500).json({ error: 'Failed to load cart' });
  }
};

// Remove an item from the cart
exports.removeFromCart = async (req, res) => {
  try {
    const { userId, itemId } = req.params;
    console.log("Received request to remove item:", { userId, itemId });

    // Check if `userId` is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(userId) || !mongoose.Types.ObjectId.isValid(itemId)) {
      console.log("Invalid userId or itemId");
      return res.status(400).json({ error: 'Invalid userId or itemId' });
    }

    // Find the user
    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) {
      console.log("Wholeseller not found with userId:", userId);
      return res.status(404).json({ error: 'Wholeseller not found' });
    }

    // Remove the item from the cart
    const initialCartLength = wholeseller.vegetablesCart.length;
    wholeseller.vegetablesCart = wholeseller.vegetablesCart.filter((item) => item.itemId.toString() !== itemId);
    
    if (wholeseller.vegetablesCart.length === initialCartLength) {
      console.log("Item not found in cart with itemId:", itemId);
      return res.status(404).json({ error: 'Item not found in cart' });
    }

    // Save the updated cart
    await wholeseller.save();
    res.status(200).json({ message: 'Item removed from cart', cart: wholeseller.vegetablesCart });
  } catch (error) {
    console.error('Error in removeFromCart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};