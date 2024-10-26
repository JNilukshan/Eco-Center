

const Wholeseller = require('../models/wholesellerModel');

// Get all items from the wholeseller's cart
exports.getCart = async (req, res) => {
  try {
    const wholeseller = req.user; 
    const allCartItems = [...wholeseller.vegetablesCart].filter(item => item);
    const grandTotal = allCartItems.reduce((total, item) => {
      return total + (item.unitprice * item.quantity);
    }, 0);

    res.json({ cartItems: allCartItems, grandTotal });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Add an item to the wholeseller's cart
exports.addToCart = async (req, res) => {
  try {
    const { itemId } = req.params;
    const wholeseller = req.user;

    const selectedVegetable = await Vegetable.findById(itemId);
    if (!selectedVegetable) {
      return res.status(404).json({ error: 'Vegetable not found' });
    }

    const existingItem = wholeseller.vegetablesCart.find(
      (item) => item.itemId.toString() === itemId
    );

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
    const { itemId } = req.params;
    const { quantity } = req.body;
    const wholeseller = req.user;

    const cartItem = wholeseller.vegetablesCart.find(item => item.itemId.toString() === itemId);
    if (!cartItem) {
      return res.status(404).json({ error: 'Item not found in cart' });
    }

    cartItem.quantity = quantity;
    if (quantity === 0) {
      wholeseller.vegetablesCart = wholeseller.vegetablesCart.filter(item => item.itemId.toString() !== itemId);
    }

    await wholeseller.save();
    res.json({ message: 'Cart updated successfully', cart: wholeseller.vegetablesCart });
  } catch (error) {
    console.error('Error updating cart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Remove an item from the cart
exports.removeFromCart = async (req, res) => {
  try {
    const { itemId } = req.params;
    const wholeseller = req.user;

    wholeseller.vegetablesCart = wholeseller.vegetablesCart.filter(item => item.itemId.toString() !== itemId);
    await wholeseller.save();
    res.json({ message: 'Item removed from cart', cart: wholeseller.vegetablesCart });
  } catch (error) {
    console.error('Error removing item from cart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};
