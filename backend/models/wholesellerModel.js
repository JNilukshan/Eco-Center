const mongoose = require('mongoose');

const wholesellerSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  address: { type: String, required: true },
  password: { type: String, required: true },
  photo: {type: String,default: null},  
  otp: { type: String },
  role: { type: String, default: 'wholeseller' },

  vegetablesCart: [
    {
      itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Vegetable' },
      name: { type: String, required: true },
      amount: { type: Number, default: 1 },
      price: { type: Number, required: true },
    },
  ],  
}, { timestamps: true });

const Wholeseller = mongoose.model('Wholeseller', wholesellerSchema);
module.exports = Wholeseller;
