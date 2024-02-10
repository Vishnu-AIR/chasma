const StockModel = require("../models/stock.model");
const { createStock, getStockById } = require("../services/bussines.service");

const StockController = {
  createStock: async function(req, res){
    try {
        // console.log("making stock")
        const {suppId, products, total} = req.body;
        const stock = await createStock(suppId, products,total);
        res.json({success:true,data:stock,message:"done"})
    } catch (error) {
        
    }
  },

  fetchAllStocks: async function (req, res) {
    try {
      const stocks = await StockModel.find();
      if (stocks.length == 0)
        return res.json({
          success: true,
          data: stocks,
          message: "No stocks yet.",
        });
      else
        return res.json({
          success: true,
          data: stocks,
          message: "here you go",
        });
    } catch(e) {
       
      return res.json({ success: false, message: e });
    }
  },

  fetchStock: async function (req, res) {
    try {
      const stock = await getStockById(req.params.id) ;
      return res.json({ success: true, data: !stock ? "no stock found" : stock });
    } catch (e) {
      return res.json({ success: false, message: e });
    }
  },

//   updateStock: async (req, res) => {
//     try {
//       const stockId = req.params.id;
//       const operation = req.params.operation;

//       const { info, quantity } = req.body;

//       let updatedStock;

//       if(operation == 2){
//         updatedStock = await updateStockInfo(stockId, info);

//       }else{
//         updatedStock = await updateStockStock(
//             stockId,
//             operation,
//             quantity
//           );
//       }

//       if (!updatedStock) {
//         throw "stock not found!";
//       }

//       return res.json({
//         success: true,
//         data: updatedStock,
//         message: "Stock updated!",
//       });
//     } catch (ex) {
//       console.log(ex);
//       return res.json({ success: false, message: ex });
//     }
//   },

//   deleteStock: async function (req, res) {
//     try {
//       const stock = await StockModel.deleteOne({ _id: req.params.id });
//       return res.json({
//         success: true,
//         data: stock,
//         stock: await getStockById(req.params.id),
//         message: "Stock is deleted",
//       });
//     } catch (e) {
//       return res.json({ success: false, message: e });
//     }
//   },
};

module.exports = StockController;
