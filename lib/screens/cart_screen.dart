import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:real_shop/providers/cart.dart' show Cart;
import 'package:real_shop/providers/orders.dart';
import 'package:real_shop/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static final routName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
        appBar: AppBar(title: Text("Your Cart")),
        body: Column(
          children: [
            Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(fontSize: 20),
                    ),
                    Spacer(),
                    Chip(
                      label: Text(
                        "\$${cart.totalAmount.toStringAsFixed(2)}", //show 2 digit after comma
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .headline6
                                .color),
                      ),
                      backgroundColor: Theme.of(context).accentColor,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    OrderButton(cart: cart)
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: cart.itemCount,
                  itemBuilder: (ctx, index) => CartItem(
                        id: cart.items.values.toList()[index].id,
                        productId: cart.items.keys.toList()[index],
                        title: cart.items.values.toList()[index].title,
                        quantity: cart.items.values.toList()[index].quantity,
                        price: cart.items.values.toList()[index].price,
                      )),
            )
          ],
        ));
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;
  const OrderButton({
    @required this.cart,
  });
  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.items.values.toList(), widget.cart.totalAmount);
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            },
      child: _isLoading
          ? CircularProgressIndicator()
          : Text(
              "ORDER NOW",
            ),
      style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
              TextStyle(color: Theme.of(context).accentColor, fontSize: 20))),
    );
  }
}
