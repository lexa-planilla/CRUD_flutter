import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
        backgroundColor: Colors.deepOrange,
        title: Text("Regular menu items"),
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

  double _timeOfDayToDouble(TimeOfDay tod) => tod.hour + tod.minute / 60.0;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        bool isItemAvailable;
        var nowDayNumber = DateTime.now().day;
        var daysOn = list[index]["daysOn"].toString().split(",");

        var aviDays = "";
        var daysWeekend = [
          "Domingo",
          "Lunes",
          "Martes",
          "Miercoles",
          "Jueves",
          "Viernes",
          "Sabado"
        ];

        for (var i = 0; i < daysOn.length; i++) {
          if (int.parse(daysOn[i]) == 1) {
            aviDays = aviDays + "${daysWeekend[i]}/";
          }
        }

        var timeOn = _timeOfDayToDouble(TimeOfDay.fromDateTime(DateTime.parse(
            list[index]["TimeOn"]))); // _startTime is a TimeOfDay
        var timeOff = _timeOfDayToDouble(
            TimeOfDay.fromDateTime(DateTime.parse(list[index]["TimeOff"])));

        var now = _timeOfDayToDouble(TimeOfDay.now());
        isItemAvailable = (list[index]["TimeOn"] == list[index]["TimeOff"])
            ? true
            : (int.parse(daysOn[nowDayNumber + 2]) == 1
                ? now >= timeOn && now <= timeOff
                : false);

        print(list[index]["WebImage"]);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              
              border: Border.all(
                
                color: isItemAvailable ? Colors.lightGreen : Colors.red,
              ),
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  onTap: () {
                    if (isItemAvailable) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OptionalGroups(
                                regularItemId: list[index]["RegularItemId"]),
                          ));
                    } else {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: Text(
                                  "Lo sentimos",
                                  style: TextStyle(
                                      fontFamily: 'Metropolis',
                                      color: Colors.red),
                                ),
                                content: Row(
                                  children: <Widget>[
                                    Text(
                                      "${list[index]["RegularItemId"]} está no disponible.",
                                      style: TextStyle(
                                          fontFamily: 'Metropolis',
                                          fontSize: 14.0),
                                    )
                                  ],
                                ),
                              ));
                    }
                  },
                  title: Text(
                    list[index]["ItemName"],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  trailing: Text(
                    "\$${list[index]["WebPrice"]}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18.0),
                  ),
                  subtitle: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Disponibilidad: ',
                            style: TextStyle(
                                fontFamily: 'Metropolis',
                                color: Colors.black,
                                fontSize: 10.0),
                          ),
                          list[index]["TimeOn"] != list[index]["TimeOff"]
                              ? Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        DateFormat('HH:mm').format(
                                            DateTime.parse(
                                                list[index]["TimeOn"])),
                                        style: TextStyle(
                                            fontFamily: 'Metropolis',
                                            color: Colors.black,
                                            fontSize: 10.0),
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                        child: Text(" -"),
                                      ),
                                      Text(
                                        DateFormat('HH:mm').format(
                                            DateTime.parse(
                                                list[index]["TimeOff"])),
                                        style: TextStyle(
                                            fontFamily: 'Metropolis',
                                            color: Colors.black,
                                            fontSize: 10.0),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '¡Todo el día!',
                                        style: TextStyle(
                                            fontFamily: 'Metropolis',
                                            color: Colors.black,
                                            fontSize: 10.0),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            aviDays,
                            style: TextStyle(fontSize: 10.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(),
              ],
            ),
          ),
        );
      },
    );
  }
}
