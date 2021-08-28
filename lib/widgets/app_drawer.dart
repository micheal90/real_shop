import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/auth.dart';
import 'package:real_shop/screens/order_screen.dart';
import 'package:real_shop/screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text("Shop App"),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag_outlined),
            title: Text("Shop"),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text("Orders"),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(OrderScreen.routName),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text("Manage Products"),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(UserProductScreen.routName),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logOut();
            },
          ),
        ],
      ),
    );
  }
}
