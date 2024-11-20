const Order = require('../models/orderModel');
const Wholeseller = require('../models/wholesellerModel');
const Vegetable = require('../models/vegetableModel');



exports.createOrder = async (req, res) => {
  const { userId, items, totalAmount } = req.body;
  
  try {
    // Create and save the new order
    const newOrder = new Order({ userId, items, totalAmount });
    await newOrder.save();

    // Find the wholeseller by userId to ensure they exist
    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) {
      return res.status(404).json({ success: false, message: "Wholeseller not found" });
    }

    // Create a new notification document
    // const notification = new Notification({
    //   userId,
    //   message: "Order Placed Successfully",
    //   icon: "order_success.png",
    //   orderId: newOrder._id,
    //   amount: totalAmount,
    //   name: wholeseller.name,
    //   dateTime: new Date(),
    // });

    // Save the notification in the Notification collection
    // const savedNotification = await notification.save();
    // console.log("Notification saved successfully:", savedNotification);

    // // Push the notification ID into the wholeseller's notifications array
    // wholeseller.notifications.push(savedNotification._id);
    // await wholeseller.save();
    // console.log("Notification added to Wholeseller's notifications array");

    // Return success response with the new order's ID
    res.status(200).json({
      success: true,
      message: "Order created and notification sent successfully",
      orderId: newOrder._id, // Include orderId in the response
    });
  } catch (error) {
    console.error("Error creating order:", error);
    res.status(500).json({ success: false, message: "Error creating order", error });
  }
};


exports.reduceStock = async (req, res) => {
  const { orderedItems } = req.body;

  try {
    for (let item of orderedItems) {
      const vegetable = await Vegetable.findById(item.itemId);

      if (!vegetable) {
        return res.status(404).json({
          success: false,
          message: `Item with ID ${item.itemId} not found.`,
        });
      }

      // Check if the stock is enough for the requested quantity
      if (vegetable.quantity < item.quantity) {
        return res.status(400).json({
          success: false,
          message: `Not enough stock for item ${vegetable.name}. Available: ${vegetable.quantity}, Requested: ${item.quantity}`,
        });
      }

      // Decrease the stock
      vegetable.quantity -= item.quantity;

      // If the stock reaches zero or below, remove the item from the database
      if (vegetable.quantity <= 0) {
        await Vegetable.findByIdAndRemove(item.itemId);
      } else {
        await vegetable.save();
      }
    }
    res.status(200).json({ success: true, message: "Stock updated successfully" });
  } catch (error) {
    console.error("Error in reduceStock:", error);
    res.status(500).json({ success: false, message: "Error updating stock", error });
  }
};

exports.getOrdersByUserId = async (req, res) => {
  const { userId } = req.params;

  try {
    const orders = await Order.find({ userId })
      .populate("items.itemId", "name") // Populate item name from Vegetable model
      .exec();

    if (!orders) {
      return res.status(404).json({ success: false, message: "No orders found" });
    }

    res.status(200).json({ success: true, orders });
  } catch (error) {
    console.error("Error fetching orders:", error);
    res.status(500).json({ success: false, message: "Error fetching orders", error });
  }
};


exports.deleteOrderById = async (req, res) => {
  const { orderId } = req.params;

  try {
    const deletedOrder = await Order.findByIdAndDelete(orderId);

    if (!deletedOrder) {
      return res.status(404).json({ success: false, message: "Order not found" });
    }

    res.status(200).json({ success: true, message: "Order deleted successfully" });
  } catch (error) {
    console.error("Error deleting order:", error);
    res.status(500).json({ success: false, message: "Error deleting order", error });
  }
};