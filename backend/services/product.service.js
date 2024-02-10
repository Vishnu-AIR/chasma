
const CategoryModel = require("../models/category.model");
const ProductModel = require("../models/product.model");


addtoCategory = async (category, productId) => {
  await CategoryModel.findOneAndUpdate(
    { name: category },
    { $push: { products: productId } },
    { new: true }
  );
  console.log(productId + "added to" + category);

  return "{$productId} added to {$category}";
};

removeFromCategory = async (category, productId) => {
    await CategoryModel.findOneAndUpdate(
      { name: category },
      { $pull: { products: productId } },
      { new: true }
    );
    console.log(productId + "remove from" + category);
  
    return "{$productId} remove from {$category}";
};


addProduct = async (name, category, price,power) => {
  try {

    //console.log(category)
    if(!category){
        category="default"
    }

    const newProduct = new ProductModel({
        name,
        category,
        price,
        power
      });

      await newProduct.save();
      addtoCategory(category, newProduct._id);
    
      return newProduct;
  } catch (error) {

    throw error
  }
};

getProductById = async (Id) => {
  const yourProduct = await ProductModel.findById(Id);
  if (yourProduct) {
    return yourProduct;
  }
  return yourProduct;
};

updateProductStock = async (productId, operation, quantity) => {
  try {
    const product = await getProductById(productId);
    let newCurrentStock;
    let newOutStock;
    let newInStock;

  if (!product) {
    return "no product found!";
  }


  if(operation ==0 && product.currentStock >= quantity ){
    newInStock = product.inStock;
    newCurrentStock = product.currentStock - quantity;
    newOutStock = product.outStock + quantity;
    
  }
   else if (operation == 1){
    newInStock = product.inStock + quantity;
    newCurrentStock = product.currentStock + quantity;
    newOutStock = product.outStock;
  }else{
    

        return {success: false,message:"low on stock", product: productId,currnetStock: product.currentStock} 
        
      
  }

  const updatedProduct = await ProductModel.findOneAndUpdate(
    { _id: productId },
    {
      inStock: newInStock,
      outStock: newOutStock,
      currentStock: newCurrentStock,
    },
    { new: true }
  );

  if (!updatedProduct) {
    return "no product found";
  }

  return {success: true , product: updatedProduct};
  } catch (error) {
    //console.error(error);
    throw {error: error}
  }
};

updateProductInfo = async (productId, Info) => {
  const product = await getProductById(productId);

  
  if (!product) {
      return product;
    }
if(product.category != Info.category){
      await removeFromCategory(product.category, product._id)
      await addtoCategory(Info.category, product._id)

    }

  const updatedProduct = await ProductModel.findOneAndUpdate(
    { _id: productId },
    Info,
    { new: true }
  );

  if (!updatedProduct) {
    return updatedProduct;
  }

  return updatedProduct;
};

deleteProductById = async (id) => {
  const deletedProduct = await ProductModel.deleteOne({ _id: id });
  if (!deletedProduct) {
    return deletedProduct;
  }
  return deletedProduct;
};



module.exports = {
  addProduct,
  addtoCategory,
  removeFromCategory,
  getProductById,
  updateProductStock,
  updateProductInfo,
  deleteProductById,
};
