const mongoose = require("mongoose");
const db = require("../config/db");

const { Schema } = mongoose;

const productSchema = new Schema({
  product: {
    type: Schema.Types.ObjectId,
    ref: "products",
    require: true,
  },
  quantity: { type: Number, require: true, default: 1 },
  supp:{type: Schema.Types.ObjectId,
    ref: "suppliers"}
});

const billSchema = new Schema({
  name: {
    type: String,
    require: true,
  },
  phone: {
    type: Number,
    require: true,
    
  },
  type:{
    type:String,
    default:"Invoice"
  },
  address:{
    type:String,
    default:""
  },
  order: { type: [productSchema], required: true },
  total: { type: Number, required: true },
  updatedOn: { type: Date },
  createdOn: { type: Date },
});

billSchema.pre("save", async function (next) {
  this.updatedOn = new Date();
  this.createdOn = new Date();
  

  // Hash the password

  next();
});

billSchema.pre("findOneAndUpdate", function (next) {
  const update = this.getUpdate();
  delete update._id;
  this.updatedOn = new Date();

  next();

  // Hash the password
});


const billModel = db.model("bills", billSchema);

module.exports = billModel;
