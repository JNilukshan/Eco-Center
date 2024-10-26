const Wholeseller = require('../models/wholesellerModel');
//const Vegetable = require('../models/VegetableModel');

// Get all items from the wholeseller's cart
exports.getCart = async (req, res) => {
  try {
    const wholeseller = req.user; 

    // Combine all cart items (vegetables) into a single array
    const allCartItems = [...wholeseller.vegetablesCart].filter(item => item);

    // Calculate the grand total
    const grandTotal = allCartItems.reduce((total, item) => {
      return total + (item.price * item.amount);
    }, 0);

    res.render('cart', {
      allCartItems,
      grandTotal,
      wholeseller,
    });
  } catch (error) {
    console.error(error);
    res.status(500).send('Internal Server Error');
  }
};

// Add an item to the wholeseller's cart
exports.addToCart = async (req, res) => {
  try {
    const { itemId } = req.params;
    const wholeseller = req.user; 

    console.log(`Adding vegetable item ${itemId} to cart for wholeseller ${wholeseller._id}`);

    // Find the vegetable by its ID
    const selectedVegetable = await Vegetable.findById(itemId);

    if (!selectedVegetable) {
      console.log(`Vegetable not found: ${itemId}`);
      return res.status(404).json({ error: 'Vegetable not found' });
    }

    // Create the cart item
    const cartItem = {
      itemId: selectedVegetable._id,
      name: selectedVegetable.name,
      amount: 1,  // Default amount when adding an item
      price: selectedVegetable.price,
    };

    // Add the vegetable to the wholeseller's cart
    wholeseller.vegetablesCart.push(cartItem);

    // Save the wholeseller's updated cart
    await wholeseller.save();

    console.log(`Item added successfully: ${JSON.stringify(cartItem)}`);
    res.status(200).json({ message: 'Item added to cart successfully', cartItem });
  } catch (error) {
    console.error('Error in addToCart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Update cart item quantity
exports.updateCartItemQuantity = async (req, res) => {
  try {
    const { itemId, amount } = req.body;
    const wholeseller = req.user; // Assuming the wholeseller is authenticated as the user

    const cartItem = wholeseller.vegetablesCart.find(item => item.itemId.toString() === itemId);

    if (!cartItem) {
      return res.status(404).json({ error: 'Item not found in cart' });
    }

    // Update the amount of the cart item
    cartItem.amount = amount;

    // Remove item if quantity is zero
    if (amount === 0) {
      wholeseller.vegetablesCart = wholeseller.vegetablesCart.filter(item => item.itemId.toString() !== itemId);
    }

    await wholeseller.save();
    res.status(200).json({ message: 'Cart updated successfully', cart: wholeseller.vegetablesCart });
  } catch (error) {
    console.error('Error updating cart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Remove an item from the cart
exports.removeFromCart = async (req, res) => {
  try {
    const { itemId } = req.params;
    const wholeseller = req.user; // Assuming the wholeseller is authenticated as the user

    // Remove the item from the cart
    wholeseller.vegetablesCart = wholeseller.vegetablesCart.filter(item => item.itemId.toString() !== itemId);

    await wholeseller.save();
    res.status(200).json({ message: 'Item removed from cart', cart: wholeseller.vegetablesCart });
  } catch (error) {
    console.error('Error removing item from cart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};
