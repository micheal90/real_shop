import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import 'package:real_shop/widgets/app_drawer.dart';

class OrderScreen extends StatelessWidget {
  static final routName = '/order';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Orders")),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchOrders(),
        builder: (ctx, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapShot.error != null) {
              return Text("An error occurred");
            } else {
              return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (ctx, index) =>
                          OrderItem(orderData.orders[index])));
            }
          }
        },
      ),
    );
  }
}
