import 'package:billf/widgets/utils.dart';
import 'package:billf/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/apicall.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  List<Map<String, dynamic>> products = [
    // Your product array here
  ];

  List<Map<String, dynamic>> suppliers = [
    // Your supplier array here
  ];

  List<Map<String, dynamic>> purchases = [
    // Your bill array here
  ];

  int totalBills = 0;
  int totalInvoices = 0;
  int totalChallans = 0;
  num totalSales = 0;
  num totalUnitSold = 0;

  int totalPurchases = 0;
  num totalAmountSpend = 0;
  num totalStockBought = 0;

  Map<String, dynamic> selectedPurchase = {}; // Selected product

  String searchField = ''; // Field to be searched

  int minThreshold = 10; //minimun threshold for the product

  List<Map<String, dynamic>> filteredPurchases = [];

  //dates for date filter
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedFilter;

  @override
  void initState() {
    super.initState();
    getAllData();

    //applyFilter();
  }

  getAllData() async {
    List<Map<String, dynamic>> j = await ApiCall.getInventory();
    List<Map<String, dynamic>> sup = await ApiCall.getSupplier();
    List<Map<String, dynamic>> b = await ApiCall.getStock();
    //print("--->");
    setState(() {
      products = j;
      suppliers = sup;
      purchases = b;
    });
    //print(purchases);
    calculateMetrics(purchases);
    fromDate = DateTime.now().subtract(const Duration(days: 1));
    toDate = DateTime.now();
    selectedFilter = 'All';

    applyFilter(purchases);
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
  void calculateMetrics(List<Map<String, dynamic>> ps) {
    totalPurchases = getTotalPurchases(ps);
    totalAmountSpend = getTotalSales(ps);
    totalStockBought = getTotalUnitSold(ps);

    //supplierSalesAndProfit = getSupplierSalesAndProfit(purchases, products);

    //print(totalProducts);

    // Calculate metrics for the selected product
  }

  int getTotalPurchases(List<Map<String, dynamic>> purchases) {
    // print(products.length);
    return purchases.length;
  }

  num getTotalUnitSold(List<Map<String, dynamic>> purchases) {
    num total = 0;
    for (var purchase in purchases) {
      for (var product in purchase['products']) {
        total += product['inStock'];
      }
    }
    return total;
  }

  num getTotalSales(List<Map<String, dynamic>> purchases) {
    num total = 0;
    for (var purchase in purchases) {
      total += purchase['total'];
    }

    return total;
  }

  // Add helper methods to calculate metrics for the selected product
  findProductFromId(String id) {
    for (var product in products) {
      if (product["_id"] == id) {
        return product;
      }
    }
    return {"name": "no product", "price": "no product"};
  }

  findSupplierNameFromId(String id) {
    for (var supplier in suppliers) {
      if (supplier["_id"] == id) {
        return supplier;
      }
    }
    return {"name": "no product"};
  }

  void applyFilter(purchases) {
    if (selectedFilter == 'All') {
      setState(() {
        filteredPurchases = purchases;
      });
      return;
    }
    List<Map<String, dynamic>> tempFilteredPurchase = purchases.where((bill) {
      return DateTime.parse(bill['createdOn']).isAfter(fromDate!) &&
          DateTime.parse(bill['createdOn'])
              .isBefore(toDate!.add(const Duration(days: 1)));
    }).toList();

    switch (selectedFilter) {
      case 'Today':
        tempFilteredPurchase = tempFilteredPurchase.where((bill) {
          return DateTime.parse(bill['createdOn']).day == DateTime.now().day;
        }).toList();
        break;
      case 'This Week':
        tempFilteredPurchase = tempFilteredPurchase.where((bill) {
          return DateTime.parse(bill['createdOn']).isAfter(DateTime.now()
                  .subtract(Duration(days: DateTime.now().weekday))) &&
              DateTime.parse(bill['createdOn']).isBefore(DateTime.now().add(
                  Duration(
                      days: DateTime.daysPerWeek - DateTime.now().weekday)));
        }).toList();
        break;
      case 'This Month':
        tempFilteredPurchase = tempFilteredPurchase.where((bill) {
          return DateTime.parse(bill['createdOn']).month ==
                  DateTime.now().month &&
              DateTime.parse(bill['createdOn']).year == DateTime.now().year;
        }).toList();
        break;
      case 'This Year':
        tempFilteredPurchase = tempFilteredPurchase.where((bill) {
          return DateTime.parse(bill['createdOn']).year == DateTime.now().year;
        }).toList();
        break;
      default:
        break;
    }

    setState(() {
      filteredPurchases = tempFilteredPurchase;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sfilteredPurchases =
        filteredPurchases.where((product) {
      // Check if the search field is empty or null, return true to include all products

      if (searchField.isEmpty) {
        return true;
      }
      // Check if the product name matches the search field
      return product[searchField.split(":")[0]]
          .toString()
          .replaceAll(RegExp(r'\s+'), '')
          .toLowerCase()
          .contains(searchField
              .split(":")[searchField.split(":").length - 1]
              .replaceAll(RegExp(r'\s+'), '')
              .toString()
              .toLowerCase());
    }).toList();
    calculateMetrics(sfilteredPurchases);
    //print("running..");
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
                      hintText: 'Search Product',
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
                  Row(
                    children: [
                      if (selectedFilter == 'Custom') ...[
                        const Text('From: '),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: fromDate!,
                              firstDate: DateTime(2015, 8),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != fromDate) {
                              setState(() {
                                fromDate = picked;
                              });
                            }
                          },
                          child: Text(fromDate.toString().split(' ')[0]),
                        ),
                        const Text('To: '),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: toDate!,
                              firstDate: DateTime(2015, 8),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != toDate) {
                              setState(() {
                                toDate = picked;
                              });
                            }
                          },
                          child: Text('${toDate.toString().split(' ')[0]}'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            applyFilter(purchases);
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blueGrey),
                              surfaceTintColor:
                                  MaterialStateProperty.all(Colors.white),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white)),
                          child: const Text('Apply Filter'),
                        ),
                      ],
                      Expanded(child: Container()),
                      DropdownButton<String>(
                        value: selectedFilter,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedFilter = newValue;
                              applyFilter(purchases);
                              // Apply logic to set fromDate and toDate based on the selected filter
                              // For demonstration purposes, just updating fromDate and toDate to yesterday and today
                            });
                          }
                        },
                        items: <String>[
                          'All',
                          'Custom',
                          'Today',
                          'This Week',
                          'This Month',
                          'This Year'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Metrics Cards
                  Row(children: [
                    // Total Products Card
                    Expanded(
                      child: Card(
                        surfaceTintColor: Colors.white,
                        color: Color.fromARGB(255, 255, 255, 255),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Total purchases: $totalPurchases'),
                              // Implement logic to display total products count
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Low on Stock Card
                    Expanded(
                      child: Card(
                        surfaceTintColor: Colors.white,
                        color: Color.fromARGB(255, 207, 253, 255),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Total amount spend: $totalAmountSpend'),
                              // Implement logic to display low on stock count
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Out of Stock Card
                    Expanded(
                      child: Card(
                        surfaceTintColor: Color.fromARGB(255, 241, 255, 221),
                        color: Color.fromARGB(255, 250, 255, 207),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Total Unit Purchased: $totalStockBought'),
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
                            child: Text('+ Add New Stock'),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(
                    height: 20,
                  ),
                  // Table displaying product data
                  Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        decoration: const BoxDecoration(color: Colors.white),
                        columns: const [
                          DataColumn(label: Text('Name/Phone')),
                          DataColumn(label: Text('Date/time')),
                          DataColumn(label: Text('Purchase Id')),
                          DataColumn(label: Text('Products')),
                          DataColumn(label: Text('Amount')),
                        ],
                        rows: sfilteredPurchases.map((purchase) {
                          Map<String, dynamic> supp =
                              findSupplierNameFromId(purchase["suppId"]);
                          return DataRow(
                            onSelectChanged: (selected) {
                              setState(() {
                                selectedPurchase = purchase;
                                calculateMetrics(sfilteredPurchases);
                              });
                            },
                            cells: [
                              DataCell(
                                  Text('${supp['name']}\n(${supp['phone']})')),
                              DataCell(Text(fromatDate(purchase['createdOn']))),
                              DataCell(Text('${purchase['_id']}')),
                              DataCell(
                                  Text(purchase['products'].length.toString())),
                              DataCell(Text(purchase['total'].toString())),
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
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Details Section
                      if (selectedPurchase.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.white),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.deepPurple),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'print purchase',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        const Center(
                          child: Text(
                            'Purchase Details\n',
                            style: AppTextStyles.subHeading,
                          ),
                        ),

                        Center(
                          child: Text(
                            'Purchase Id: ${selectedPurchase["_id"]}',
                            style: AppTextStyles.body,
                          ),
                        ),
                        Text(
                            '\nname:  ${findSupplierNameFromId(selectedPurchase["suppId"])["name"]}',
                            style: AppTextStyles.body),
                        Text(
                            'phone:  ${findSupplierNameFromId(selectedPurchase["suppId"])["phone"]}',
                            style: AppTextStyles.body),

                        Text(
                          'created On: ${fromatDate(selectedPurchase["createdOn"])}',
                          style: AppTextStyles.body,
                        ),
                        Divider(),
                        Text(
                          'Total:  ${selectedPurchase["total"]}',
                          style: AppTextStyles.body,
                        ),
                        Divider(),
                        // Implement displaying product details

                        DataTable(
                          columns: const <DataColumn>[
                            DataColumn(
                              label: Text('name/id'),
                            ),
                            DataColumn(
                              label: Text('inPrice'),
                            ),
                            DataColumn(
                              label: Text('qunatity'),
                            ),
                          ],
                          rows:
                              selectedPurchase["products"].map<DataRow>((data) {
                            //print(data[0]["name"]);
                            Map<String, dynamic> product =
                                findProductFromId(data["product"]);

                            return DataRow(
                              //selected: fr,
                              cells: <DataCell>[
                                DataCell(Text(
                                    '${product["name"]}\n${product["_id"]}')),
                                DataCell(Text(data["inPrice"].toString())),
                                DataCell(Text("${data["inStock"]}"))
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
