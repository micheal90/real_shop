import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/cart.dart';
import 'package:real_shop/providers/products.dart';
import 'package:real_shop/screens/cart_screen.dart';
import 'package:real_shop/widgets/app_drawer.dart';
import 'package:real_shop/widgets/badge.dart';
import 'package:real_shop/widgets/products_grid.dart';

enum filterOption { All, favorites }

class ProductOverViewScreen extends StatefulWidget {
  @override
  _ProductOverViewScreenState createState() => _ProductOverViewScreenState();
}

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {
  var _isLoading = false;
  var _showOnlyFavorites = false;

  @override
  void initState() {
    _isLoading = true;
    Provider.of<Products>(context, listen: false)
        .fetchProducts()
        .then((value) => setState(() => _isLoading = false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Shop"),
        actions: [
          Consumer<Cart>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.routName),
            ),
            builder: (ctx, cart, child) =>
                Badge(child: child, value: cart.itemCount.toString()),
          ),
          PopupMenuButton(
            onSelected: (filterOption selectetVal) {
              setState(() {
                if (selectetVal == filterOption.favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Only Favorite"),
                value: filterOption.favorites,
              ),
              PopupMenuItem(
                child: Text("Show All"),
                value: filterOption.All,
              ),
            ],
          ),
        ],
      ),
      body: _isLoading == true
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showOnlyFavorites),
      drawer: AppDrawer(),
    );
  }
}
