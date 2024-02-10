const mongoose = require("mongoose");
const db = require("../config/db");

const { Schema } = mongoose;

const orderSchema = new Schema({
    product: {
      type: Schema.Types.ObjectId,
      require: true,
      ref: "products"
    },
    inPrice: { type: Number, require: true },
    inStock: {type: Number, default: 0}
    

  });

const stockSchema = new Schema({
  suppId: {type: String, require: true },
  products : {type: [orderSchema],require: true},
  total : {type: Number, require: true},
  updatedOn: { type: Date },
  createdOn: { type: Date }
  
});

stockSchema.pre(['save'], function(next) {

    this.updatedOn = new Date();
    this.createdOn = new Date();

    next();

    // Hash the password
});


stockSchema.pre(['findOneAndUpdate'], function(next) {


    const update = this.getUpdate();
    delete update._id;

    this.updatedOn = new Date();

    next();

    // Hash the password
});


const stockModel = db.model("stocks", stockSchema);

module.exports = stockModel;