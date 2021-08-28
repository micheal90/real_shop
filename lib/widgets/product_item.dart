import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/auth.dart';
import 'package:real_shop/providers/cart.dart';
import 'package:real_shop/providers/product.dart';
import 'package:real_shop/providers/products.dart';
import 'package:real_shop/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context);
    final authData = Provider.of<Auth>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GridTile(
        child: GestureDetector(
          onTap: () => Navigator.of(context)
              .pushNamed(ProductDetailScreen.routName, arguments: product.id),
          child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.fill,
              )),
        ),
        footer: GridTileBar(
          title: Text(product.title),
          leading: IconButton(
            color: Theme.of(context).iconTheme.color,
            icon: product.isFavorite
                ? Icon(Icons.favorite)
                : Icon(Icons.favorite_border),
            onPressed: () =>
                product.toggleFavoriteStatus(authData.token, authData.userId),
          ),
          backgroundColor: Colors.black45,
          trailing: IconButton(
            color: Theme.of(context).iconTheme.color,
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              cart.addItem(product.id, product.title, product.price);
              ScaffoldMessenger.of(context)
                  .hideCurrentSnackBar(); //hide snackBar if run befor
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Added to cart"),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: "Undo!",
                  onPressed: () => cart.removeSingelItem(product.id),
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}
