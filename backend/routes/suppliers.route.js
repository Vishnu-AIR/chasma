const SupplierRoutes = require('express').Router();
const SupplierController = require('../controller/supplier.controller');

SupplierRoutes.get("/", SupplierController.fetchAllsuppliers);
SupplierRoutes.get("/:id",SupplierController.fetchsupplier)
SupplierRoutes.post("/", SupplierController.createsupplier);
SupplierRoutes.patch("/:id",SupplierController.updatesupplier);
SupplierRoutes.delete("/:id", SupplierController.deletesupplier);



module.exports = SupplierRoutes;