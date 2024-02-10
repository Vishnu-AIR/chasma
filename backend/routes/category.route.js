const CategoryRoutes = require('express').Router();
const CategoryController = require('../controller/category.controller');

CategoryRoutes.get("/", CategoryController.fetchAllCategorys);
CategoryRoutes.get("/:id",CategoryController.fetchCategory)
CategoryRoutes.post("/", CategoryController.createCategory);
CategoryRoutes.put("/:id",CategoryController.updateCategory);
CategoryRoutes.delete("/:id", CategoryController.deleteCategory)



module.exports = CategoryRoutes;