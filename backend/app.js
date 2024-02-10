const express = require("express");
const bodyparser = require("body-parser");
const cors = require("cors");

const ProductRoutes = require("./routes/product.route");
const CategoryRoutes = require("./routes/category.route");
const SupplierRoutes = require("./routes/suppliers.route");
const BillRoutes = require("./routes/bill.route");
const StockRoutes = require("./routes/stock.route");

const app = express();

const corsOptions = {
  origin: "*", // Replace with your app's domain
  optionsSuccessStatus: 200,
};

app.use(cors(corsOptions));

app.use(bodyparser.json());


//app.use('/api/auth',userRouter);
app.use("/api/products", ProductRoutes)
app.use("/api/categories", CategoryRoutes)
app.use("/api/suppliers", SupplierRoutes)
app.use("/api/bills", BillRoutes)
app.use("/api/stocks", StockRoutes)




app.use("/", (req, res, next) => {
  return res.send("<center><h1>Tenu KALA CHASMA JAJTA hai..!</h1></center>");
});

module.exports = app;
