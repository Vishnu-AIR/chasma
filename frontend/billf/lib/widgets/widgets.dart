import 'dart:math';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';

import 'package:billf/screens/billn.dart';

import 'package:billf/screens/inventoryn.dart';
import 'package:billf/screens/nbill.dart';

import 'package:billf/screens/stockn.dart';

import 'package:billf/screens/suppliersn.dart';
import 'package:billf/service/apicall.dart';
import 'package:billf/widgets/utils.dart';
import 'package:flutter/material.dart';

import '../screens/category.dart';

class SquareBox extends StatelessWidget {
  final String text;

  // Constructor with a required parameter
  const SquareBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Your widget's UI goes here
      width: 200,
      height: 150,
      padding: const EdgeInsets.all(16.0),
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.heading,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  TopBar({super.key});

  static List<bool> active = [true, false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 2,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      actions: <Widget>[
        const SizedBox(
          width: 200,
          child: Text("    Bite"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () {
                active[6] = true;
                active[5] = false;
                active[1] = false;
                active[0] = false;
                active[3] = false;
                active[4] = false;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PurchasesPage()),
                );
              },
              child: Text(
                "Dashborad",
                style:
                    TextStyle(color: active[6] ? Colors.purple : Colors.black),
              ),
            ),
            MaterialButton(
              onPressed: () {
                active[0] = true;
                active[1] = false;
                active[2] = false;
                active[3] = false;
                active[4] = false;
                active[5] = false;
                active[6] = false;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const BillsPage()),
                );
              },
              child: Text(
                "Orders",
                style:
                    TextStyle(color: active[0] ? Colors.purple : Colors.black),
              ),
            ),
            MaterialButton(
              onPressed: () {
                active[5] = true;
                active[1] = false;
                active[0] = false;
                active[3] = false;
                active[4] = false;
                active[6] = false;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PurchasesPage()),
                );
              },
              child: Text(
                "Purchases",
                style:
                    TextStyle(color: active[5] ? Colors.purple : Colors.black),
              ),
            ),
            MaterialButton(
              onPressed: () {
                active[1] = true;
                active[0] = false;
                active[2] = false;
                active[3] = false;
                active[4] = false;
                active[5] = false;
                active[6] = false;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InventoryPage()),
                );
              },
              child: Text(
                "Inventory",
                style:
                    TextStyle(color: active[1] ? Colors.purple : Colors.black),
              ),
            ),
            MaterialButton(
              onPressed: () {
                active[2] = true;
                active[1] = false;
                active[0] = false;
                active[3] = false;
                active[4] = false;
                active[5] = false;
                active[6] = false;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoriessPage()),
                );
              },
              child: Text(
                "Categories",
                style:
                    TextStyle(color: active[2] ? Colors.purple : Colors.black),
              ),
            ),
            MaterialButton(
              onPressed: () {
                active[3] = true;
                active[1] = false;
                active[2] = false;
                active[0] = false;
                active[4] = false;
                active[5] = false;
                active[6] = false;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SuppliersPage()),
                );
              },
              child: Text(
                "Suppliers",
                style:
                    TextStyle(color: active[3] ? Colors.purple : Colors.black),
              ),
            ),
            MaterialButton(
              onPressed: () {
                active[4] = true;
                active[1] = false;
                active[2] = false;
                active[3] = false;
                active[0] = false;
                active[5] = false;
                active[6] = false;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ICpage()),
                );
              },
              child: Text(
                "Bill",
                style:
                    TextStyle(color: active[4] ? Colors.purple : Colors.black),
              ),
            )
          ],
        ),
        Expanded(
          child: Container(),
          flex: 2,
        ),
        IconButton(onPressed: () {}, icon: Icon(Icons.person_2_rounded)),
        SizedBox(
          width: 80,
          child: Text("admin"),
        ),
      ],
    );
  }
}

class DropdownWidget<T> extends StatefulWidget {
  final List<T> items;
  final T selectedValue;
  final void Function(T)? onChanged;

  const DropdownWidget({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  _DropdownWidgetState<T> createState() => _DropdownWidgetState<T>();
}

class _DropdownWidgetState<T> extends State<DropdownWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: widget.selectedValue,
      items: widget.items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: (T? newValue) {
        widget.onChanged?.call(newValue as T);
      },
    );
  }
}

class ProductFormDialog extends StatefulWidget {
  @override
  _ProductFormDialogState createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _price = 0.0;
  String _category = 'Other';
  String _info = '';

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Books',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: AlertDialog(
        title: Text('Add Product'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!);
                },
              ),
              SizedBox(height: 8),
              DropdownWidget(
                  items: _categories,
                  selectedValue: _category,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _category = newValue;
                      });
                    }
                  }),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(labelText: 'Power'),
                maxLines: 1,
                onSaved: (value) {
                  _info = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Process the form data (e.g., save to database)
                print(
                    'Name: $_name, Price: $_price, Category: $_category, Info: $_info');

                await ApiCall.postProduct(_name, _price, _category, _info);
                // setState(() {});
                Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

class SuppForm extends StatefulWidget {
  const SuppForm({super.key});

  @override
  State<SuppForm> createState() => _SuppFormState();
}

class _SuppFormState extends State<SuppForm> {
  final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController supplierPhoneController = TextEditingController();
  final TextEditingController supplierStateController = TextEditingController();
  final TextEditingController supplierAddressController =
      TextEditingController();
  //final TextEditingController inPriceController = TextEditingController();

  AutoCompleteTextField? textField;

  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  List<dynamic> products = [];
  List<String> options = [];
  var selectedProduct = [];
  List<int> inPrice = [];

  List<dynamic> suppPro = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    esehi();
  }

  esehi() async {
    var j = await ApiCall.getInventory();
    setState(() {
      products = j;
      for (var element in products) {
        options.add(element["name"]);
      }
    });
  }

  void _handleSubmit() async {
    // Handle form submission logic here
    //print(selectedProduct);
    for (var i = 0; i < selectedProduct.length; i++) {
      suppPro.add(
        {"product": selectedProduct[i]["_id"], "inPrice": inPrice[i]},
      );
    }
    //selectedProduct.forEach((e) => );
    //print(suppPro);
    await ApiCall.postSupp(
            supplierNameController.text,
            supplierPhoneController.text,
            supplierAddressController.text +
                " : " +
                supplierStateController.text,
            suppPro)
        .then((v) => {print(v)});

    // print('Supplier Name: ${supplierNameController.text}');
    // print('Supplier Phone: ${supplierPhoneController.text}');
    // print('Supplier State: ${supplierStateController.text}');
    // print('Supplier Address: ${supplierAddressController.text}');
    // print('Selected Products: $suppPro');
  }

  String findClosestValue(String input) {
    String closestValue = options.first;
    int minDistance = levenshteinDistance(input, closestValue);
    for (String option in options) {
      int distance = levenshteinDistance(input, option);
      if (distance < minDistance) {
        minDistance = distance;
        closestValue = option;
      }
    }
    return closestValue;
  }

  int levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> previousRow =
        List<int>.generate(b.length + 1, (int index) => index);

    for (int i = 0; i < a.length; i++) {
      List<int> currentRow = [i + 1];
      for (int j = 0; j < b.length; j++) {
        int insertions = currentRow[j] + 1;
        int deletions = previousRow[j + 1] + 1;
        int substitutions = previousRow[j] + (a[i] != b[j] ? 1 : 0);
        currentRow.add(min(min(insertions, deletions), substitutions));
      }
      previousRow = currentRow;
    }

    return previousRow[b.length];
  }

  @override
  Widget build(BuildContext context) {
    //print(products?[0]["name"]);
    return products == null
        ? CircularProgressIndicator.adaptive()
        : Scaffold(
            backgroundColor: Color.fromRGBO(242, 242, 242, 1),
            appBar: AppBar(
              title: Text('Supplier Form'),
              automaticallyImplyLeading: true,
              backgroundColor: Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 24),
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextField(
                          controller: supplierNameController,
                          decoration: InputDecoration(
                            hintText: 'Supplier Name',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF999999)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ) //InputDecoration(labelText: 'Supplier Name'),
                          ),
                      SizedBox(
                        height: 16,
                      ),
                      TextField(
                        controller: supplierPhoneController,
                        decoration: InputDecoration(
                          hintText: 'Phone',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF999999)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ), //InputDecoration(labelText: 'Supplier Phone'),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextField(
                          controller: supplierStateController,
                          decoration: InputDecoration(
                            hintText: 'State',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF999999)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ) //InputDecoration(labelText: 'Supplier State'),
                          ),
                      SizedBox(
                        height: 16,
                      ),
                      TextField(
                          controller: supplierAddressController,
                          decoration: InputDecoration(
                            hintText: 'Address',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF999999)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ) //InputDecoration(labelText: 'Supplier Address'),
                          ),
                      SizedBox(height: 20),
                      DropdownButton(
                        hint: Text("select the product to add"),
                        value: null,
                        items: products!.map((value) {
                          return DropdownMenuItem(
                            value: value["name"],
                            child: Text(value["name"]),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (!selectedProduct.contains(products!.firstWhere(
                              (value) => value["name"] == newValue))) {
                            setState(() {
                              selectedProduct.add(products!.firstWhere(
                                  (value) => value["name"] == newValue));
                              inPrice.add(0);
                            });
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductFormDialog()));
                          },
                          //style: ButtonStyle(),
                          child: Text("Add Product")),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Handle form submission here
                          _handleSubmit();
                        },
                        child: Text('Submit'),
                      ),
                      DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text('name/id'),
                          ),
                          DataColumn(
                            label: Text('InPrice'),
                          ),
                        ],
                        rows: selectedProduct.map<DataRow>((data) {
                          TextEditingController inPriceController =
                              TextEditingController();
                          return DataRow(
                            //selected: fr,
                            // onSelectChanged: (value) {
                            //   print(inPrice);
                            //   //print(data);
                            //   //print(selectedProduct.indexOf(value));

                            //   inPrice[selectedProduct.indexOf(data)] =
                            //       int.parse(inPriceController.text);
                            // },
                            cells: <DataCell>[
                              DataCell(Text(
                                  data["name"] + "\n" + data["_id"] ?? '')),
                              DataCell(
                                TextField(
                                  controller: inPriceController,

                                  onChanged: (value) {
                                    inPrice[selectedProduct.indexOf(data)] =
                                        int.parse(value);
                                    print(inPrice);
                                  },
                                  decoration: InputDecoration(
                                    hintText:
                                        inPrice[selectedProduct.indexOf(data)]
                                            .toString(),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF999999)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                  ), //InputDecoration(labelText: 'Supplier Phone'),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

class AddStock extends StatefulWidget {
  const AddStock({super.key});

  @override
  State<AddStock> createState() => _AddStockState();
}

class _AddStockState extends State<AddStock> {
  List<dynamic>? products;
  List<dynamic>? supp;
  var selectedProduct = [];
  List<int> inPrice = [];
  List<int> inQ = [];
  String? selectedSupp = null;

  List<dynamic> stokPro = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    esehi();
  }

  esehi() async {
    var j = await ApiCall.getInventory();
    var hki = await ApiCall.getSupplier();
    setState(() {
      products = j;
      supp = hki;
      //selectedSupp = supp![0]["name"];
    });
  }

  _handelSumbit() async {
    var supId = supp!.firstWhere((element) => element["name"] == selectedSupp);

    for (var i = 0; i < selectedProduct.length; i++) {
      stokPro.add(
        {
          "product": selectedProduct[i]["_id"],
          "inStock": inQ[i],
          "inPrice": inPrice[i]
        },
      );
    }

    print(stokPro);
  }

  @override
  Widget build(BuildContext context) {
    return supp == null
        ? CircularProgressIndicator.adaptive()
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              title: Text("Add Stock"),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 24),
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButton(
                        hint: Text("select the supplier to add"),
                        value: selectedSupp,
                        items: supp!.map((value) {
                          return DropdownMenuItem(
                            value: value["name"],
                            child: Text(value["name"]),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedSupp = newValue.toString();
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SuppForm()));
                          },
                          //style: ButtonStyle(),
                          child: Text("Add Supplier")),
                      SizedBox(
                        height: 24,
                      ),
                      DropdownButton(
                        hint: Text("select the product to add"),
                        value: null,
                        items: products!.map((value) {
                          return DropdownMenuItem(
                            value: value["name"],
                            child: Text(value["name"]),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            if (!selectedProduct.contains(products!.firstWhere(
                                (value) => value["name"] == newValue))) {
                              selectedProduct.add(products!.firstWhere(
                                  (value) => value["name"] == newValue));
                              var lp =
                                  selectedProduct[selectedProduct.length - 1];
                              inQ.add(1);
                              try {
                                var gggh = ((supp!
                                    .firstWhere((element) =>
                                        element["name"] ==
                                        selectedSupp)["products"]
                                    .firstWhere((e) =>
                                        e["product"] == lp["_id"]))["inPrice"]);
                                inPrice.add(gggh);
                              } catch (e) {
                                inPrice.add(0);
                              }

                              //print(gggh);
                            } else {
                              inQ[selectedProduct.indexOf(products!.firstWhere(
                                  (value) => value["name"] == newValue))]++;
                            }
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductFormDialog()));
                          },
                          //style: ButtonStyle(),
                          child: Text("Add Product")),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Handle form submission here
                          _handelSumbit();
                        },
                        child: Text('Submit'),
                      ),
                      SizedBox(height: 20),
                      DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text('name/id'),
                          ),
                          DataColumn(
                            label: Text('InPrice'),
                          ),
                          DataColumn(
                            label: Text('InQ'),
                          ),
                        ],
                        rows: selectedProduct.map<DataRow>((data) {
                          TextEditingController inPriceController =
                              TextEditingController();
                          TextEditingController inQController =
                              TextEditingController();
                          return DataRow(
                            //selected: fr,
                            // onSelectChanged: (value) {
                            //   //print(inPrice);
                            //   //print(data);
                            //   //print(selectedProduct.indexOf(value));

                            //   inPrice[selectedProduct.indexOf(data)] =
                            //       int.parse(inPriceController.text);
                            // },
                            cells: <DataCell>[
                              DataCell(Text(
                                  data["name"] + "\n" + data["_id"] ?? '')),
                              DataCell(
                                TextField(
                                  controller: inPriceController,

                                  onChanged: (value) {
                                    inPrice[selectedProduct.indexOf(data)] =
                                        int.parse(value);
                                    //print(inPrice);
                                  },
                                  decoration: InputDecoration(
                                    hintText:
                                        inPrice[selectedProduct.indexOf(data)]
                                            .toString(),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF999999)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                  ), //InputDecoration(labelText: 'Supplier Phone'),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              DataCell(
                                TextField(
                                  controller: inQController,

                                  onChanged: (value) {
                                    inQ[selectedProduct.indexOf(data)] =
                                        int.parse(value);
                                    //print(inPrice);
                                  },
                                  decoration: InputDecoration(
                                    hintText: inQ[selectedProduct.indexOf(data)]
                                        .toString(),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF999999)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.purple),
                                    ),
                                  ), //InputDecoration(labelText: 'Supplier Phone'),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ]),
              ),
            ),
          );
  }
}
