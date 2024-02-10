//import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'dart:html' as html;

class InvoiceDocument extends StatelessWidget {
  final String billType;
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String billId;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String date;
  final List<Map<String, dynamic>> products;
  final double total;

  InvoiceDocument({
    required this.billType,
    required this.companyName,
    required this.companyAddress,
    required this.companyPhone,
    required this.billId,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.date,
    required this.products,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pdf = pw.Document();
    //final font = pw.GoogleFonts.notoSans();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Center(child: pw.Text("TYPE: " + billType)),
            pw.Divider(),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('My Company Name'),
                      pw.Text('My Company Address'),
                      pw.Text('My Company Phone'),
                      pw.SizedBox(height: 24),
                      pw.Text('Bill ID: $billId'),
                    ],
                  ),
                ),
                pw.Divider(),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("To: " + customerName),
                      pw.Text('address: ' + customerAddress),
                      pw.Text('phone: ' + customerPhone),
                      pw.Text('GSTIN: '),
                      pw.SizedBox(height: 24),
                      pw.Text('Date: ${date.split("T")[0]}'),
                    ],
                  ),
                ),
              ],
            ),
            pw.Divider(),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GSTIN:'),
                  pw.Text('Place of Supply: '),
                ]),
            pw.Divider(),
            pw.SizedBox(height: 4),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(children: [
                  pw.Text('S/no.'),
                  pw.Text('Product'),
                  pw.Text('Quantity'),
                  pw.Text('List Price'),
                  pw.Text('Amount'),
                ]),
                for (var product in products)
                  pw.TableRow(children: [
                    pw.Text(products.indexOf(product).toString()),
                    pw.Text(product["name"]),
                    pw.Text(product["quantity"].toString()),
                    pw.Text(product["price"].toString()),
                    pw.Text(
                        (product["price"] * product["quantity"]).toString()),
                  ]),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('Party Last Balance: '),
                pw.Text('Total: $total'),
              ],
            ),
            pw.Divider(),
          ],
        ),
      ),
    );

    // return PdfPreview(
    //   build: (format) => pdf.save(),
    // );
    // pdf.save().then((List<int> bytes) {
    //   final file = File('invoice.pdf');
    //   file.writeAsBytesSync(bytes);

    //   // Display PDF preview
    //   PDFDocument.fromFile(file).then(
    //     (PDFDocument document) {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => PDFViewer(document: document),
    //         ),
    //       );
    //     },
    //   );
    // });
    pdf.save().then((List<int> bytes) {
      // Convert to Uint8List
      Uint8List uint8List = Uint8List.fromList(bytes);

      // Create a Blob from Uint8List
      final blob = html.Blob([uint8List]);

      // Create a URL for the Blob
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create an anchor element to trigger download
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..target = 'webbrowser'
        ..download = 'invoice.pdf' // Specify the desired file name
        ..click();

      // Revoke the URL to free up resources
      html.Url.revokeObjectUrl(url);
    });
    // pdf.save().then((List<int> bytes) {
    //   final file = File('invoice.pdf');
    //   file.writeAsBytesSync(bytes);
    // });

    // final file = File('invoice.pdf');
    // file.writeAsBytesSync(pdf.save());

    return Container();
  }
}
