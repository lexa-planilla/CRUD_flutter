import 'package:flutter/material.dart';

class Vendedores extends StatefulWidget {
  Vendedores({Key key}) : super(key: key);

  @override
  _VendedoresState createState() => _VendedoresState();
}

class _VendedoresState extends State<Vendedores> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         backgroundColor: Theme.of(context).primaryColor,
    elevation: 0,
    leading: IconButton(
      icon: Icon(
        Icons.person_pin_circle,
        color: Colors.white,
      ),
      onPressed: () {
        print("Person cart pressed");
      },
    ),
       ),
    );
  }
}