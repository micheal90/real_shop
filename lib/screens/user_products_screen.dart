import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/products.dart';
import 'package:real_shop/screens/edit_product_screen.dart';
import 'package:real_shop/widgets/app_drawer.dart';
import 'package:real_shop/widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static final routName = '/user-product';
  Future _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchProducts(filterByUser: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Product"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  icon: Icon(Icons.add_box_outlined),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(EditProductScreen.routName)),
            )
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: _refreshProducts(context),
            builder: (ctx, snapShot) =>
                snapShot.connectionState == ConnectionState.waiting
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : RefreshIndicator(
                        child: Consumer<Products>(
                          builder: (ctx, value, child) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                                itemCount: value.items.length,
                                itemBuilder: (ctx, index) => Column(
                                      children: [
                                        UserProductItem(
                                          id: value.items[index].id,
                                          title: value.items[index].title,
                                          imageUrl: value.items[index].imageUrl,
                                        ),
                                        Divider()
                                      ],
                                    )),
                          ),
                        ),
                        onRefresh: () => _refreshProducts(ctx))));
  }
}
