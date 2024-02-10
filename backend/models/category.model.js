const mongoose = require("mongoose");
const db = require("../config/db");

const { Schema } = mongoose;

const categorySchema = new Schema({
  name: {type: String, require: true },
  products:{type: [Schema.Types.ObjectId], ref: 'products',required:true, default:[]},
  updatedOn: {type: Date},
  createdOn: {type: Date}
});

categorySchema.pre(['save'], function(next) {

  this.updatedOn = new Date();
  this.createdOn = new Date();

  next();

  // Hash the password
});


categorySchema.pre(['findOneAndUpdate'], function(next) {


  const update = this.getUpdate();
  delete update._id;

  this.updatedOn = new Date();

  next();

  // Hash the password
});

const categoryModel = db.model("category", categorySchema);

module.exports = categoryModel;


