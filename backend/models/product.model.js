const mongoose = require("mongoose");
const db = require("../config/db");


const { Schema } = mongoose;

const productSchema = new Schema({
  name: {type: String, require: true },
  category:{type: String, ref: 'category',default: ""},
  power:{type:String,default:""},
  price: { type: Number, require: true },
  inStock: {type: Number, default: 0},
  currentStock: {type: Number, default: 0},
  outStock: {type: Number, default: 0},
  mectric:{type:{
    
  },},
  updatedOn: { type: Date },
  createdOn: { type: Date }
});

productSchema.pre(['findOneAndUpdate'], function(next) {


  const update = this.getUpdate();
  delete update._id;


  this.updatedOn = new Date();

  next();

  // Hash the password
});

productSchema.pre('save', function(next){


  this.updatedOn = new Date();
  this.createdOn = new Date();

  next();
})



const productModel = db.model("products", productSchema);

module.exports = productModel;


