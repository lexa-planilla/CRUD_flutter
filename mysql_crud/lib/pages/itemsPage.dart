import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mysql_crud/pages/optionalsGroups.dart';

class RegularMenu extends StatelessWidget {
  final String menuCategoryId;
  const RegularMenu({Key key, this.menuCategoryId}) : super(key: key);


  Future<List> _getRegularMenu() async {
    final response =
        await http.post("http://lexa.com.sv/tienda/getRegularMenu.php", body: {
      "menuCategorieId": menuCategoryId,
    });

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,     
      ),
      body: FutureBuilder<List>(
        future: _getRegularMenu(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? ItemList(list: snapshot.data)
              : Center(
                  child: CircularProgressIndicator(),
                );
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
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
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
                    builder: (context) => OptionalGroups(
                        regularItemId: list[index]['RegularItemId']),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  height: 200.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF961F).withOpacity(0.7),
                          Colors.green.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.white),
                                children: [
                                  TextSpan(
                                    text: list[index]['ItemName'],
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'Metropolis',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.white),
                                children: [
                                  TextSpan(
                                    text: list[index]['WebDescription'],
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'Metropolis',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.white),
                                children: [
                                  TextSpan(
                                    text: "\$" + list[index]['WebPrice'],
                                    style: TextStyle(
                                      fontSize: 14.0,
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
