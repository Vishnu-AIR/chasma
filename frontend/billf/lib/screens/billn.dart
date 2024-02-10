import 'package:billf/widgets/utils.dart';
import 'package:billf/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/apicall.dart';
import '../widgets/printable.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  List<Map<String, dynamic>> products = [
    // Your product array here
  ];

  List<Map<String, dynamic>> suppliers = [
    // Your supplier array here
  ];

  List<Map<String, dynamic>> bills = [
    // Your bill array here
  ];

  int totalBills = 0;
  int totalInvoices = 0;
  int totalChallans = 0;
  num totalSales = 0;
  num totalUnitSold = 0;

  Map<String, dynamic> selectedBill = {}; // Selected product

  String searchField = ''; // Field to be searched

  int minThreshold = 10; //minimun threshold for the product

  List<Map<String, dynamic>> filteredBills = [];

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
    products = await ApiCall.getInventory();
    suppliers = await ApiCall.getSupplier();
    bills = await ApiCall.getOrders();
    //print("--->");
    setState(() {
      products;
      suppliers;
      bills;
    });

    //print(bills);
    calculateMetrics(bills);
    fromDate = DateTime.now().subtract(const Duration(days: 1));
    toDate = DateTime.now();
    selectedFilter = 'All';

    applyFilter(bills);
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
  void calculateMetrics(List<Map<String, dynamic>> bs) {
    totalBills = getTotalBills(bs);
    totalInvoices = getTotalInvoices(bs);
    totalChallans = getTotalChallans(bs);
    totalSales = getTotalSales(bs);
    totalUnitSold = getTotalUnitSold(bs);
    //supplierSalesAndProfit = getSupplierSalesAndProfit(bills, products);

    //print(totalProducts);

    // Calculate metrics for the selected product
  }

  int getTotalBills(List<Map<String, dynamic>> bills) {
    // print(products.length);
    return bills.length;
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

  num getTotalUnitSold(List<Map<String, dynamic>> bills) {
    num totalUnitSold = 0;
    for (var bill in bills) {
      for (var order in bill['order']) {
        totalUnitSold += order['quantity'];
      }
    }
    return totalUnitSold;
  }

  getTotalInvoices(bills) {
    num totalInvoice = 0;
    for (var bill in bills) {
      if (bill["type"] == "invoice") {
        totalInvoice++;
      }
    }
    return totalInvoice;
  }

  getTotalChallans(bills) {
    num totalChallan = 0;
    for (var bill in bills) {
      if (bill["type"] == "challan") {
        totalChallan++;
      }
    }
    return totalChallan;
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

  void applyFilter(bills) {
    if (selectedFilter == 'All') {
      setState(() {
        filteredBills = bills;
      });
      return;
    }
    List<Map<String, dynamic>> tempFilteredBills = bills.where((bill) {
      return DateTime.parse(bill['createdOn'])
              .isAfter(fromDate!.subtract(const Duration(days: 1))) &&
          DateTime.parse(bill['createdOn'])
              .isBefore(toDate!.add(const Duration(days: 1)));
    }).toList();

    switch (selectedFilter) {
      case 'Today':
        tempFilteredBills = tempFilteredBills.where((bill) {
          return DateTime.parse(bill['createdOn']).day == DateTime.now().day;
        }).toList();
        break;
      case 'This Week':
        tempFilteredBills = tempFilteredBills.where((bill) {
          return DateTime.parse(bill['createdOn']).isAfter(DateTime.now()
                  .subtract(Duration(days: DateTime.now().weekday))) &&
              DateTime.parse(bill['createdOn']).isBefore(DateTime.now().add(
                  Duration(
                      days: DateTime.daysPerWeek - DateTime.now().weekday)));
        }).toList();
        break;
      case 'This Month':
        tempFilteredBills = tempFilteredBills.where((bill) {
          return DateTime.parse(bill['createdOn']).month ==
                  DateTime.now().month &&
              DateTime.parse(bill['createdOn']).year == DateTime.now().year;
        }).toList();
        break;
      case 'This Year':
        tempFilteredBills = tempFilteredBills.where((bill) {
          return DateTime.parse(bill['createdOn']).year == DateTime.now().year;
        }).toList();
        break;
      default:
        break;
    }

    setState(() {
      filteredBills = tempFilteredBills;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sfilteredBills = filteredBills.where((product) {
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

    calculateMetrics(sfilteredBills);

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
                            applyFilter(bills);
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blueGrey),
                              surfaceTintColor:
                                  MaterialStateProperty.all(Colors.white),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white)),
                          child: const Text('Apply Filter'),
                        )
                      ],
                      Expanded(child: Container()),
                      DropdownButton<String>(
                        value: selectedFilter,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedFilter = newValue;
                              applyFilter(bills);
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
                        color: Color.fromARGB(255, 207, 240, 255),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Total: $totalBills'),
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
                        color: Color.fromARGB(255, 207, 240, 255),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Total Sales: $totalSales'),
                              // Implement logic to display low on stock count
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Out of Stock Card
                    Expanded(
                      child: Card(
                        surfaceTintColor: Colors.white,
                        color: Color.fromARGB(255, 207, 240, 255),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Total Unit Sold: $totalUnitSold'),
                              // Implement logic to display out of stock count
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  'Invoic / challan: $totalInvoices / $totalChallans'),
                              // Implement logic to display out of stock count
                            ],
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
                          DataColumn(label: Text('bill Id')),
                          DataColumn(label: Text('total')),
                          DataColumn(label: Text('Date/time')),
                          DataColumn(label: Text('Type')),
                        ],
                        rows: sfilteredBills.map((bill) {
                          return DataRow(
                            onSelectChanged: (selected) {
                              setState(() {
                                selectedBill = bill;
                              });
                              //calculateMetrics(filteredBills);
                            },
                            cells: [
                              DataCell(
                                  Text('${bill['name']}\n(${bill['phone']})')),
                              DataCell(Text('${bill['_id']}')),
                              DataCell(Text('${bill['total']}')),
                              DataCell(Text(fromatDate(bill['createdOn']))),
                              DataCell(Text(bill['type'])),
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
                      if (selectedBill.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Implement logic for editing product
                              },
                              child: const Text('change to Invoice'),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.white),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.deepPurple),
                              ),
                              onPressed: () {
                                List<Map<String, dynamic>> newOrder = [];
                                for (var data in selectedBill["order"]) {
                                  Map<String, dynamic> product =
                                      findProductFromId(data["product"]);

                                  newOrder.add({
                                    "name": product["name"],
                                    "quantity": data["quantity"],
                                    "price": product["price"]
                                  });
                                }

                                //print(newOrder);

                                // Implement logic for editing product
                                final invoice = InvoiceDocument(
                                  billType: selectedBill["type"],
                                  companyName: 'Your Company',
                                  companyAddress: 'Your Company Address',
                                  companyPhone: 'Your Company Phone',
                                  billId: selectedBill["_id"],
                                  customerName: selectedBill["name"],
                                  customerAddress: "Address coming soon",
                                  customerPhone:
                                      selectedBill["phone"].toString(),
                                  date: fromatDate(selectedBill["createdOn"]),
                                  products: newOrder,
                                  total: selectedBill["total"],
                                );
                                invoice.build(context);
                              },
                              child: const Text(
                                'print Bill',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const Center(
                          child: Text(
                            'Order Details\n',
                            style: AppTextStyles.subHeading,
                          ),
                        ),

                        Center(
                          child: Text(
                            'Bill Id: ${selectedBill["_id"]}',
                            style: AppTextStyles.body,
                          ),
                        ),
                        Text('\nname:  ${selectedBill["name"]}',
                            style: AppTextStyles.body),
                        Text('phone:  ${selectedBill["phone"]}',
                            style: AppTextStyles.body),
                        Text('phone:  ${selectedBill["address"]}',
                            style: AppTextStyles.body),
                        Text(
                          'type: ${selectedBill["type"]}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'created On: ${fromatDate(selectedBill["createdOn"])}',
                          style: AppTextStyles.body,
                        ),
                        Divider(),
                        Text(
                          'Total:  ${selectedBill["total"]}',
                          style: AppTextStyles.body,
                        ),
                        Divider(),
                        // Implement displaying product details

                        DataTable(
                          columns: const <DataColumn>[
                            DataColumn(
                              label: Text('name/id/supp'),
                            ),
                            DataColumn(
                              label: Text('Price'),
                            ),
                            DataColumn(
                              label: Text('qunatity'),
                            ),
                            DataColumn(
                              label: Text('supplier'),
                            ),
                          ],
                          rows: selectedBill["order"].map<DataRow>((data) {
                            //print(data[0]["name"]);
                            Map<String, dynamic> product =
                                findProductFromId(data["product"]);
                            Map<String, dynamic> supp =
                                findSupplierNameFromId(data["supp"]);
                            return DataRow(
                              //selected: fr,
                              cells: <DataCell>[
                                DataCell(Text(
                                    '${product["name"]}\n${product["_id"]}')),
                                DataCell(Text(product["price"].toString())),
                                DataCell(Text("${data["quantity"]}")),
                                DataCell(Text("${supp["name"]}"))
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
