import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mysql_crud/pages/optionals.dart';

class OptionalGroups extends StatelessWidget {
  final String regularItemId;

  const OptionalGroups({Key key, this.regularItemId}) : super(key: key);

  Future<List> _getOptionalGroups() async {
    final response = await http
        .post("http://lexa.com.sv/tienda/getMenuOptionalsGroups.php", body: {
      "regularItemId": regularItemId,
    });

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("Grupos de modificadores"),
      ),
      body: FutureBuilder<List>(
        future: _getOptionalGroups(),
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
    //Es obligatorio el optional?
    var isMandatory = false;

    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (BuildContext context, int index) {
        isMandatory = list[index]['Mandatory'] == '1';
        print(list[index]['Mandatory']);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Optionals(
                      regularItemId: list[index]['RegularItemId'],
                      optionalGroupId: list[index]['OptionalGroupId'],
                    ),
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
                      border: Border.all(color: Colors.purple),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: list[index]['GroupName'],
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: 'Metropolis',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                          Text(
                            isMandatory ? "Requerido" : "",
                            style: TextStyle(color: Colors.red),
                          )
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
