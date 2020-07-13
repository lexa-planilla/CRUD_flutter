import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double _timeOfDayToDouble(TimeOfDay tod) => tod.hour + tod.minute / 60.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Menu categorias"),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.refresh,
            color: Colors.white,
          ),
          onPressed: () async {
            await _getMenuCategories();
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
                bool isCategoryAvailable;
                var nowDayNumber =
                    (DateTime.now().weekday) == 7 ? 0 : DateTime.now().weekday;
                var daysOn =
                    snapshot.data[index]["daysOn"].toString().split(",");

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

                var timeOn = _timeOfDayToDouble(TimeOfDay.fromDateTime(
                    DateTime.parse(snapshot.data[index]
                        ["TimeOn"]))); // _startTime is a TimeOfDay
                var timeOff = _timeOfDayToDouble(TimeOfDay.fromDateTime(
                    DateTime.parse(snapshot.data[index]["TimeOff"])));

                var now = _timeOfDayToDouble(TimeOfDay.now());
                print(daysOn);
                print(nowDayNumber);
                print((int.parse(daysOn[nowDayNumber]) == 1));
                //verificando si este dia esta disponible la categoria

                isCategoryAvailable = (snapshot.data[index]["TimeOn"] ==
                        snapshot.data[index]["TimeOff"])
                    ? (int.parse(daysOn[nowDayNumber]) == 1)
                    : (int.parse(daysOn[nowDayNumber]) == 1
                        ? now >= timeOn && now <= timeOff
                        : false);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isCategoryAvailable
                            ? Colors.lightGreen
                            : Colors.red,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          onTap: () {
                            if (isCategoryAvailable) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegularMenu(
                                        menuCategoryId: snapshot.data[index]
                                            ["MenuCategoryId"]),
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
                                              "${snapshot.data[index]["MenuCategoryName"]} está no disponible.",
                                              style: TextStyle(
                                                  fontFamily: 'Metropolis',
                                                  fontSize: 14.0),
                                            )
                                          ],
                                        ),
                                      ));
                            }
                          },
                          title: Shimmer.fromColors(
                            baseColor: (isCategoryAvailable)
                                ? Colors.green
                                : Colors.red,
                            highlightColor: (isCategoryAvailable)
                                ? Colors.lightGreen
                                : Colors.red,
                            child: Text(
                              snapshot.data[index]["MenuCategoryName"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                                  snapshot.data[index]["TimeOn"] !=
                                          snapshot.data[index]["TimeOff"]
                                      ? Container(
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                DateFormat('HH:mm').format(
                                                    DateTime.parse(
                                                        snapshot.data[index]
                                                            ["TimeOn"])),
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
                                                        snapshot.data[index]
                                                            ["TimeOff"])),
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

          return Text('Loading...');
        },
      ),
    );
  }
}
