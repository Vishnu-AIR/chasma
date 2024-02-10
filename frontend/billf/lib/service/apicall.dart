import 'dart:convert';
import 'dart:js';

import 'package:http/http.dart' as http;

class ApiCall {
  static const String baseUrl = "http://localhost:9000/api";
  static const String ordersUrl = "/bills";
  static const String stockUrl = "/stocks";
  static const String supplierUrl = "/suppliers";
  static const String productUrl = "/products";
  static const String categoryUrl = "/categories";

  //--------- order --------

  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      var request = http.Request('GET', Uri.parse(baseUrl + ordersUrl));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        Map<String, dynamic> jsonMap = json.decode(body);

        return List<Map<String, dynamic>>.from(jsonMap["data"]);
      } else {
        return [
          {"messsage": response.statusCode}
        ];
      }
    } catch (e) {
      return [
        {"error": e}
      ];
    }
  }

  static postBill(name, phone, type, address, products, total) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', Uri.parse(baseUrl + ordersUrl));
      request.body = json.encode({
        "name": name,
        "phone": phone,
        "type": type,
        "address": address,
        "order": products,
        "total": total
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        Map<String, dynamic> jsonMap = json.decode(body);

        return jsonMap["data"];
      } else {
        return response.statusCode;
      }
    } catch (e) {
      return e;
    }
  }

  //--------- inventory --------

  static Future<List<Map<String, dynamic>>> getInventory() async {
    try {
      var request = http.Request('GET', Uri.parse(baseUrl + productUrl));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        Map<String, dynamic> jsonMap = json.decode(body);
        // List<Map<String, dynamic>> inv =
        //     List<Map<String, dynamic>>.from(jsonMap["data"]);

        return List<Map<String, dynamic>>.from(jsonMap["data"]);
      } else {
        return [
          {"message": response.statusCode}
        ];
      }
    } catch (e) {
      return [
        {"error--->": e}
      ];
    }
  }

  static postProduct(name, price, category, info) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', Uri.parse(baseUrl + productUrl));
      request.body = json.encode({"name": name, "price": price, "power": info});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        Map<String, dynamic> jsonMap = json.decode(body);

        return jsonMap["data"];
      } else {
        return response.statusCode;
      }
    } catch (e) {
      return e;
    }
  }

  //--------- supplier --------

  static Future<List<Map<String, dynamic>>> getSupplier() async {
    try {
      var request = http.Request('GET', Uri.parse(baseUrl + supplierUrl));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        Map<String, dynamic> jsonMap = json.decode(body);

        return List<Map<String, dynamic>>.from(jsonMap["data"]);
      } else {
        return [
          {"message": response.statusCode}
        ];
      }
    } catch (e) {
      return [
        {"error": e}
      ];
    }
  }

  static postSupp(name, phone, address, products) async {
    try {
      print(products);
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', Uri.parse(baseUrl + supplierUrl));
      request.body = json.encode({
        "name": name,
        "phone": phone,
        "address": address,
        "products": products,
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        Map<String, dynamic> jsonMap = json.decode(body);

        return jsonMap["data"];
      } else {
        return response.statusCode;
      }
    } catch (e) {
      return e;
    }
  }

  //--------- stocks --------

  static Future<List<Map<String, dynamic>>> getStock() async {
    try {
      var request = http.Request('GET', Uri.parse(baseUrl + stockUrl));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        Map<String, dynamic> jsonMap = json.decode(body);

        return List<Map<String, dynamic>>.from(jsonMap["data"]);
      } else {
        return [
          {"message": response.statusCode}
        ];
      }
    } catch (e) {
      return [
        {"error": e}
      ];
    }
  }

  static postStock(suppId, products, total) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', Uri.parse(baseUrl + stockUrl));
      request.body =
          json.encode({"suppId": suppId, "products": products, "total": total});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        Map<String, dynamic> jsonMap = json.decode(body);

        return jsonMap["data"];
      } else {
        return response.statusCode;
      }
    } catch (e) {
      return e;
    }
  }

  //--------- category --------

  static Future<List<Map<String, dynamic>>> getCategory() async {
    try {
      var request = http.Request('GET', Uri.parse(baseUrl + categoryUrl));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        Map<String, dynamic> jsonMap = json.decode(body);

        return List<Map<String, dynamic>>.from(jsonMap["data"]);
      } else {
        return [
          {"message": response.statusCode}
        ];
      }
    } catch (e) {
      return [
        {"error": e}
      ];
    }
  }
}
