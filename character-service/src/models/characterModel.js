const mongoose = require('mongoose');

const characterSchema = new mongoose.Schema({
    name: { type: String, required: true, unique: true },
    imagePath: { type: String, required: true }, 
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Character', characterSchema);