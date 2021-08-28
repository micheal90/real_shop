import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:real_shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken;
  String userId;

  //used in proxy provider for get old data to provider
  void getData(String token, String uId, List<OrderItem> orders) {
    authToken = token;
    userId = uId;
    _orders = orders;
    notifyListeners();
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  //function to fetch orders from API database
  Future fetchOrders() async {
    final url = Uri.parse(
        'https://shop-c23fe-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;

      List<OrderItem> _loadedOrders = [];
      //asign all orders to _loadedOrders
      extractedData.forEach((orderId, orderData) {
        _loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(
              orderData['dateTime']), //convert string to DateTime
          products: (orderData['products'] as List<dynamic>)
              .map((prodId) => CartItem(
                    id: prodId['id'],
                    title: prodId['title'],
                    quantity: prodId['quantity'],
                    price: prodId['price'],
                  ))
              .toList(),
        ));
      });
      //reversed order(last order show first) and asign to _orders
      _orders = _loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  //function to add order in API and locally
  Future addOrder(List<CartItem> cartProduct, double total) async {
    final url = Uri.parse(
        'https://shop-c23fe-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      //add order top API database
      final timeStamp = DateTime.now();
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProduct
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price
                    })
                .toList()
          }));
      //add oder at index 0 for show first order
      //add order locally
      _orders.insert(
          0,
          OrderItem(
            id: json.decode(
                response.body)['name'], //fetch id from response generated
            amount: total,
            products: cartProduct,
            dateTime: timeStamp,
          ));
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
