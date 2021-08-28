import 'package:flutter/material.dart';

//creat circle contion number on icon
class Badge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color color;
  const Badge({
    @required this.child,
    @required this.value,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color != null ? color : Theme.of(context).accentColor,
            ),
            constraints: BoxConstraints(minHeight: 16, minWidth: 16),
            child: Text(
              value,
              style: TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }
}
