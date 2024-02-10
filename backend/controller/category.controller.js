const { ObjectID } = require('mongodb');
const CategoryModel = require("../models/category.model");
const { getProductById,  updateProductInfo } = require("../services/product.service");

const CategoryController = {
  createCategory: async function (req, res) {
    try {
      const productData = req.body;
      const newCategory = new CategoryModel(productData);
      await newCategory.save();

      return res.json({
        success: true,
        data: newCategory,
        message: "Category created!",
      });
    } catch (e) {
      return res.json({ success: false, message: e });
    }
  },

  fetchAllCategorys: async function (req, res) {
    try {
      const products = await CategoryModel.find();
      if (products.length == 0)
        return res.json({
          success: true,
          data: products,
          message: "No products yet.",
        });
      else
        return res.json({
          success: true,
          data: products,
          message: "here you go",
        });
    } catch (e) {
      return res.json({ success: false, message: e });
    }
  },
  fetchCategory: async function (req, res) {
    try {
      const category = await CategoryModel.findById(req.params.id);
      return res.json({ success: true, data: category });
    } catch (e) {
      return res.json({ success: false, message: e });
    }
  },

  updateCategory: async (req, res) => {
    try {
      const categoryId = req.params.id;
      const products = req.body.products;
      //const category = await CategoryModel.findById(categoryId);


      products.forEach( async (element) => {
        product = await getProductById(element);
        console.log(await updateProductInfo(product._id, {category : categoryId}))
      });

      const updatedCategory = await CategoryModel.findById(categoryId);

        return res.json({ success: true, data: updatedCategory, message:"product(s) are added!" });
      

    } catch (ex) {
      console.log(ex);
      return res.json({ success: false, message: ex });
    }
  },

  deleteCategory: async(req, res, next)=>{
    const deletedCategory = await CategoryModel.deleteOne({ _id: req.params.id });
    if (!deletedCategory) {
        return res.json({ success: true,data: deletedCategory, message: "no category found" });
  }
  return res.json({ success: true,data: deletedCategory, message: "category deleted" });
  }

};

module.exports = CategoryController;
