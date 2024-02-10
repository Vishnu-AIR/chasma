import 'package:billf/widgets/printable.dart';
import 'package:billf/widgets/utils.dart';
import 'package:billf/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../service/apicall.dart';

class Bill extends StatefulWidget {
  @override
  _BillState createState() => _BillState();
}

class _BillState extends State<Bill> {
  TextEditingController barcodeController = TextEditingController();
  static List<Map<dynamic, dynamic>> scannedBarcodes = [];
  static List<int> quantity = [];

  static List<String> currSuppL = [];

  bool isBarcodeScanningMode = false;

  TextEditingController searchController = TextEditingController();
  List<DataRow> filteredRows = [];

  List<dynamic> products = [];
  List<dynamic> supp = [];

  List<Map<dynamic, dynamic>> proTB = [];

  List<String> items = ['invoice', 'challan'];
  String? ccn;
  int total = 0;
  int cntMi = 0;
  int ol = -1;

  TextEditingController _name = TextEditingController();
  TextEditingController _type = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _address = TextEditingController();

  FocusNode textFieldFocusNode = FocusNode();
  FocusNode rawKeyboardFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ccn = items[0];
    if (scannedBarcodes.length > 0) {
      getTotal();
    }
    esehi();
  }

  List<dynamic> findSup(String targetProductId) {
    List<dynamic> result = [];

    for (int i = 0; i < supp.length; i++) {
      List<dynamic> products = supp[i]["products"];

      for (int j = 0; j < products.length; j++) {
        if (products[j]["product"] == targetProductId) {
          result.add(supp[i]);
        }
      }
    }

    return result;
  }

  addQuantityToProduct(productList) {
    productList.forEach((product) {
      product['quantity'] = quantity[scannedBarcodes.indexOf(product)];
      proTB.add({
        "product": product["_id"],
        "quantity": quantity[scannedBarcodes.indexOf(product)]
      });
    });
  }

  getTotal() {
    var t = 0;
    for (var i = 0; i < scannedBarcodes.length; i++) {
      t = t + (scannedBarcodes[i]["price"] as int) * quantity[i];
    }
    setState(() {
      total = t;
    });
    //print(total);
  }

  esehi() async {
    //print("--->");
    var j = await ApiCall.getSupplier();
    var p = await ApiCall.getInventory();

    setState(() {
      supp = j;
      products = p;
    });
  }

  Map<dynamic, dynamic> findKey(list, key, value) {
    List<dynamic> prod = list;
    int index = prod.indexWhere((element) => element[key] == value);

    if (index == -1) {
      return {"name": "#"};
    }

    return prod[index];
  }

  onEnter(event) {
    var barcode = barcodeController.text;
    if (barcode.isNotEmpty) {
      setState(() {
        //print(findKey(products, "name", barcode.toString()));
        var pro128 = findKey(products, "name", barcode);
        if (pro128["name"] != "#") {
          print(pro128);
          if (scannedBarcodes.contains(pro128)) {
            quantity[scannedBarcodes.indexOf(pro128)]++;
          } else {
            print("###");
            scannedBarcodes.add(pro128);
            quantity.add(1);
            currSuppL.add(findSup(pro128["_id"])[0]);
          }
          getTotal();
        } else {
          showAboutDialog(
              context: context,
              applicationName: "Bite Says",
              children: [
                Text("No Such Product"),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductFormDialog()),
                        );
                      });
                    },
                    child: Text("Add One"))
              ]);
        }

        barcodeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
      appBar: TopBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (RawKeyEvent event) {
                          print("haha");
                          if (event.logicalKey == LogicalKeyboardKey.enter) {
                            setState(() {
                              onEnter(event);
                            });
                          }
                        },
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isBarcodeScanningMode = !isBarcodeScanningMode;
                            });
                          },
                          child: Container(
                            child: isBarcodeScanningMode
                                ? Text("scannning")
                                : Text("scanCodex"),
                          ),
                        ),

                        // child: TextField(
                        //   focusNode: textFieldFocusNode,
                        //   controller: barcodeController,
                        //   onEditingComplete: () {},
                        //   onSubmitted: (value){

                        //   },
                        //   decoration: const InputDecoration(
                        //       labelText: 'tap to scan an add product'),
                        // ),
                      ),
                      TextField(
                        focusNode: textFieldFocusNode,
                        controller: barcodeController,
                        onSubmitted: (String value) {
                          if (!isBarcodeScanningMode && value.isNotEmpty) {
                            // Process manual input
                            setState(() {
                              onEnter("event");
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Tap to scan or add product',
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      SingleChildScrollView(
                        child: DataTable(
                          showBottomBorder: true,
                          dataRowHeight: 100,
                          //showCheckboxColumn: false,
                          decoration: BoxDecoration(color: Colors.white),
                          columns: [
                            DataColumn(
                                label: Text(
                              'Itmes/Id',
                              style: AppTextStyles.body,
                            )),
                            DataColumn(
                                label: Text(
                              'price',
                              style: AppTextStyles.body,
                            )),
                            DataColumn(
                                label: Text(
                              'quantity',
                              style: AppTextStyles.body,
                            )),
                            DataColumn(
                                label: Text(
                              'remove',
                              style: AppTextStyles.body,
                            ))
                          ],
                          rows: scannedBarcodes.map((barcode) {
                            int pq = quantity[scannedBarcodes.indexOf(barcode)];

                            List<dynamic> thisPSL = findSup(barcode['_id']);

                            var currSupp = currSuppL.isNotEmpty
                                ? currSuppL[scannedBarcodes.indexOf(barcode)]
                                : null;

                            return DataRow(
                              selected: ol == scannedBarcodes.indexOf(barcode),
                              onSelectChanged: (selectedValue) {
                                setState(() {
                                  ol = scannedBarcodes.indexOf(barcode);
                                });
                              },
                              cells: [
                                DataCell(Column(
                                  children: [
                                    Text(barcode['name'] +
                                        "\n" +
                                        barcode['_id']),
                                    DropdownButton(
                                      hint: Text("no supp yet"),
                                      value: currSupp,
                                      items: thisPSL.map((value) {
                                        return DropdownMenuItem(
                                          value: value["name"].toString(),
                                          child: Text(value["name"].toString()),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        //print(newValue.toString());
                                        setState(() {
                                          currSuppL[scannedBarcodes.indexOf(
                                              barcode)] = newValue.toString();
                                        });
                                        print(currSuppL);
                                      },
                                    ),
                                  ],
                                )),
                                DataCell(Text(barcode['price'].toString())),
                                DataCell(Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          quantity[scannedBarcodes
                                              .indexOf(barcode)] = quantity[
                                                      scannedBarcodes
                                                          .indexOf(barcode)] >
                                                  0
                                              ? quantity[scannedBarcodes
                                                      .indexOf(barcode)] -
                                                  1
                                              : 0;
                                          getTotal();
                                          if (quantity[scannedBarcodes
                                                  .indexOf(barcode)] ==
                                              0) {
                                            quantity.removeAt(scannedBarcodes
                                                .indexOf(barcode));
                                            scannedBarcodes.remove(barcode);
                                          }
                                        });
                                      },
                                    ),
                                    Text(pq.toString()),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () => setState(() {
                                        quantity[
                                            scannedBarcodes.indexOf(barcode)]++;
                                        getTotal();
                                      }),
                                    ),
                                  ],
                                )),
                                DataCell(IconButton(
                                  onPressed: () {
                                    if (scannedBarcodes.contains(barcode)) {
                                      setState(() {
                                        quantity.removeAt(
                                            scannedBarcodes.indexOf(barcode));
                                        scannedBarcodes.remove(barcode);
                                        getTotal();
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    size: 20,
                                  ),
                                ))
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  width: 1, // Set the desired width of the vertical line
                  height: 500,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 4,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select Your Details"),
                      Container(
                        width: 200,
                        height: 64,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: DropdownButton<String>(
                          value: ccn, // Initial selected item
                          onChanged: (String? selectedItem) {
                            // Handle item selection here
                            setState(() {
                              ccn = selectedItem!;
                            });
                            //print('Selected Item: $selectedItem');
                          },
                          items: items
                              .map<DropdownMenuItem<String>>((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text("Enter Customer details"),
                      Container(
                        width: 300,
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _phone,
                          decoration: InputDecoration(
                            hintText: 'Phone',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF999999)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 300,
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _name,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF999999)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 300,
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _state,
                          decoration: InputDecoration(
                            hintText: 'State',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF999999)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 400,
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _address,
                          decoration: InputDecoration(
                            hintText: 'Address',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF999999)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Text(
                          "Total: " + total.toString(),
                          style: AppTextStyles.subHeading,
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            try {
                              addQuantityToProduct(scannedBarcodes);

                              ApiCall.postBill(
                                      _name.text,
                                      _phone.text,
                                      _type.text,
                                      _address.text + " : " + _state.text,
                                      proTB,
                                      total)
                                  .then((value) {
                                if (value["_id"] != null) {
                                  final invoice = InvoiceDocument(
                                    billType: ccn!,
                                    companyName: 'Your Company',
                                    companyAddress: 'Your Company Address',
                                    companyPhone: 'Your Company Phone',
                                    billId: value["_id"],
                                    customerName: _name.text,
                                    customerAddress: _address.text,
                                    customerPhone: _phone.text.toString(),
                                    date: value["createdOn"].toString(),
                                    products: List<Map<String, dynamic>>.from(
                                        scannedBarcodes),
                                    total: total.toDouble(),
                                  );
                                  invoice.build(context);
                                }
                              });

                              //print("----------->" + _billId.toString());
                            }

                            //dd
                            catch (e) {
                              print(e);
                            }
                          },
                          child: Text("Bill Invoice"))
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  filterRows() {}
}
