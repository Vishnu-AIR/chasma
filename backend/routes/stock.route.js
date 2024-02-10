const StockRoutes = require("express").Router();
const StockController = require("../controller/stock.controller");

StockRoutes.get("/", StockController.fetchAllStocks);
StockRoutes.get("/:id", StockController.fetchStock);

StockRoutes.post("/", StockController.createStock);


module.exports = StockRoutes;