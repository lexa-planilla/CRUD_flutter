import 'package:flutter/material.dart';

import 'pages/styletest.dart';
import 'pages/vendedoresPage.dart';
import 'pages/itemsPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

String username;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Vendedores(),
      title: 'CRUD Mysql',
      routes: <String, WidgetBuilder>{
        '/styletest': (BuildContext context) => new StyleTest(),
        '/itemsPage': (BuildContext context) => new RegularMenu(),
        '/vendedoresPage': (BuildContext context) => new Vendedores(),
        'LoginPage': (BuildContext context) => LoginPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController controllerUsername = new TextEditingController();
  TextEditingController controllerPassword = new TextEditingController();

  String mensaje = '';

  final kBoxDecorationStyle = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(35.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  final titleStyle = TextStyle(
    fontFamily: 'Metropolis Bold',
    color: Colors.black,
    fontSize: 28.0,
  );

  final subtitleStyle = TextStyle(
    fontFamily: 'Metropolis Light',
    color: Color.fromRGBO(141, 152, 161, 1),
    fontSize: 26.0,
  );

  final buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'Metropolis Light',
    letterSpacing: 1.0,
  );

  final kHintTextStyle = TextStyle(
    color: Colors.grey,
    fontFamily: 'Metropolis',
  );

  final kLabelStyle = TextStyle(
    color: Colors.orange,
    fontFamily: 'Metropolis Bold',
    fontSize: 14.0,
  );

  final kLabelStyleBlack = TextStyle(
    color: Colors.black,
    fontFamily: 'Metropolis Bold',
    fontSize: 14.0,
  );

  final kLabelStyleGray = TextStyle(
    color: Colors.black,
    fontFamily: 'Metropolis Light',
    fontSize: 14.0,
  );

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: controllerUsername,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 18.0),
                child: Icon(Icons.email, color: Colors.orange),
              ),
              hintText: 'Ingresa tu Correo',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: controllerPassword,
            obscureText: true,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 18.0),
                child: Icon(Icons.lock_outline, color: Colors.orange),
              ),
              hintText: 'Contraseña',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      height: 60.0,
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: _login,
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
        ),
        color: Theme.of(context).buttonColor,
        child: Text('LOGIN',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Metropolis Light',
              letterSpacing: 1.0,
            )),
      ),
    );
  }

  Future<List> _login() async {
    final response = await http.post("http://lexa.com.sv/tienda/login.php",
        body: {
          "username": controllerUsername.text,
          "password": controllerPassword.text
        });

    var datauser = json.decode(response.body);

    if (datauser.length == 0) {
      setState(() {
        mensaje = "usuario o contraseña incorrecto";
      });
    } else {
      if (datauser[0]['nivel'] == 'admin') {
        Navigator.pushReplacementNamed(context, '/styletest');
      } else if (datauser[0]['nivel'] == 'ventas') {
        Navigator.pushReplacementNamed(context, '/vendedoresPage');
      }
      setState(() {
        username = datauser[0]['username'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Form(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 100.0,
            ),
            Text(
              "Bienvenido wapo",
              style: TextStyle(fontSize: 18.0, color: Colors.green),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              mensaje,
              style: TextStyle(fontSize: 18.0, color: Colors.red),
            ),
            SizedBox(
              height: 10.0,
            ),
            _buildEmailTF(),
            SizedBox(
              height: 10.0,
            ),
            _buildPasswordTF(),
            SizedBox(
              height: 20.0,
            ),
            _buildLoginBtn(),
          ],
        ),
      ),
    );
  }
}
