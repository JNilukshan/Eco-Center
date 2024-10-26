


exports.addToCart = async (req, res) => {
  try {
    const { itemId } = req.params;
    const wholeseller = req.user;

    // Find the vegetable by its ID
    const selectedVegetable = await Vegetable.findById(itemId);
    if (!selectedVegetable) {
      return res.status(404).json({ error: 'Vegetable not found' });
    }

    // Check if item already exists in cart
    const existingItem = wholeseller.vegetablesCart.find(
      (item) => item.itemId.toString() === itemId
    );

    if (existingItem) {
      existingItem.quantity += 1; // Increase quantity if already in cart
    } else {
      // Add new item to cart
      wholeseller.vegetablesCart.push({
        itemId: selectedVegetable._id,
        name: selectedVegetable.name,
        quantity: 1,
        unitprice: selectedVegetable.unitprice,
      });
    }

    await wholeseller.save();
    res.status(200).json({ message: 'Item added to cart successfully', cart: wholeseller.vegetablesCart });
  } catch (error) {
    console.error('Error adding to cart:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};
