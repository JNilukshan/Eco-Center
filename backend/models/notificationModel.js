const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'Wholeseller', required: true }, 
  message: { type: String, required: false }, 
  icon: { type: String }, 
  orderId: { type: String }, 
  amount: { type: Number }, 
  name: { type: String }, 
  dateTime: { type: Date, default: Date.now }, 
});

const Notification = mongoose.model('Notification', notificationSchema);

module.exports = Notification;