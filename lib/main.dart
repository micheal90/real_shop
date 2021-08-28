import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/auth_screen.dart';
import './providers/auth.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/product.dart';
import './providers/products.dart';
import './screens/cart_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/order_screen.dart';
import './screens/splash_screen.dart';
import './screens/user_products_screen.dart';
import './screens/product_overview_screen.dart';
import './screens/product_detail_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // var pref = await SharedPreferences.getInstance();
  // pref.clear();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (ctx, authValue, previousOrders) => previousOrders
            ..getData(authValue.token, authValue.userId,
                previousOrders.orders == null ? [] : previousOrders.orders),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (ctx, authValue, previousProducts) => previousProducts
            ..getData(authValue.token, authValue.userId,
                previousProducts.items == null ? [] : previousProducts.items),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authValue, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
              textTheme: TextTheme(
                bodyText1: TextStyle(
                  fontSize: 20,
                ),
              ),
              iconTheme: IconThemeData(color: Colors.red),
              primarySwatch: Colors.blue,
              accentColor: Colors.deepPurpleAccent,
              fontFamily: 'Lato'),
          //home: CartScreen(),
          home: authValue.isAuth
              ? ProductOverViewScreen()
              : FutureBuilder(
                  future: authValue.tryAutoLogIn(),
                  builder: (ctx, authSnapshot) =>
                      authSnapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailScreen.routName: (_) => ProductDetailScreen(),
            CartScreen.routName: (_) => CartScreen(),
            EditProductScreen.routName: (_) => EditProductScreen(),
            UserProductScreen.routName: (_) => UserProductScreen(),
            OrderScreen.routName: (_) => OrderScreen(),
            SplashScreen.routeName: (_) => SplashScreen(),
          },
        ),
      ),
    );
  }
}
