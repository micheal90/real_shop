import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  //change value of isFavorite
  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  //function for change status of isFavorite
  Future<void> toggleFavoriteStatus(String token, String userId) async {
    //first change value locally and then change in database
    final oldSatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    //change in database
    final Uri url = Uri.tryParse(
        'https://shop-c23fe-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token');
    try {
      var response = await http.put(url, body: json.encode(isFavorite));
      //if happend error
      if (response.statusCode >= 400) {
        //return set old value by this method
        _setFavValue(oldSatus);
      }
    } catch (e) {
      //return set old value by this method
      _setFavValue(oldSatus);
    }
  }
}
