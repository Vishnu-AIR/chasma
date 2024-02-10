const BillModel = require("../models/bill.model");
const StockModel = require("../models/stock.model");
const supplierModel = require("../models/supplier.model");
const { updateProductStock, getProductById } = require("./product.service");

getBillById = async (id) => {
  try {
    bill = await BillModel.findById(id);
    return bill;
  } catch (error) {
    throw error;
  }
};

getBillByPhone = async (phone) => {
    try {
        bill = await BillModel.find({phone: phone})
        return bill
    } catch (error) {
        throw error
    }
}

getStockById = async (id) => {
  try {
    const stock = await StockModel.findById(id);
    return stock;
  } catch (error) {
    throw error;
  }
};



updateStock = async (productId,quantity) =>{
    const product = getProductById(productId);

} 

getSuppById = async (id) => {
  try {
    const supp = await supplierModel.findById(id);
    return supp;
  } catch (error) {
    throw error;
  }
};


updateSupplier = async (suppId, productId, inPrice) => {
  const supp = await getSuppById(suppId);
  const products = supp.products;
  
  try {
    //console.log(products.findIndex( obj => obj.product == productId));
    if (products.findIndex( obj => obj.product == productId) > -1 ) {
      //console.log("found")
      //console.log(products[products.findIndex(obj => obj.product == productId)].inPrice)
      if( products[products.findIndex(obj => obj.product == productId)].inPrice== inPrice ){
        //console.log("found..2")
        return -1
      }else{
          //console.log("found with diff inP")
          const updateSupp = await supplierModel.updateOne(
            { _id: suppId, 'products.product': productId },
            { $set: { 'products.$.inPrice': inPrice } },
            {new: true}
          );
          return updateSupp;
        
      }
    }
     else {
      //console.log("working on stocks..6")
      
        const updateSupp = await supplierModel.findByIdAndUpdate(
          {"_id":suppId},
          { $push: {products:{ product: productId, inPrice: inPrice }} },
          { new: true }
        );
        return updateSupp;
    }
  } catch (error) {
    throw error;
  }
};

createStock = async (suppId, products, total) => {
  try {
    // products.forEach(async (element) => {
    //   await updateSupplier(suppId, element);
    // });
    // console.log("working on stocks")
    for(const element in products){
        await updateSupplier(suppId, products[element].product,products[element].inPrice);
    }
    // console.log("working on stocks..2")
    const stock = new StockModel({
      suppId: suppId,
      products: products,
      total: total,
    });
    await stock.save();

    await addStock(stock._id);

    return stock;
  } catch (error) {
    throw error;
  }
};  

createBill = async (name,phone,type, order,address ,total) => {
    try {
      
    //console.log(order)
     const outOfStock = await billStock(order);
     console.log(outOfStock)
     if(outOfStock.success){
        //console.log("saving..")
        const bill = new BillModel({
        name,
        phone,
        type,
        address,
        order, 
        total
      });
      await bill.save();
  
      return bill;
        
     }else{
        return {message:"out of stock", data: outOfStock}
     }
      
    
    } catch (error) {
      throw error;
    }
  };

addStock = async (stockId) => {
  try {
    console.log("adding to stock : "+stockId)
    const stock = await getStockById(stockId);
    stock.products.forEach(async (element) => {
      await updateProductStock(element.product, 1, element.inStock);
    });

    return { message: "stock loaded :)", stock: stockId };
  } catch (error) {
    throw { message: "error stock loaded :(", error: error };
  }
};

billStock = async (order) => {
  try {

    for (const element in order){
        console.log(order[element])
        let ok = await updateProductStock(order[element].product, 0, order[element].quantity)
        if(!ok.success){
            return ok
        }
    }
        return { success: true,message: "billing successfull :)"};
    
    
  } catch (error) {
    console.log(error)
    throw { message: "billing unsuccessfull :(", error: error };
  }
};

unBillStock = async (order) => {
  try {

    for (const element in order){
        console.log(order[element])
        let ok = await updateProductStock(order[element].product, 1, order[element].quantity)
        if(!ok.success){
            return ok
        }
    }
        return { success: true,message: "billing successfull :)"};
    
    
  } catch (error) {
    console.log(error)
    throw { message: "billing unsuccessfull :(", error: error };
  }
};


module.exports = {
    getBillById,
    getBillByPhone,
    getStockById,
    getSuppById,
    billStock,
    createStock,
    createBill,
    updateSupplier,
}