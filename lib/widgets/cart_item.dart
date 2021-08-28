import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;
  const CartItem({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        padding: EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Are you sure?'),
                  content: Text('Do you want to remove item from the cart?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('NO')),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Yes'))
                  ],
                ));
      },
      onDismissed: (direction) =>
          Provider.of<Cart>(context, listen: false).removeItem(productId),
      direction: DismissDirection.endToStart,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            child: FittedBox(
                child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text('\$$price'),
            )),
          ),
          title: Text(title),
          subtitle: Text("\$${quantity * price}"),
          trailing: Text("$quantity x"),
        ),
      ),
    );
  }
}
