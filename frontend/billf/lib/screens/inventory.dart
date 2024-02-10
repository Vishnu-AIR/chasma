import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

import '../service/apicall.dart';
import '../widgets/utils.dart';
import '../widgets/widgets.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  String selectedValue = 'Today';
  List<String> options = ['today', 'week', 'month'];

  TextEditingController searchController = TextEditingController();
  List<DataRow> filteredRows = [];

  List<dynamic> order = [];
  List<dynamic> supp = [];
  int ol = -1;
  bool fr = true;

  @override
  void initState() {
    super.initState();

    esehi();
  }

  esehi() async {
    var j = await ApiCall.getInventory();
    var sup = await ApiCall.getSupplier();
    //print("--->");
    setState(() {
      order = j;
      supp = sup;
    });
  }

  List<dynamic> findSup(List<dynamic> suppliers, String targetProductId) {
    List<dynamic> result = [];

    for (int i = 0; i < suppliers.length; i++) {
      List<dynamic> products = suppliers[i]["products"];

      for (int j = 0; j < products.length; j++) {
        if (products[j]["product"] == targetProductId) {
          result.add([suppliers[i], j]);
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
      appBar: TopBar(),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.62,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Your Inventory",
                              style: AppTextStyles.subHeading,
                            ),
                            DropdownWidget<String>(
                              items: [
                                'Today',
                                'This week',
                                'This Month',
                                'Custom'
                              ],
                              selectedValue: selectedValue,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedValue = newValue;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 172,
                        //color: Colors.red,
                        child: ListView.builder(
                            itemCount: 1,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SquareBox(
                                    text: "Total Products\n" +
                                        order.length.toString()),
                              );
                            }),
                      ),
                      Divider(),
                      DataTable(
                        decoration: BoxDecoration(color: Colors.white),
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text('S/No.'),
                          ),
                          DataColumn(
                            label: Text('Name/Id'),
                          ),
                          DataColumn(
                            label: Text('Current_Stock'),
                          ),
                          DataColumn(
                            label: Text('Selling_Price'),
                          ),
                          DataColumn(
                            label: Text('updatedOn'),
                          ),
                        ],
                        rows: order.map((data) {
                          return DataRow(
                            //selected: fr,
                            selected: order.indexOf(data) == ol,
                            onSelectChanged: (selected) {
                              // Handle row tap
                              //fr = !fr;

                              setState(() {
                                ol = order.indexOf(data);
                              });
                              //order.indexOf(data);
                              // print('Row tapped: ${data['_id']}');
                            },
                            cells: <DataCell>[
                              DataCell(
                                  Text((order.indexOf(data) + 1).toString())),
                              DataCell(Text(data['name'] +
                                      "\n" +
                                      data["_id"].toString() ??
                                  '')),
                              DataCell(Text(data['currentStock'].toString())),
                              DataCell(Text(
                                data['price'].toString(),
                                style: AppTextStyles.body2,
                              )),
                              DataCell(Text(
                                data['updatedOn'].toString(),
                                style: AppTextStyles.body2,
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    //color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Product Wise Order",
                              style: AppTextStyles.headingLight,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ProductFormDialog();
                                    },
                                  );
                                },
                                //style: ButtonStyle(),
                                child: Text("Add Product")),
                          ],
                        ),
                        Divider(),
                        SizedBox(
                          height: 24,
                        ),
                        ol == -1
                            ? Text("select a product")
                            : SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      child: SfBarcodeGenerator(
                                        value: order[ol]["_id"],
                                        symbology: Code128(),
                                      ),
                                    ),
                                    Text(
                                      order[ol]["_id"],
                                      style: AppTextStyles.body,
                                    ),
                                    Text(order[ol]["name"]),
                                    Text(order[ol]["category"]),
                                    Text(order[ol]["createdOn"]),
                                    Text(order[ol]["updatedOn"]),
                                    Divider(),
                                    // Text(findSup(supp, order[ol]["id"])
                                    //     .toString()),
                                    DataTable(
                                      columns: const <DataColumn>[
                                        DataColumn(
                                          label: Text('name/id'),
                                        ),
                                        DataColumn(
                                          label: Text('inPrice'),
                                        ),
                                      ],
                                      rows: findSup(supp, order[ol]["_id"])
                                          .map<DataRow>((data) {
                                        //print(data[0]["name"]);
                                        return DataRow(
                                          //selected: fr,
                                          cells: <DataCell>[
                                            DataCell(Text(data[0]["name"] +
                                                "\n" +
                                                data[0]["_id"])),
                                            DataCell(Text(data[0]["products"]
                                                    [data[1]]["inPrice"]
                                                .toString()))
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                    Text(
                                      " selling_price:" +
                                          order[ol]["price"].toString(),
                                      style: AppTextStyles.subHeading,
                                    ),
                                  ],
                                ),
                              )
                      ],
                    )),
              )
            ],
          )),
    );
  }

  filterRows() {
    String searchText = searchController.text.toLowerCase();
    setState(() {
      filteredRows = order
          .where((row) =>
              row['name'].toLowerCase().contains(searchText) ||
              row['age'].toString().contains(searchText))
          .map((item) {
        return DataRow(
          cells: [
            DataCell(Text(item['id'].toString())),
            DataCell(Text(item['name'])),
            DataCell(Text(item['age'].toString())),
          ],
        );
      }).toList();
    });
  }
}
