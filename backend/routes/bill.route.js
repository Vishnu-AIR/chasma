const BillRoutes = require("express").Router();
const BillController = require("../controller/bill.controller");

BillRoutes.get("/", BillController.fetchAllBills);
BillRoutes.get("/:id", BillController.fetchBill);

BillRoutes.post("/", BillController.createBill);


module.exports = BillRoutes;