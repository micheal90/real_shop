import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/products.dart';
import 'package:real_shop/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavorite;

  const ProductsGrid(this.showFavorite);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products =
        showFavorite ? productData.favoritesItems : productData.items;
    return products.isEmpty
        ? Center(
            child: Text("There is no products"),
          )
        : GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 2,
                crossAxisCount: 2),
            itemCount: products.length,
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              value: products[index],
              child: ProductItem(),
            ),
          );
  }
}
