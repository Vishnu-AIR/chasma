const mongoose = require("mongoose");
const db = require("../config/db");

const { Schema } = mongoose;

const orderSchema = new Schema({
  product: {
    type: Schema.Types.ObjectId,
    require: true,
    ref: "products"
  },
  inPrice: { type: Number, require: true }
  

});

const supplierSchema = new Schema({
  name: {type: String, require: true },
  phone: { type: Number, require: true, unique: true },
  address: {type: String, default: ""},
  products: {type: [orderSchema], default: []},
  updatedOn: { type: Date },
  createdOn: { type: Date }
});

supplierSchema.pre(['save'], function(next) {

    this.updatedOn = new Date();
    this.createdOn = new Date();

    next();

});

supplierSchema.pre(['findOneAndUpdate'], function(next) {

    
    const update = this.getUpdate();
    delete update._id;

    this.updatedOn = new Date();

    next();

});

const supplierModel = db.model("suppliers", supplierSchema);

module.exports = supplierModel;