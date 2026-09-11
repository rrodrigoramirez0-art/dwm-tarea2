const mongoose = require('mongoose');

const SandwichSchema = new mongoose.Schema({
  nombre: { type: String, required: true },
  precio: { type: Number, required: true },
  descripcion: String,
  disponible: { type: Boolean, default: true }
});

module.exports = mongoose.model('Sandwich', SandwichSchema);