import 'package:billf/widgets/utils.dart';
import 'package:billf/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/apicall.dart';

class CategoriessPage extends StatefulWidget {
  const CategoriessPage({super.key});

  @override
  State<CategoriessPage> createState() => _CategoriessPageState();
}

class _CategoriessPageState extends State<CategoriessPage> {
  List<Map<String, dynamic>> products = [
    // Your product array here
  ];

  List<Map<String, dynamic>> categories = [
    // Your bill array here
  ];

  num totalSales = 0;

  int totalCategories = 0;

  Map<String, dynamic> selectedCategory = {}; // Selected product

  String searchField = ''; // Field to be searched

  @override
  void initState() {
    super.initState();
    getAllData();

    //applyFilter();
  }

  getAllData() async {
    products = await ApiCall.getInventory();
    categories = await ApiCall.getCategory();

    //print("--->");
    setState(() {
      products;
      categories;
    });
    //print(categorys);
    calculateMetrics(categories);

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
    totalCategories = ps.length;

    //totalSales = getTotalSales(ps);

    //supplierSalesAndProfit = getSupplierSalesAndProfit(categorys, products);

    //print(totalProducts);

    // Calculate metrics for the selected product
  }

  num getTotalSales(List<Map<String, dynamic>> cats) {
    num total = 0;
    for (var cat in cats) {
      for (var pro in cat["products"]) {
        pro = findProductFromId(pro);
        total += pro["price"] * pro["outStock"];
      }
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

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sfilteredCategories =
        categories.where((product) {
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
    calculateMetrics(sfilteredCategories);

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
                              Text('Total categorys: $totalCategories'),
                              // Implement logic to display total products count
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Low on Stock Card

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
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromRGBO(242, 242, 242, 1)),
                            surfaceTintColor: MaterialStateProperty.all(
                                const Color.fromRGBO(255, 255, 255, 1)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('+ Add New Category'),
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
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Category Id')),
                          DataColumn(label: Text('Products')),
                        ],
                        rows: sfilteredCategories.map((category) {
                          //print(category["products"]);
                          return DataRow(
                            onSelectChanged: (selected) {
                              setState(() {
                                selectedCategory = category;
                                calculateMetrics(sfilteredCategories);
                              });
                            },
                            cells: [
                              DataCell(Text('${category['name']}')),
                              DataCell(Text('${category['_id']}')),
                              DataCell(
                                  Text(category['products'].length.toString())),
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
                      if (selectedCategory.isNotEmpty) ...[
                        const Center(
                          child: Text(
                            'Categories Details\n',
                            style: AppTextStyles.heading,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Categories Name:   ',
                              style: AppTextStyles.body,
                            ),
                            Text(
                              '${selectedCategory["name"]}',
                              style: AppTextStyles.subHeading,
                            ),
                          ],
                        ),
                        Center(
                          child: Text(
                            'Categories Id: ${selectedCategory["_id"]}',
                            style: AppTextStyles.body,
                          ),
                        ),

                        Divider(),
                        Text(
                          'Total Products:  ${selectedCategory["products"].length}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'Total Sale of this Category:  ${getTotalSales([
                                selectedCategory
                              ])}',
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
                              label: Text('Price'),
                            ),
                          ],
                          rows:
                              selectedCategory["products"].map<DataRow>((data) {
                            //print(data[0]["name"]);
                            Map<String, dynamic> product =
                                findProductFromId(data);

                            return DataRow(
                              //selected: fr,
                              cells: <DataCell>[
                                DataCell(Text(
                                    '${product["name"]}\n${product["_id"]}')),
                                DataCell(Text(product["price"].toString())),
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
