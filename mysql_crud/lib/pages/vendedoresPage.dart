import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'itemsPage.dart';

class Vendedores extends StatefulWidget {
  Vendedores({Key key}) : super(key: key);

  @override
  _VendedoresState createState() => _VendedoresState();
}

class _VendedoresState extends State<Vendedores> {
  StreamController _streamController = StreamController();
  Timer _timer;

  Future _getMenuCategories() async {
    final response =
        await http.get("http://lexa.com.sv/tienda/getMenuCategories.php");

    //Add your data to stream
    _streamController.add(jsonDecode(response.body));
  }

  @override
  void initState() {
    _getMenuCategories();

    //Check the server every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) => _getMenuCategories());

    super.initState();
  }

  @override
  void dispose() {
    //cancel the timer
    if (_timer.isActive) _timer.cancel();

    super.dispose();
  }

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
      body: StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegularMenu(
                                menuCategoryId: snapshot.data[index]["MenuCategoryId"]),
                          ),
                        ),
                        title: Text(
                          snapshot.data[index]["MenuCategoryId"],
                          style: TextStyle(
                              fontFamily: 'Metropolis Bold',
                              color: Colors.black),
                        ),
                        subtitle: Text(
                          snapshot.data[index]["MenuCategoryName"],
                          style: TextStyle(
                              fontFamily: 'Metropolis',
                              color: Colors.black,
                              fontSize: 10.0),
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                );
              },
            );
          }

          return Text('Loading...');
        },
      ),
    );
  }
}

class ItemList extends StatelessWidget {
  final List list;
  ItemList({this.list});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegularMenu(
                        menuCategoryId: list[index]['MenuCategoryId']),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  height: 160.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF961F).withOpacity(0.7),
                          Colors.orange.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.white),
                                children: [
                                  TextSpan(
                                    text: list[index]['MenuCategoryName'],
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: 'Metropolis',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: list == null ? 0 : list.length,
    );
  }
}
