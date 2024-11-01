const mongoose = require('mongoose');

const driverSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: {
    type: String,
    required: true,
    unique: true,
    validate: {
      validator: function(v) {
        return /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/.test(v); // Email format validation
      },
      message: props => `${props.value} is not a valid email address!`
    }
  },
  address: { type: String, required: true },
  photo: { type: String, default: null },
  password: { type: String, required: true },
  vehicleType: { type: String },
  vehicalnumber: { type: Date },
  phone: {
    type: String,
    required: true,
    
  },
  otp: { type: String },
  role: { type: String, default: 'driver' },
}, { timestamps: true });

const Driver = mongoose.model('Driver', driverSchema);
module.exports = Driver;
