const supplierModel = require("../models/supplier.model");
const { addtosupplier, getProductById, removeFromsupplier, updateProductInfo } = require("../services/bussines.service");

const supplierController = {
  createsupplier: async function (req, res) {
    try {
      const {name,phone,address,products} = req.body;
     // console.log(products);
      const newsupplier = new supplierModel({name,phone,address,products});
      await newsupplier.save();

      return res.json({
        success: true,
        data: newsupplier,
        message: "supplier created!",
      });
    } catch (e) {
      return res.json({ success: false, message: e });
    }
  },

  fetchAllsuppliers: async function (req, res) {
    try {
      const suppliers = await supplierModel.find();
      if (suppliers.length == 0)
        return res.json({
          success: true,
          data: suppliers,
          message: "No suppliers yet.",
        });
      else
        return res.json({
          success: true,
          data: suppliers,
          message: "here you go",
        });
    } catch (e) {
      return res.json({ success: false, message: e });
    }
  },
  fetchsupplier: async function (req, res) {
    try {
      const supplier = await supplierModel.findById(req.params.id);
      return res.json({ success: true, data: supplier });
    } catch (e) {
      return res.json({ success: false, message: e });
    }
  },

  updatesupplier: async (req, res) => {
    try {
      const supplierId = req.params.id;
      let newInfo = req.body;

      
      //const supplier = await supplierModel.findById(supplierId);

      const updatedsupplier = await supplierModel.findOneAndUpdate({_id: supplierId},newInfo, {new : true});

   
        return res.json({ success: true, data: updatedsupplier, message:"product(s) are added!" });
      

    } catch (ex) {
      console.log(ex);
      return res.json({ success: false, message: ex });
    }
  },

  deletesupplier: async(req, res, next)=>{
    const deletedsupplier = await supplierModel.deleteOne({ _id: req.params.id });
    if (!deletedsupplier) {
        return res.json({ success: true,data: deletedsupplier, message: "no supplier found" });
  }
  return res.json({ success: true,data: deletedsupplier, message: "supplier deleted" });
  }

};

module.exports = supplierController;
