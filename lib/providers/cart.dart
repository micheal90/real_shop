import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};
  //get map of items
  Map<String, CartItem> get items {
    return {..._items};
  }

  //get count of items
  int get itemCount {
    return _items.length;
  }

  //get price of all products in cart
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity * cartItem.price; //multiply quantity by price
    });
    return total;
  }

  //function to add item to _items(cart)
  void addItem(String productId, String title, double price) {
    //if product already found in _items
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (exsistingCartItem) => CartItem(
                //update only quantity+1
                id: exsistingCartItem.id,
                title: exsistingCartItem.title,
                quantity: exsistingCartItem.quantity + 1,
                price: exsistingCartItem.price,
              ));
    } else {
      //product not found in _items
      _items.putIfAbsent(
          //putIfAbsent mean is add item if not exist
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price));
    }
    notifyListeners();
  }

  //function to remove item from _items
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  //function to remove one item if found quantity
  void removeSingelItem(String productId) {
    if (!_items.containsKey(productId)) {
      //if not found item in _items
      return;
    }
    if (_items[productId].quantity > 1) {
      //if more than 1 of item in cart
      _items.update(
          productId,
          (exsistingCartItem) => CartItem(
                //update only quantity-1
                id: exsistingCartItem.id,
                title: exsistingCartItem.title,
                quantity: exsistingCartItem.quantity - 1,
                price: exsistingCartItem.price,
              ));
    } else {
      //if only one item in cart
      _items.remove(productId);
    }
    notifyListeners();
  }

  //function to remove all items in cart
  void clear() {
    _items = {};
    notifyListeners();
  }
}
