const BillModel = require("../models/bill.model");
const {
    billStock,
createBill,
  getBillById,
  getBillByPhone,
} = require("../services/bussines.service");

const BillController = {
  createBill: async function(req, res){
    try {
        //console.log("making bill")
        const {name, phone,type,address ,order ,total} = req.body;
        const bill = await createBill(name,phone,type,order,address,total);
        res.json({success:true,data:bill,message:"done"})
    } catch (error) {
        
    }
  },

  fetchAllBills: async function (req, res) {
    try {
      const bills = await BillModel.find();
      if (bills.length == 0)
        return res.json({
          success: true,
          data: bills,
          message: "No bills yet.",
        });
      else
        return res.json({
          success: true,
          data: bills,
          message: "here you go",
        });
    } catch(e) {
       
      return res.json({ success: false, message: e });
    }
  },

  fetchBill: async function (req, res) {
    try {
      const bill = await getBillByPhone(req.params.id) ?? await getBillById(req.params.id) ;
      return res.json({ success: true, data: !bill ? "no bill found" : bill });
    } catch (e) {
      return res.json({ success: false, message: e });
    }
  },

//   updateBill: async (req, res) => {
//     try {
//       const billId = req.params.id;
//       const operation = req.params.operation;

//       const { info, quantity } = req.body;

//       let updatedBill;

//       if(operation == 2){
//         updatedBill = await updateBillInfo(billId, info);

//       }else{
//         updatedBill = await updateBillStock(
//             billId,
//             operation,
//             quantity
//           );
//       }

//       if (!updatedBill) {
//         throw "bill not found!";
//       }

//       return res.json({
//         success: true,
//         data: updatedBill,
//         message: "Bill updated!",
//       });
//     } catch (ex) {
//       console.log(ex);
//       return res.json({ success: false, message: ex });
//     }
//   },

//   deleteBill: async function (req, res) {
//     try {
//       const bill = await BillModel.deleteOne({ _id: req.params.id });
//       return res.json({
//         success: true,
//         data: bill,
//         bill: await getBillById(req.params.id),
//         message: "Bill is deleted",
//       });
//     } catch (e) {
//       return res.json({ success: false, message: e });
//     }
//   },
};

module.exports = BillController;
