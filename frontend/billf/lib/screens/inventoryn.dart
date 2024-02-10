import 'package:billf/widgets/utils.dart';
import 'package:billf/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import '../service/apicall.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, dynamic>> products = [
    // Your product array here
  ];

  List<Map<String, dynamic>> suppliers = [
    // Your supplier array here
  ];

  List<Map<String, dynamic>> bills = [
    // Your bill array here
  ];

  int totalProducts = 0;
  int lowOnStock = 0;
  int outOfStock = 0;
  num totalSales = 0;
  num totalProfit = 0;
  num totalUnitSold = 0;
  List<Map<String, dynamic>> supplierSalesAndProfit = [];

  Map<String, dynamic> selectedProduct = {}; // Selected product

  String searchField = ''; // Field to be searched

  int minThreshold = 10; //minimun threshold for the product

  @override
  void initState() {
    super.initState();
    getAllData();

    //selectedFilter = 'All';
  }

  getAllData() async {
    List<Map<String, dynamic>> j = await ApiCall.getInventory();
    List<Map<String, dynamic>> sup = await ApiCall.getSupplier();
    List<Map<String, dynamic>> b = await ApiCall.getOrders();
    //print("--->");
    setState(() {
      products = j;
      suppliers = sup;
      bills = b;
    });
    calculateMetrics();
    setState(() {});
  }

  int _getSupplierCount(String productId) {
    int count = 0;
    for (var supplier in suppliers) {
      for (var product in supplier['products']) {
        if (product['product'] == productId) {
          count++;
          break;
        }
      }
    }
    return count;
  }

  String fromatDate(String timestamp) {
    // Parse the string to a DateTime object
    DateTime dateTime = DateTime.parse(timestamp);
    // Format the DateTime object
    String formattedDateTime =
        '${DateFormat.yMMMMd().format(dateTime)} (${DateFormat.jm().format(dateTime)})';
    return formattedDateTime;
  }

  //calculation of main metics
  void calculateMetrics() {
    totalProducts = getTotalProducts(products);
    lowOnStock = getLowOnStockCount(products);
    outOfStock = getOutOfStockCount(products);
    totalSales = getTotalSales(bills);
    totalProfit = getTotalProfit(products);
    totalUnitSold = getTotalUnitSold(bills);
    //supplierSalesAndProfit = getSupplierSalesAndProfit(bills, products);

    //print(totalProducts);

    // Calculate metrics for the selected product
    if (selectedProduct.isNotEmpty) {
      //print("selected");
      totalSales = getTotalSalesOfSelectedProduct(selectedProduct, bills);
      totalProfit = getTotalProfitOfSelectedProduct(selectedProduct);

      totalUnitSold = getTotalUnitSoldOfSelectedProduct(selectedProduct, bills);
      supplierSalesAndProfit =
          getSupplierListForProduct(selectedProduct["_id"]);

      //print(supplierSalesAndProfit);
    }
  }

  int getTotalProducts(List<Map<String, dynamic>> products) {
    // print(products.length);
    return products.length;
  }

  int getLowOnStockCount(List<Map<String, dynamic>> products) {
    int count = 0;
    for (var product in products) {
      if (product['currentStock'] < minThreshold) {
        count++;
      }
    }
    return count;
  }

  int getOutOfStockCount(List<Map<String, dynamic>> products) {
    int count = 0;
    for (var product in products) {
      if (product['currentStock'] == 0) {
        count++;
      }
    }
    return count;
  }

  num getTotalSales(List<Map<String, dynamic>> bills) {
    num totalSales = 0;
    for (var bill in bills) {
      for (var order in bill['order']) {
        totalSales += order['quantity'];
      }
    }
    return totalSales;
  }

  num getTotalProfit(List<Map<String, dynamic>> products) {
    //print("hdbejnsm");
    num totalProfit = 0;
    for (var product in products) {
      for (var element in getSupplierListForProduct(product["_id"])) {
        totalProfit += element["profit"];
      }
    }

    return totalProfit;
  }

  num getTotalUnitSold(List<Map<String, dynamic>> bills) {
    num totalUnitSold = 0;
    for (var bill in bills) {
      for (var order in bill['order']) {
        totalUnitSold += order['quantity'];
      }
    }
    return totalUnitSold;
  }

  Map<String, Map<String, num>> getSupplierSalesAndProfit(
      List<Map<String, dynamic>> bills, List<Map<String, dynamic>> products) {
    Map<String, Map<String, num>> supplierSalesAndProfit = {};
    for (var bill in bills) {
      for (var order in bill['order']) {
        var product = products.firstWhere((p) => p['_id'] == order['product']);
        var supplierId = order['suppId'];
        int profit =
            (product['price'] - product['inPrice']) * order['quantity'];
        if (!supplierSalesAndProfit.containsKey(supplierId)) {
          supplierSalesAndProfit[supplierId] = {'sales': 0, 'profit': 0};
        }
        supplierSalesAndProfit[supplierId]?['sales'] =
            supplierSalesAndProfit[supplierId]!['sales']! + order['quantity'];
        supplierSalesAndProfit[supplierId]?['profit'] =
            supplierSalesAndProfit[supplierId]!['profit']! + profit;
      }
    }
    return supplierSalesAndProfit;
  }

  // Add helper methods to calculate metrics for the selected product
  num getTotalSalesOfSelectedProduct(
      Map<String, dynamic> selectedProduct, List<Map<String, dynamic>> bills) {
    num totalSales = 0;
    for (var bill in bills) {
      for (var order in bill['order']) {
        if (order['product'] == selectedProduct['_id']) {
          totalSales += order['quantity'] * selectedProduct['price'];
        }
      }
    }
    return totalSales;
  }

  num getTotalProfitOfSelectedProduct(
    Map<String, dynamic> selectedProduct,
  ) {
    num totalProfit = 0;
    for (var element in getSupplierListForProduct(selectedProduct["_id"])) {
      totalProfit += element["profit"];
    }
    return totalProfit;
  }

  num getTotalUnitSoldOfSelectedProduct(
      Map<String, dynamic> selectedProduct, List<Map<String, dynamic>> bills) {
    num totalUnitSold = 0;
    for (var bill in bills) {
      for (var order in bill['order']) {
        if (order['product'] == selectedProduct['_id']) {
          totalUnitSold += order['quantity'];
        }
      }
    }
    return totalUnitSold;
  }

  List<Map<String, dynamic>> getSupplierListForProduct(String productId) {
    List<Map<String, dynamic>> supplierList = [];

    // Iterate through the supplier array
    for (var supplier in suppliers) {
      // Iterate through the products of the current supplier
      for (var product in supplier['products']) {
        //print(supplier);
        // Check if the product id matches the selected product id
        if (product['product'] == productId) {
          // Calculate profit for the supplier
          double profit =
              (getProductPrice(productId) - product['inPrice']).toDouble();
          // Calculate units sold for the supplier
          num unitSold = getUnitSoldForSupplier(supplier['_id'], productId);

          // Create a map for the supplier's information
          Map<String, dynamic> supplierInfo = {
            'name': supplier['name'],
            'inPrice': product['inPrice'],
            'profit': profit * unitSold,
            'unitSold': unitSold,
          };
          // Add the supplier's information to the supplier list
          supplierList.add(supplierInfo);
        }
      }
    }
    // print("jbdbd");
    return supplierList;
  }

// Function to get the unit sold for a supplier
  num getUnitSoldForSupplier(String supplierId, String productId) {
    num unitSold = 0;

    // Iterate through the bill models array
    for (var bill in bills) {
      // Iterate through the orders of the current bill
      for (var order in bill['order']) {
        // Check if the supplier id and product id match the selected ones
        if (order['suppId'] == supplierId && order['product'] == productId) {
          // Increment the unit sold by the quantity in the order
          unitSold += order['quantity'];
        }
      }
    }

    return unitSold;
  }

// Function to get the price of the selected product
  num getProductPrice(String productId) {
    // Iterate through the product models array
    for (var product in products) {
      // Check if the product id matches the selected product id
      if (product['_id'] == productId) {
        // Return the price of the product
        return product['price'];
      }
    }
    // Return 0 if the product id is not found
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredProducts = products.where((product) {
      // Check if the search field is empty or null, return true to include all products
      if (searchField.isEmpty) {
        return true;
      }
      // Check if the product name matches the search field
      return product[searchField.split(":")[0]]
          .toString()
          .toLowerCase()
          .contains(searchField
              .split(":")[searchField.split(":").length - 1]
              .toString()
              .toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
      appBar: TopBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search Order',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        setState(() {
                          searchField = '';
                        });
                      }
                    },
                    onSubmitted: (value) {
                      setState(() {
                        searchField = value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  // Metrics Cards
                  Row(
                    children: [
                      // Total Products Card
                      Expanded(
                        child: Card(
                          surfaceTintColor: Colors.white,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Total Products: $totalProducts'),
                                // Implement logic to display total products count
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Low on Stock Card
                      Expanded(
                        child: Card(
                          color: const Color.fromARGB(255, 255, 233, 167),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Low on Stock: $lowOnStock'),
                                // Implement logic to display low on stock count
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Out of Stock Card
                      Expanded(
                        child: Card(
                          color: const Color.fromARGB(255, 255, 191, 191),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Out of Stock: $outOfStock'),
                                // Implement logic to display out of stock count
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(0, 255, 255, 255),
                            border: Border.all(
                              color: Colors.deepPurple, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Implement logic for adding new product
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return ProductFormDialog();
                                },
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(242, 242, 242, 1)),
                              surfaceTintColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(255, 255, 255, 1)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('+ Add New Product'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  selectedProduct.isNotEmpty
                      ? Row(
                          children: [
                            Expanded(
                              child: Card(
                                surfaceTintColor: Colors.white,
                                color: Color.fromARGB(255, 173, 239, 255),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                          'Total sales of selected product: $totalSales'),
                                      // Implement logic to display total products count
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                surfaceTintColor: Colors.white,
                                color: Color.fromARGB(255, 221, 255, 173),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                          'Total profit of selected product: $totalProfit'),
                                      // Implement logic to display total products count
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  // Table displaying product data
                  Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        dataRowMaxHeight: 60,
                        decoration: const BoxDecoration(color: Colors.white),
                        columns: const [
                          DataColumn(label: Text('Name/ID')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Current Stock')),
                          DataColumn(label: Text('Suppliers')),
                          DataColumn(label: Text('Updated On')),
                        ],
                        rows: filteredProducts.map((product) {
                          return DataRow(
                            color: MaterialStateProperty.all<Color>(product[
                                        'currentStock'] <
                                    minThreshold
                                ? product['currentStock'] == 0
                                    ? const Color.fromARGB(255, 255, 201, 201)
                                    : const Color.fromARGB(255, 255, 235, 175)
                                : Colors.white),
                            onSelectChanged: (selected) {
                              setState(() {
                                selectedProduct = product;
                              });
                              calculateMetrics();
                            },
                            cells: [
                              DataCell(Text(
                                  '${product['name']}\npower: ${product['power']}\n(${product['_id']})')),
                              DataCell(Text('${product['price']}')),
                              DataCell(Text('${product['currentStock']}')),
                              DataCell(
                                  Text('${_getSupplierCount(product['_id'])}')),
                              DataCell(Text(
                                fromatDate(product['updatedOn']),
                                style: AppTextStyles.body2,
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Details Section
                      if (selectedProduct.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Implement logic for editing product
                              },
                              child: const Text('Edit Product'),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.white),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.deepPurple),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                              ),
                              onPressed: () {
                                // Implement logic for editing product
                              },
                              child: const Text('print BarCode'),
                            ),
                          ],
                        ),
                        const Center(
                          child: Text(
                            'Product Details',
                            style: AppTextStyles.subHeading,
                          ),
                        ),
                        const Divider(),
                        RichText(
                            text:
                                TextSpan(style: AppTextStyles.body, children: [
                          const TextSpan(text: "name:   "),
                          TextSpan(
                              text: '${selectedProduct["name"]}',
                              style: AppTextStyles.headingLight)
                        ])),
                        const Divider(),
                        SizedBox(
                          height: 64,
                          child: SfBarcodeGenerator(
                            value: selectedProduct["_id"],
                            symbology: Code128(),
                            showValue: false,
                            textAlign: TextAlign.justify,
                          ),
                        ),

                        Text(
                          '\n_id:   ${selectedProduct["_id"]}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'selling price:   ${selectedProduct["price"]} Rs',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'createdOn: ${fromatDate(selectedProduct["createdOn"])}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'updatedOn: ${fromatDate(selectedProduct["updatedOn"])}',
                          style: AppTextStyles.body,
                        ),
                        const Divider(),
                        Text(
                          'total unit in Stock:   ${selectedProduct["currentStock"]}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'total units Purchsed:  ${selectedProduct["inStock"]}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'total unit Sold:   ${selectedProduct["outStock"]}',
                          style: AppTextStyles.body,
                        ),
                        const Divider(),

                        // Implement displaying product details
                        const Center(
                          child: Text(
                            'Metrics\n',
                            style: AppTextStyles.subHeading,
                          ),
                        ),
                        DataTable(
                          columns: const <DataColumn>[
                            DataColumn(
                              label: Text('name/id'),
                            ),
                            DataColumn(
                              label: Text('inPrice'),
                            ),
                            DataColumn(
                              label: Text('profit/\nunitSold'),
                            ),
                          ],
                          rows: supplierSalesAndProfit.map<DataRow>((data) {
                            //print(data[0]["name"]);
                            return DataRow(
                              //selected: fr,
                              cells: <DataCell>[
                                DataCell(Text(data["name"])),
                                DataCell(Text(data["inPrice"].toString())),
                                DataCell(Text(
                                    "${data["profit"]}\n${data["unitSold"]}"))
                              ],
                            );
                          }).toList(),
                        ),

                        // Implement displaying product metrics
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
