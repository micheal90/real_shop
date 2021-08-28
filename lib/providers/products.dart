import 'dart:convert';

import 'package:flutter/material.dart';
import '../providers/product.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  String authToken;
  String userId;

  //used in proxy provider for get old data to provider
  void getData(String token, String uId, List<Product> products) {
    authToken = token;
    userId = uId;
    _items = products;
    notifyListeners();
  }

  //return list of items
  List<Product> get items {
    return [..._items];
  }

  //for return list of favorite items
  List<Product> get favoritesItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  //function for return product of id
  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // function that fetch products from database
  Future fetchProducts({bool filterByUser = false}) async {
    //filterString :if filterByUser is true make order by creatorId by userId
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://shop-c23fe-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      print(filterString);
      print(authToken);
      //get all products from database
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print(extractedData);
      if (extractedData == null) return;
      var urlFavorite = Uri.parse(
          'https://shop-c23fe-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      //get value if product of userId is favorite
      var favoriteRes = await http.get(urlFavorite);
      final favoriteData = json.decode(favoriteRes.body);

      List<Product> loadedProducts = [];
      //asign data of products to loadedProducts
      extractedData.forEach((prodId, prodData) {
        print(prodData['price'].runtimeType);
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'].toDouble() ,
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false));
      });
      //asign  loadedProducts to _items

      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      //throw e;
      print("error code:$e");
    }
  }

  //function for add product to database and localy
  Future addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-c23fe-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      //add products to database
      final response = await http.post(url,
          body: json.encode({
            'id': product.id,
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId //for know products of any user
          }));

      //add localy
      final newProduct = Product(
          id: json.decode(
              response.body)['name'], //set id generated from response bode
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  //function for update product by id
  Future updateProduct(String id, Product updatedProduct) async {
    final productIndex = _items.indexWhere(
        (prod) => prod.id == id); //fetch product index to be updated
    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://shop-c23fe-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      try {
        //updated product in database
        var response = await http.patch(url,
            body: json.encode({
              //not udated 'creatorId'and 'id' because is fixed

              'tilte': updatedProduct.title,
              'description': updatedProduct.description,
              'price': updatedProduct.price,
              'imageUrl': updatedProduct.imageUrl,
            }));
        //updated product localy
        _items[productIndex] = updatedProduct;
        notifyListeners();
      } catch (e) {
        print(e);
      }
    } else {
      print("not udated");
    }
  }

  //function for delete product by id
  Future deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shop-c23fe-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    //first deleted product localy and then deleted fron database
    final existingProductIndex = _items.indexWhere(
        (prod) => prod.id == id); //fetch index of product to be deleted
    var existingProduct = _items[existingProductIndex]; //fetch product
    _items.removeAt(existingProductIndex);
    notifyListeners();

    var response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpExceptionApp('Could not delete product.');
    }
    existingProduct = null; //set null after used in this function
  }
}
