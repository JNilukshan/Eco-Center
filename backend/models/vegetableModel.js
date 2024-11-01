const mongoose = require('mongoose');

const vegetableSchema = new mongoose.Schema({
    name: { type: String, required: true },
    quantity: { type: Number, required: true },
    unitprice: { type: Number, required: true },
    image: { type: String, required: true },
});

const Vegetable = mongoose.model('Vegetable', vegetableSchema);

module.exports = Vegetable;