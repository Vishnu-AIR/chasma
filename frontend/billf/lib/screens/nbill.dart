import 'package:billf/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import '../service/apicall.dart';
import '../widgets/widgets.dart';

class ICpage extends StatefulWidget {
  const ICpage({super.key});

  @override
  _ICpageState createState() => _ICpageState();
}

class _ICpageState extends State<ICpage> {
  static List<dynamic> _products = [];
  static List<dynamic> _supp = [];

  static List<String> _addedProducts = [];
  static Map<String, int> _productQuantity = {};
  double _totalPrice = 0.0;
  String _scannedData = '';

  late FocusNode _dropdownFocusNode;
  late FocusNode _dropdownFocusNode1;
  String _selectedBillType = 'Invoice';
  String _selectedCompany = 'Company 1';
  String _nameOfCustomer = '';
  String _phoneOfCustomer = '';
  String _stateOfCustomer = '';
  String _addressOfCustomer = '';

  final List<String> _billTypes = ['Invoice', 'Challan'];
  List<String> _companies = ['Company 1', 'Company 2'];

  @override
  void initState() {
    super.initState();
    // Listen for keyboard input events
    RawKeyboard.instance.addListener(_handleKeyEvent);
    for (var element in _addedProducts) {
      _totalPrice +=
          _products.firstWhere((p) => p['name'] == element)['price'] *
              _productQuantity[element];
    }
    esehi();
    _dropdownFocusNode = FocusNode();
    _dropdownFocusNode1 = FocusNode();
  }

  @override
  void dispose() {
    // Clean up listeners
    _dropdownFocusNode.dispose();
    _dropdownFocusNode1.dispose();
    RawKeyboard.instance.removeListener(_handleKeyEvent);

    super.dispose();
  }

  esehi() async {
    //print("--->");
    var j = await ApiCall.getSupplier();
    var p = await ApiCall.getInventory();

    setState(() {
      _supp = j;
      _products = p;
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

  // Handle keyboard input events
  void _handleKeyEvent(RawKeyEvent event) {
    // Check if the key event is a key down event and the key is a character key
    if (event is RawKeyDownEvent && event.character != null) {
      // Append the character to the scanned data
      setState(() {
        _scannedData += event.character!;
      });

      // Check if the character is the end of scan character (e.g., newline)
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        // Process the scanned data here
        _processScannedData(_scannedData);

        // Clear the scanned data for the next scan
        setState(() {
          _scannedData = '';
        });
      }
    } else if (event is RawKeyDownEvent && event.character == null) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        // Process the scanned data here
        _processScannedData(_scannedData);

        // Clear the scanned data for the next scan
        setState(() {
          _scannedData = '';
        });
      }
    }
  }

  // Process the scanned data
  void _processScannedData(String scannedData) {
    // Here, you can perform any necessary actions based on the scanned data
    developer.log('Scanned data: $scannedData');

    // For example, you can make an API call, update the UI, or perform any other logic
    // based on the scanned data.
    _addProduct(scannedData); // Assuming the scanned data is the product name
  }

  List<Map<String, dynamic>> getListOfSuppforProduct(id) {
    List<Map<String, dynamic>> sopList = [];
    for (var supp in _supp) {
      for (var product in supp["products"]) {
        if (product["product"] == id) {
          sopList.add(supp);
        }
      }
    }
    if (sopList.isEmpty) {
      return [
        {"name": "select supp"}
      ];
    }
    return sopList;
  }

  void _addProduct(String productName) {
    if (findKey(_products, "name", productName)["name"] != "#") {
      setState(() {
        if (!_addedProducts.contains(productName)) {
          _addedProducts.add(productName);
          _productQuantity[productName] = 1;
        } else {
          _productQuantity[productName] = _productQuantity[productName]! + 1;
        }
        _totalPrice +=
            _products.firstWhere((p) => p['name'] == productName)['price'];
      });
    } else {
      showAboutDialog(
          context: context,
          applicationName: "Bite Says",
          children: [
            const Text("No Such Product"),
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
                child: const Text("Add One"))
          ]);
      setState(() async {
        _scannedData = "";
        await esehi();
      });
    }
  }

  void _removeProduct(String productName, bool del) {
    setState(() {
      if (!del) {
        if (_productQuantity[productName]! > 1) {
          _productQuantity[productName] = _productQuantity[productName]! - 1;
        } else {
          _addedProducts.remove(productName);
          _productQuantity.remove(productName);
        }
        _totalPrice -=
            _products.firstWhere((p) => p['name'] == productName)['price'];
      } else {
        int nt =
            _products.firstWhere((p) => p['name'] == productName)['price'] *
                _productQuantity[productName];
        _addedProducts.remove(productName);
        _productQuantity.remove(productName);
        _totalPrice -= nt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
      appBar: TopBar(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _scannedData,
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Added Products:',
                      style: AppTextStyles.subHeading,
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _addedProducts.length,
                        itemBuilder: (context, index) {
                          String productName = _addedProducts[index];
                          int quantity = _productQuantity[productName]!;
                          num totalPrice = quantity *
                              _products.firstWhere(
                                  (p) => p['name'] == productName)['price'];
                          var thisSOP = getListOfSuppforProduct(
                              _products.firstWhere(
                                  (p) => p['name'] == productName)['_id']);
                          var selectedSupplier = thisSOP[0]["name"];
                          return Card(
                            surfaceTintColor: Colors.white,
                            color: Colors.white,
                            child: ListTile(
                              title: Text(
                                productName,
                                style: AppTextStyles.headingLight,
                              ),
                              subtitle: Text(
                                  'Quantity: $quantity\nPrice${_products.firstWhere((p) => p['name'] == productName)['price']}\nAmount: \$${totalPrice.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 300,
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        //labelText: 'Select Supplier',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50))),
                                      ),
                                      value:
                                          selectedSupplier, // Initially selected supplier

                                      //focusNode: _dropdownFocusNode,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedSupplier =
                                              newValue; // Update selected supplier
                                        });
                                        //FocusScope.of(context).unfocus();
                                        // _dropdownFocusNode.unfocus();
                                      },
                                      items: thisSOP
                                          .map<DropdownMenuItem<String>>(
                                              (supplier) {
                                        return DropdownMenuItem<String>(
                                          value: supplier['name'],
                                          child: Text(
                                            supplier['name'],
                                            style: AppTextStyles.body2,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () =>
                                            _removeProduct(productName, false),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () =>
                                            _addProduct(productName),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _removeProduct(productName, true),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(),
                    Text(
                      'Total Price: \$${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  RawKeyboard.instance.addListener(_handleKeyEvent);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedBillType,
                          onTap: () {
                            RawKeyboard.instance
                                .removeListener(_handleKeyEvent);
                          },
                          //focusNode: _dropdownFocusNode,
                          onChanged: (value) {
                            setState(() {
                              _selectedBillType = value!;
                            });
                            FocusScope.of(context).unfocus();
                          },
                          items: _billTypes.map((billType) {
                            return DropdownMenuItem(
                              value: billType,
                              child: Text(billType),
                            );
                          }).toList(),
                          decoration:
                              const InputDecoration(labelText: 'Type of Bill'),
                        ),
                        const SizedBox(height: 16.0),
                        DropdownButtonFormField<String>(
                          value: _selectedCompany,
                          onTap: () {
                            RawKeyboard.instance
                                .removeListener(_handleKeyEvent);
                          },
                          //focusNode: _dropdownFocusNode1,
                          onChanged: (value) {
                            setState(() {
                              _selectedCompany = value!;
                            });
                            FocusScope.of(context).unfocus();
                          },
                          items: _companies.map((company) {
                            return DropdownMenuItem(
                              value: company,
                              child: Text(company),
                            );
                          }).toList(),
                          decoration:
                              const InputDecoration(labelText: 'Company'),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Customer Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          onTap: () {
                            RawKeyboard.instance
                                .removeListener(_handleKeyEvent);
                          },
                          onChanged: (value) {
                            setState(() {
                              _nameOfCustomer = value;
                            });
                          },
                          decoration: const InputDecoration(
                              labelText: 'Name of Customer'),
                        ),
                        TextField(
                          onTap: () {
                            RawKeyboard.instance
                                .removeListener(_handleKeyEvent);
                          },
                          onChanged: (value) {
                            setState(() {
                              _phoneOfCustomer = value;
                            });
                          },
                          decoration: const InputDecoration(
                              labelText: 'Phone of Customer'),
                        ),
                        TextField(
                          onTap: () {
                            RawKeyboard.instance
                                .removeListener(_handleKeyEvent);
                          },
                          onChanged: (value) {
                            setState(() {
                              _stateOfCustomer = value;
                            });
                          },
                          decoration: const InputDecoration(
                              labelText: 'State of Customer'),
                        ),
                        TextField(
                          onTap: () {
                            RawKeyboard.instance
                                .removeListener(_handleKeyEvent);
                          },
                          onChanged: (value) {
                            setState(() {
                              _addressOfCustomer = value;
                            });
                          },
                          decoration: const InputDecoration(
                              labelText: 'Address of Customer'),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            // Perform form submission or validation here
                            print(_nameOfCustomer);
                            print(_phoneOfCustomer);
                            print(_stateOfCustomer);
                            print(_addressOfCustomer);

                            RawKeyboard.instance.addListener(_handleKeyEvent);
                          },
                          child: const Text('Checkout'),
                        ),
                        const Expanded(
                            child: Center(
                                child: Text("tap here to start scanning")))
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
