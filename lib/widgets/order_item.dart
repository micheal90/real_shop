import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as ord;

class OrderItem extends StatelessWidget {
  final ord.OrderItem order;
  OrderItem(this.order);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ExpansionTile(
        title: Text(
          "\$${order.amount}",
          style: TextStyle(fontSize: 20),
        ),
        subtitle: Text(DateFormat('dd/MM/yyyy hh:mm').format(order.dateTime)),
        children: order.products
            .map((product) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${product.quantity} x${product.price}",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    )
                  ],
                ))
            .toList(),
      ),
    );
  }
}
