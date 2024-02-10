import 'package:billf/service/apicall.dart';
import 'package:billf/widgets/utils.dart';
import 'package:billf/widgets/widgets.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
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

    print(ol.toString() + "######");
  }

  esehi() async {
    //print("--->");
    var j = await ApiCall.getOrders();
    var p = await ApiCall.getInventory();
    num totalSale = 0;
    num unit = 0;

    setState(() {
      order = j;
      products = p;

      highlight.add("Total Order\n" + order.length.toString());

      for (var i = 0; i < order.length; i++) {
        totalSale = totalSale + order[i]["total"];
        //print(order[i]["order"].length);
        for (int ss = 0; ss < order[i]["order"].length; ss++) {
          unit = unit + order[i]["order"][ss]["quantity"];
        }
      }
      highlight.add("Total Sale\n" + totalSale.toString());
      highlight.add("Unit Sold\n" + unit.toString());
    });
  }

  Map<dynamic, dynamic> findKey(list, key, value) {
    List<dynamic> prod = list;
    int index = prod.indexWhere((element) => element[key] == value);

    return prod[index];
  }

  @override
  Widget build(BuildContext context) {
    print(ol);
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
              Container(
                width: MediaQuery.of(context).size.width * 0.62,
                child: SingleChildScrollView(
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
                      SizedBox(
                        height: 172,
                        //color: Colors.red,
                        child: ListView.builder(
                            itemCount: highlight.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SquareBox(text: highlight[index]),
                              );
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Orders",
                            style: AppTextStyles.subHeading,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                // Update the filteredRows when the search text changes
                                filterRows();
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 0),
                                labelText: 'Search',
                                hintText: 'Enter name or age',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                  borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255)),
                                ),
                                filled: true,
                                isDense: true,
                                fillColor: Color.fromARGB(206, 255, 255,
                                    255), // Set the background color
                              ),
                            ),
                          )
                        ],
                      ),
                      Divider(),
                      DataTable(
                        decoration: BoxDecoration(color: Colors.white),
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text('S/No.'),
                          ),
                          DataColumn(
                            label: Text('Name/Phone'),
                          ),
                          DataColumn(
                            label: Text('_id'),
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
                                      data["phone"].toString() ??
                                  '')),
                              DataCell(Text(data['_id'] ?? '')),
                              DataCell(Text(data['createdOn'] ?? '')),
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
                              onPressed: () {},
                              //style: ButtonStyle(),
                              child: Text("Print Bill")),
                        ],
                      ),
                      Divider(),
                      SizedBox(
                        height: 24,
                      ),
                      ol < 0
                          ? Text("select a bill")
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
                                  Text(order[ol]["name"]),
                                  Text(order[ol]["phone"].toString()),
                                  Text(order[ol]["createdOn"]),
                                  DataTable(
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text('name/id'),
                                      ),
                                      DataColumn(
                                        label: Text('price'),
                                      ),
                                      DataColumn(
                                        label: Text('quantity'),
                                      ),
                                    ],
                                    rows:
                                        order[ol]["order"].map<DataRow>((data) {
                                      //print(data);
                                      return DataRow(
                                        //selected: fr,
                                        cells: <DataCell>[
                                          DataCell(Text(findKey(products, "_id",
                                                      data['product'])["name"] +
                                                  "\n" +
                                                  data['product'] ??
                                              '')),
                                          DataCell(Text(findKey(products, "_id",
                                                  data['product'])["price"]
                                              .toString())),
                                          DataCell(Text(
                                              data['quantity'].toString())),
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
