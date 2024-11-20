const Wholeseller = require('../models/wholesellerModel');
const Notification = require('../models/notificationModel');

exports.createNotification = async (req, res) => {
  const { userId, orderId, totalAmount } = req.body;
  const io = req.app.get('socketio');  // Get Socket.io instance

  try {
    const wholeseller = await Wholeseller.findById(userId);
    if (!wholeseller) {
      return res.status(404).json({ success: false, message: "Wholeseller not found" });
    }

    const notification = new Notification({
      userId,
      message: "Order Success",
      icon: "success_icon.png",
      orderId,
      amount: totalAmount,
      name: wholeseller.name,
      dateTime: new Date(),
    });

    const savedNotification = await notification.save();

    // Push the notification ID into the wholeseller's notifications array
    wholeseller.notifications.push(savedNotification._id);
    await wholeseller.save();

    // Emit the notification to all connected clients
    io.emit('newNotification', savedNotification);

    res.status(200).json({ success: true, message: "Notification created successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error creating notification", error });
  }
};

exports.getNotifications = async (req, res) => {
  try {
    const wholeseller = await Wholeseller.findById(req.params.userId).select('notifications');

    if (!wholeseller) {
      return res.status(404).json({ message: "Wholeseller not found" });
    }

    const notifications = await Notification.find({ _id: { $in: wholeseller.notifications } });
    res.status(200).json({ notifications });
  } catch (error) {
    res.status(500).json({ message: "Failed to load notifications", error });
  }
};

exports.deleteNotification = async (req, res) => {
  try {
    const { userId, id } = req.params;

    const updatedWholeseller = await Wholeseller.findByIdAndUpdate(
      userId,
      { $pull: { notifications: id } },
      { new: true, useFindAndModify: false }
    );

    if (!updatedWholeseller) {
      return res.status(404).json({ message: "Wholeseller not found or notification not present" });
    }

    await Notification.findByIdAndDelete(id);  // Delete notification from database
    res.status(200).json({ message: "Notification deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Failed to delete notification", error });
  }
};
