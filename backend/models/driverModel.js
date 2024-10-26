const mongoose = require('mongoose');

const driverSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  address: { type: String, required: true },
  photo: {type: String},
  password: { type: String, required: true },
  vehicleType: { type: String },
  licenseExpiryDate: { type: Date },
  otp: { type: String }, 
  role: { type: String, default: 'driver' },
}, { timestamps: true });

const Driver = mongoose.model('Driver', driverSchema);
module.exports = Driver;
