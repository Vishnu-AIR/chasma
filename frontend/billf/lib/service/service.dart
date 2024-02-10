import 'package:billf/service/apicall.dart';

class Service {
  static final orders = ApiCall.getOrders();
  static final products = ApiCall.getInventory();
  static final suppliers = ApiCall.getSupplier();
  static final category = ApiCall.getCategory();
  static final stock = ApiCall.getStock();

  static bool isGg = false;

  Future<Map<dynamic, dynamic>> findProduct(id) async {
    List<dynamic> prod = await products;
    int index = prod.indexWhere((element) => element["id"] == id);

    return prod[index];
  }

  Future<Map<dynamic, dynamic>> findStock(id) async {
    List<dynamic> prod = await stock;
    int index = prod.indexWhere((element) => element["id"] == id);

    return prod[index];
  }

  Future<Map<dynamic, dynamic>> findBill(id) async {
    List<dynamic> prod = await orders;
    int index = prod.indexWhere((element) => element["id"] == id);

    return prod[index];
  }

  Future<Map<dynamic, dynamic>> findSupplier(id) async {
    List<dynamic> prod = await products;
    int index = prod.indexWhere((element) => element["id"] == id);

    return prod[index];
  }

  Future<Map<dynamic, dynamic>> findCategory(id) async {
    List<dynamic> prod = await category;
    int index = prod.indexWhere((element) => element["id"] == id);

    return prod[index];
  }
}
