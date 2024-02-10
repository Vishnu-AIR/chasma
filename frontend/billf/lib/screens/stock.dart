import 'package:flutter/material.dart';

import '../service/apicall.dart';
import '../widgets/utils.dart';
import '../widgets/widgets.dart';

class Stocks extends StatefulWidget {
  const Stocks({super.key});

  @override
  State<Stocks> createState() => _StocksState();
}

class _StocksState extends State<Stocks> {
  String selectedValue = 'Today';
  List<String> options = ['today', 'week', 'month'];

  TextEditingController searchController = TextEditingController();
  List<DataRow> filteredRows = [];

  List<dynamic> order = [];
  List<dynamic> products = [];
  List<dynamic> highlight = [];
  int ol = -1;
  bool fr = true;

  @override
  void initState() {
    super.initState();

    esehi();
  }

  esehi() async {
    //print("--->");
    var j = await ApiCall.getStock();
    var p = await ApiCall.getInventory();

    setState(() {
      order = j;
      products = p;

      // highlight.add("Total Order\n" + order.length.toString());

      // for (var i = 0; i < order.length; i++) {
      //   totalSale = totalSale + order[i]["total"];
      //   //print(order[i]["order"].length);
      //   for (int ss = 0; ss < order[i]["order"].length; ss++) {
      //     unit = unit + order[i]["order"][ss]["quantity"];
      //   }
      // }
      // highlight.add("Total Sale\n" + totalSale.toString());
      // highlight.add("Unit Sold\n" + unit.toString());
    });
  }

  Map<dynamic, dynamic> findKey(list, key, value) {
    List<dynamic> prod = list;
    int index = prod.indexWhere((element) => element[key] == value);

    return prod[index];
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
                              "Highligt",
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
                      // SizedBox(
                      //   height: 172,
                      //   //color: Colors.red,
                      //   child: ListView.builder(
                      //       itemCount: highlight.length,
                      //       scrollDirection: Axis.horizontal,
                      //       itemBuilder: (context, index) {
                      //         return Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: SquareBox(text: highlight[index]),
                      //         );
                      //       }),
                      // ),
                      Divider(),
                      DataTable(
                        decoration: BoxDecoration(color: Colors.white),
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text('S/No.'),
                          ),
                          DataColumn(
                            label: Text('_id'),
                          ),
                          DataColumn(
                            label: Text('Supp_id'),
                          ),
                          DataColumn(
                            label: Text('date'),
                          ),
                          DataColumn(
                            label: Text('total'),
                          ),
                        ],
                        rows: order.map((data) {
                          return DataRow(
                            //selected: fr,
                            selected: order.indexOf(data) == ol,
                            onSelectChanged: (selected) {
                              // Handle row tap
                              //fr = !fr;
                              print(order.indexOf(data));
                              setState(() {
                                ol = order.indexOf(data);
                              });
                              print(order.length);
                              //order.indexOf(data);
                              // print('Row tapped: ${data['_id']}');
                            },
                            cells: <DataCell>[
                              DataCell(
                                  Text((order.indexOf(data) + 1).toString())),
                              DataCell(Text(
                                data['_id'] ?? '',
                                style: AppTextStyles.body2,
                              )),
                              DataCell(Text(
                                data['suppId'] ?? '',
                                style: AppTextStyles.body2,
                              )),
                              DataCell(Text(
                                data['createdOn'] ?? '',
                                style: AppTextStyles.body2,
                              )),
                              DataCell(Text(data['total'].toString())),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddStock()));
                              },
                              //style: ButtonStyle(),
                              child: Text("AddStock")),
                          ElevatedButton(
                              onPressed: () {},
                              //style: ButtonStyle(),
                              child: Text("Print Bill")),
                        ],
                      ),
                      Divider(),
                      SizedBox(
                        height: 24,
                      ),
                      ol == -1
                          ? Text("select a stock")
                          : SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order[ol]["_id"],
                                    style: AppTextStyles.body,
                                  ),
                                  Text(order[ol]["suppId"]),
                                  Text(order[ol]["createdOn"]),
                                  DataTable(
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text('name/id'),
                                      ),
                                      DataColumn(
                                        label: Text('Inprice'),
                                      ),
                                      DataColumn(
                                        label: Text('quantity'),
                                      ),
                                    ],
                                    rows: order[ol]["products"]
                                        .map<DataRow>((data) {
                                      print(ol);
                                      //print(data);
                                      return DataRow(
                                        //selected: fr,
                                        cells: <DataCell>[
                                          DataCell(Text(findKey(products, "_id",
                                                      data['product'])["name"] +
                                                  "\n" +
                                                  data['product'] ??
                                              '')),
                                          DataCell(
                                              Text(data['inPrice'].toString())),
                                          DataCell(
                                              Text(data['inStock'].toString())),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                  Divider(),
                                  Text(
                                    " total:" + order[ol]["total"].toString(),
                                    style: AppTextStyles.subHeading,
                                  ),
                                ],
                              ),
                            )
                    ],
                  ))
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
