import 'package:flutter/material.dart';

class StyleTest extends StatefulWidget {
  StyleTest({Key key}) : super(key: key);

  @override
  _StyleTestState createState() => _StyleTestState();
}

class _StyleTestState extends State<StyleTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         backgroundColor: Theme.of(context).primaryColor,
    elevation: 0,
    leading: IconButton(
      icon: Icon(
        Icons.shopping_cart,
        color: Colors.white,
      ),
      onPressed: () {
        print("Shopping cart pressed");
      },
    ),
       ),
    );
  }
}