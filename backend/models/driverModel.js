const mongoose = require('mongoose');

const driverSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  address: { type: String, required: true },
  photo: {type: String,default: null},
  password: { type: String, required: true },
  vehicleType: { type: String },
  licenseExpiryDate: { type: Date },
  phone: {
    type: String,
    required: true,
    validate: {
      validator: function(v) {
        return /^\d{10}$/.test(v); // Ensures the phone number is exactly 10 digits
      },
      message: props => `${props.value} is not a valid 10-digit phone number!`
    },
  },
  otp: { type: String }, 
  role: { type: String, default: 'driver' },
}, { timestamps: true });

const Driver = mongoose.model('Driver', driverSchema);
module.exports = Driver;
