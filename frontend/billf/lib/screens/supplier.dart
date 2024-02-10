import 'package:flutter/material.dart';

import '../service/apicall.dart';
import '../widgets/utils.dart';
import '../widgets/widgets.dart';

class Supplier extends StatefulWidget {
  const Supplier({super.key});

  @override
  State<Supplier> createState() => _SupplierState();
}

class _SupplierState extends State<Supplier> {
  String selectedValue = 'Today';
  List<String> options = ['today', 'week', 'month'];

  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredRows = [];

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
    var j = await ApiCall.getSupplier();
    var p = await ApiCall.getInventory();

    setState(() {
      order = j;
      products = p;
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
              Container(
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
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        // Update the filteredRows when the search text changes
                        if (value == "") {
                          filteredRows = [];
                        }
                        // else {
                        //   filterRows();
                        // }
                      },
                      onSubmitted: (value) {
                        filterRows();
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                        labelText: 'Search',
                        hintText: 'Enter name or age',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(43, 0, 0, 0)),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(
                            206, 255, 255, 255), // Set the background color
                      ),
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
                          label: Text('address'),
                        ),
                        DataColumn(
                          label: Text('products'),
                        ),
                      ],
                      rows: (!filteredRows.isEmpty ? filteredRows : order)
                          .map((data) {
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
                                    data["phone"].toString() ??
                                '')),
                            DataCell(Text(data['_id'] ?? '')),
                            DataCell(Text(data['address'] ?? '')),
                            DataCell(Text(data['products'].length.toString())),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
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
                            "Supplier Details",
                            style: AppTextStyles.headingLight,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SuppForm()),
                                );
                              },
                              //style: ButtonStyle(),
                              child: Text("Add Supplier")),
                          ElevatedButton(
                              onPressed: () {},
                              //style: ButtonStyle(),
                              child: Text("Edit Supplier")),
                        ],
                      ),
                      Divider(),
                      SizedBox(
                        height: 24,
                      ),
                      ol == -1
                          ? Text("select a Supplier")
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
                                  Text(order[ol]["address"]),
                                  Text(order[ol]["createdOn"]),
                                  DataTable(
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text('name/id'),
                                      ),
                                      DataColumn(
                                        label: Text('inPrice'),
                                      ),
                                    ],
                                    rows: order[ol]["products"]
                                        .map<DataRow>((data) {
                                      // print(data);
                                      return DataRow(
                                        //selected: fr,
                                        cells: <DataCell>[
                                          DataCell(Text(data["product"])),
                                          DataCell(
                                              Text(data["inPrice"].toString())),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                  Divider(),
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
    List<String> searchText = searchController.text.split(":");
    print(searchText);
    setState(() {
      filteredRows = order
          .where((row) => row[searchText[0]].toString().contains(searchText[1]))
          .toList();
    });
  }
}
