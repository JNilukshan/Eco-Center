const mongoose = require('mongoose');

const wholesellerSchema = new mongoose.Schema({
  name: { type: String },
  email: {
    type: String,
    unique: true,
    validate: {
      validator: function(v) {
        return /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/.test(v); // Email format validation
      },
      message: props => `${props.value} is not a valid email address!`
    }
  },
  address: { type: String },
  password: { type: String },
  phone: {
    type: String,
    
  },
  otp: { type: String },
  role: { type: String, default: 'wholeseller' },
  vegetablesCart: [
    {
      itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Vegetable' },
      name: { type: String, required: true },
      quantity: { type: Number, required: true },
      unitprice: { type: Number, required: false },
    }
  ],
}, { timestamps: true });

const Wholeseller = mongoose.model('Wholeseller', wholesellerSchema);
module.exports = Wholeseller;
