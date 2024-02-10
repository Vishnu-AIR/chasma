const ProductRoutes = require("express").Router();
const ProductController = require("../controller/product.controller");

ProductRoutes.get("/", ProductController.fetchAllProducts);
ProductRoutes.get("/:id", ProductController.fetchProduct);

ProductRoutes.post("/", ProductController.createProduct);

ProductRoutes.put("/:id/:operation", ProductController.updateProduct);

ProductRoutes.delete("/:id", ProductController.deleteProduct);

module.exports = ProductRoutes;
