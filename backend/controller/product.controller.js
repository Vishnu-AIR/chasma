const ProductModel = require("../models/product.model");
const {
  addProduct,
  updateProductStock,
  getProductById,
  updateProductInfo,
  addtoCategory
} = require("../services/product.service");

const ProductController = {
  createProduct: async function (req, res, next) {
    try {
      const { name, category, price, power } = req.body;
      const newProduct = await addProduct(name, category, price, power);
      return res.json({
        success: true,
        data: newProduct,
        message: "Product created!",
      });
    } catch (e) {
        console.log(e)
      return res.json({ success: false, message: e });
  }
},

  fetchAllProducts: async function (req, res) {
    try {
      const products = await ProductModel.find();
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

  fetchProduct: async function (req, res) {
    try {
      const product = await getProductById(req.params.id);
      return res.json({ success: true, data: !product ? "no product found" : product });
    } catch (e) {
      return res.json({ success: false, message: e });
    }
  },

  updateProduct: async (req, res) => {
    try {
      const productId = req.params.id;
      const operation = req.params.operation;

      const { info, quantity } = req.body;

      let updatedProduct;

      if(operation == 2){
        updatedProduct = await updateProductInfo(productId, info);

      }else{
        updatedProduct = await updateProductStock(
            productId,
            operation,
            quantity
          );
      }

      if (!updatedProduct) {
        throw "product not found!";
      }

      return res.json({
        success: true,
        data: updatedProduct,
        message: "Product updated!",
      });
    } catch (ex) {
      console.log(ex);
      return res.json({ success: false, message: ex });
    }
  },

  deleteProduct: async function (req, res) {
    try {
      const product = await ProductModel.deleteOne({ _id: req.params.id });
      return res.json({
        success: true,
        data: product,
        product: await getProductById(req.params.id),
        message: "Product is deleted",
      });
    } catch (e) {
      return res.json({ success: false, message: e });
    }
  },
};

module.exports = ProductController;
