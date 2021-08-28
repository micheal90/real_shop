import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/products.dart';
import 'package:real_shop/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;

  final String imageUrl;
  const UserProductItem({
    @required this.id,
    @required this.title,
    @required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    var scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
      title: Text(title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context)
                    .pushNamed(EditProductScreen.routName, arguments: id)),
            IconButton(
                icon: Icon(Icons.delete_forever_rounded),
                color: Theme.of(context).errorColor,
                onPressed: () async {
                  try {
                    return await Provider.of<Products>(context, listen: false)
                        .deleteProduct(id);
                  } catch (e) {
                    scaffold.showSnackBar(
                        SnackBar(content: Text("Deleting failed!")));
                  }
                })
          ],
        ),
      ),
    );
  }
}
