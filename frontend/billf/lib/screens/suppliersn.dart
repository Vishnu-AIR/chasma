import 'package:billf/widgets/utils.dart';
import 'package:billf/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/apicall.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  List<Map<String, dynamic>> products = [
    // Your product array here
  ];

  List<Map<String, dynamic>> suppliers = [
    // Your supplier array here
  ];

  List<Map<String, dynamic>> bills = [
    // Your bill array here
  ];

  List<Map<String, dynamic>> purchases = [
    // Your bill array here
  ];

  int totalSuppliers = 0;
  int newSuppliers = 0;

  num totalSales = 0;
  num totalProfit = 0;
  num totalPurchase = 0;

  num totalUnitSold = 0;
  num totalUnitPurchased = 0;

  Map<String, dynamic> selectedSupplier = {};
  List<Map<String, dynamic>> supplierData = []; // Selected product

  String searchField = ''; // Field to be searched

  int minThreshold = 10; //minimun threshold for the product

  @override
  void initState() {
    super.initState();
    getAllData();

    //selectedFilter = 'All';
  }

  getAllData() async {
    products = await ApiCall.getInventory();
    suppliers = await ApiCall.getSupplier();
    bills = await ApiCall.getOrders();
    purchases = await ApiCall.getStock();

    //print("--->");
    setState(() {
      products;
      suppliers;
      bills;
      purchases;
    });
    calculateMetrics(suppliers);
    setState(() {});
  }

  String fromatDate(String timestamp) {
    // Parse the string to a DateTime object
    DateTime dateTime = DateTime.parse(timestamp);
    // Format the DateTime object
    String formattedDateTime =
        '${DateFormat.yMMMMd().format(dateTime)} - (${DateFormat.jm().format(dateTime)})';
    return formattedDateTime;
  }

  //calculation of main metics
  void calculateMetrics(List<Map<String, dynamic>> supp) {
    totalSuppliers = getTotalSuppliers(supp);
    newSuppliers = getNewSuppliers(supp);

    // totalSales = getTotalSales(bills);
    // totalProfit = getTotalProfit(products);
    // totalUnitSold = getTotalUnitSold(bills);
    //supplierSalesAndProfit = getSupplierSalesAndProfit(bills, products);

    //print(totalSuppliers);

    // Calculate metrics for the selected product
    if (selectedSupplier.isNotEmpty) {
      //print("selected");
      supplierData = generateSupplierData(
          selectedSupplier["_id"], products, purchases, bills);
      totalSales = getTotalSalesOfSelectedSupplier(supplierData);
      totalProfit = getTotalProfitOfSelectedSupplier(supplierData);
      totalPurchase = getTotalPurchaseOfSelectedSupplier(supplierData);

      totalUnitSold = getTotalUnitSoldOfSelectedSupplier(supplierData);
      totalUnitPurchased =
          getTotalUnitPurchasedOfSelectedSupplier(supplierData);

      //print(supplierSalesAndProfit);
    }
  }

  int getNewSuppliers(List<Map<String, dynamic>> supp) {
    List<Map<String, dynamic>> tempFilteredPurchase = supp.where((bill) {
      return DateTime.parse(bill['createdOn']).month == DateTime.now().month &&
          DateTime.parse(bill['createdOn']).year == DateTime.now().year;
    }).toList();
    return tempFilteredPurchase.length;
  }

  int getTotalSuppliers(List<Map<String, dynamic>> supp) {
    // print(products.length);
    return supp.length;
  }

  num getTotalUnitSoldOfSelectedSupplier(List<Map<String, dynamic>> supData) {
    num totalSales = 0;
    for (var data in supData) {
      totalSales += data["total unit sold"];
    }
    return totalSales;
  }

  num getTotalUnitPurchasedOfSelectedSupplier(
      List<Map<String, dynamic>> supData) {
    num totalSales = 0;
    for (var data in supData) {
      totalSales += data["total units purchased"];
    }
    return totalSales;
  }

  // Add helper methods to calculate metrics for the selected product
  num getTotalSalesOfSelectedSupplier(List<Map<String, dynamic>> supData) {
    num totalSales = 0;
    for (var data in supData) {
      totalSales += data["total sale"];
    }
    return totalSales;
  }

  num getTotalPurchaseOfSelectedSupplier(List<Map<String, dynamic>> supData) {
    num totalSales = 0;
    for (var data in supData) {
      totalSales += data["total amount purchased"];
    }
    return totalSales;
  }

  num getTotalProfitOfSelectedSupplier(List<Map<String, dynamic>> supData) {
    num totalSales = 0;
    for (var data in supData) {
      totalSales += data["total profit"];
    }
    return totalSales;
  }

  /////--------get supplier data----------

  List<Map<String, dynamic>> generateSupplierData(
      String supplierId,
      List<Map<String, dynamic>> products,
      List<Map<String, dynamic>> purchases,
      List<Map<String, dynamic>> bills) {
    Map<String, dynamic> supplier = suppliers.firstWhere(
        (supplier) => supplier['_id'] == supplierId,
        orElse: () => {"name": null});

    if (supplier["name"] == null) {
      return [];
    }

    List<Map<String, dynamic>> supplierData = [];

    for (var productData in supplier['products']) {
      Map<String, dynamic> product = products.firstWhere(
          (product) => product['_id'] == productData['product'],
          orElse: () => {"name": null});

      if (product["name"] != null) {
        num totalUnitSold = 0;
        num totalSale = 0;
        num totalProfit = 0;

        // Calculate sales from bills
        for (var bill in bills) {
          for (var order in bill['order']) {
            if (order['product'] == product['_id'] &&
                order["supp"] == supplierId) {
              totalUnitSold += order['quantity'];
              totalSale += order['quantity'] * product['price'];
              totalProfit +=
                  (product['price'] - productData["inPrice"]) * totalUnitSold;
            }
          }
        }

        num totalUnitsPurchased = 0;
        num totalAmountPurchased = 0;

        // Calculate total units purchased and total amount purchased
        for (var purchase in purchases) {
          if (purchase["suppId"] == supplierId) {
            for (var purchaseProduct in purchase['products']) {
              if (purchaseProduct['product'] == product['_id']) {
                totalUnitsPurchased += purchaseProduct['inStock'];
                totalAmountPurchased +=
                    purchaseProduct['inStock'] * purchaseProduct['inPrice'];
              }
            }
          }
        }

        supplierData.add({
          'name': product['name'],
          '_id': product['_id'],
          'selling price': product['price'],
          'inPrice': productData['inPrice'],
          'total unit sold': totalUnitSold,
          'total sale': totalSale,
          'total profit': totalProfit,
          'total units purchased': totalUnitsPurchased,
          'total amount purchased': totalAmountPurchased,
        });
      }
    }

    return supplierData;
  }

// Function to get the unit sold for a supplier

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredSuppliers = suppliers.where((product) {
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

    calculateMetrics(filteredSuppliers);

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
                                Text('Total Suppliers: $totalSuppliers'),
                                // Implement logic to display total products count
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Low on Stock Card
                      Expanded(
                        child: Card(
                          color: const Color.fromARGB(255, 215, 255, 223),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('New Suppliers: $newSuppliers'),
                                // Implement logic to display low on stock count
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Out of Stock Card

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
                              child: Text('+ Add New Supplier'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  selectedSupplier.isNotEmpty
                      ? Row(
                          children: [
                            Expanded(
                              child: Card(
                                surfaceTintColor: Colors.white,
                                color: Color.fromARGB(255, 173, 232, 255),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                          'Total sales of selected supplier: $totalSales'),
                                      // Implement logic to display total products count
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                surfaceTintColor: Colors.white,
                                color: Color.fromARGB(255, 223, 255, 196),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                          'Total profit of selected supplier: $totalProfit'),
                                      // Implement logic to display total products count
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                surfaceTintColor: Colors.white,
                                color: Color.fromARGB(255, 255, 240, 190),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                          'Total purchase of selected dupplier: $totalPurchase'),
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
                        decoration: const BoxDecoration(color: Colors.white),
                        columns: const [
                          DataColumn(label: Text('Name/ID')),
                          DataColumn(label: Text('Phone')),
                          DataColumn(label: Text('Products')),
                          DataColumn(label: Text('Address')),
                          DataColumn(label: Text('Created On')),
                        ],
                        rows: filteredSuppliers.map((data) {
                          return DataRow(
                            color:
                                MaterialStateProperty.all<Color>(Colors.white),
                            onSelectChanged: (selected) {
                              setState(() {
                                selectedSupplier = data;
                              });
                              calculateMetrics(filteredSuppliers);
                            },
                            cells: [
                              DataCell(
                                  Text('${data['name']}\n(${data['_id']})')),
                              DataCell(Text('${data['phone']}')),
                              DataCell(Text('${data['products'].length}')),
                              DataCell(Text('${data['address']}')),
                              DataCell(Text(fromatDate(data['createdOn']))),
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
                      if (selectedSupplier.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Implement logic for editing product
                              },
                              child: const Text('Edit Supplier'),
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
                              text: '${selectedSupplier["name"]}',
                              style: AppTextStyles.headingLight)
                        ])),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                            text:
                                TextSpan(style: AppTextStyles.body, children: [
                          const TextSpan(text: "phone (+91):   "),
                          TextSpan(
                              text: '${selectedSupplier["phone"]}',
                              style: AppTextStyles.headingLight)
                        ])),
                        const Divider(),

                        Text(
                          '_id:   ${selectedSupplier["_id"]}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'address:   ${selectedSupplier["address"]}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'createdOn: ${fromatDate(selectedSupplier["createdOn"])}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'updatedOn: ${fromatDate(selectedSupplier["updatedOn"])}',
                          style: AppTextStyles.body,
                        ),
                        const Divider(),
                        Text(
                          'total Products:  ${selectedSupplier["products"].length}',
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
                          dataRowMaxHeight: 120,
                          columns: const <DataColumn>[
                            DataColumn(
                              label: Text('prduct'),
                            ),
                            DataColumn(
                              label: Text('analysis'),
                            ),
                          ],
                          rows: supplierData.map<DataRow>((data) {
                            //print(data[0]["name"]);
                            //print(supplierData);
                            return DataRow(
                              //selected: fr,
                              cells: <DataCell>[
                                DataCell(Text(
                                    'name: ${data["name"]}\nid: (${data["_id"]})\nSP: ${data["selling price"]}\nCP: ${data["inPrice"]}\nprofit: ${data["total profit"]}')),
                                DataCell(Text(
                                    'Salses: ${data["total sale"]}\nunit sold${data["total unit sold"]}\n\nPurchase: ${data["total amount purchased"]}\nUnits Purchased: ${data["total units purchased"]}')),
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
