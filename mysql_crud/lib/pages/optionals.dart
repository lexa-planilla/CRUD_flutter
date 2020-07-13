import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Optionals extends StatefulWidget {
  final String regularItemId;
  final String optionalGroupId;

  Optionals({Key key, this.regularItemId, this.optionalGroupId})
      : super(key: key);

  @override
  _OptionalsState createState() => _OptionalsState();
}

class _OptionalsState extends State<Optionals> {
  var maximumAllowed = 0;
  var ingredientsIncluded = 0;
  var exclusive = false;

  Future<List> _getOptionals() async {
    final response = await http
        .post("http://lexa.com.sv/tienda/getMenuOptionals.php", body: {
      "regularItemId": widget.regularItemId,
      "optionalGroupId": widget.optionalGroupId,
    });

    var result = json.decode(response.body);

    return result;
  }

  var total = 0.0;
  var catidadSeleccionada = 0;

  //Los que lleva el usuario
  var countIngredientsIncluded = 0;

  var isMaxElementsReached = false;

  var opcionalesSeleccionados = new List();
  var opcionalesSeleccionadosCant = new List();

  void _sumOptional(double price, String nombreOpcional) {
    setState(() {
      if (maximumAllowed != 0) {
        if (maximumAllowed == catidadSeleccionada) {
          isMaxElementsReached = true;
          return;
        } else {
          if (ingredientsIncluded != 0 &&
              countIngredientsIncluded != ingredientsIncluded) {
            catidadSeleccionada += 1;
            _addOptional(nombreOpcional);
            countIngredientsIncluded++;
            return;
          }
          catidadSeleccionada += 1;
          total += price;
          _addOptional(nombreOpcional);
          return;
        }
      }

      if (ingredientsIncluded != 0 &&
          countIngredientsIncluded != ingredientsIncluded) {
        _addOptional(nombreOpcional);
        countIngredientsIncluded++;
        return;
      }

      catidadSeleccionada += 1;
      total += price;

      _addOptional(nombreOpcional);
    });
  }

  void _clear() {
    setState(() {
      catidadSeleccionada = 0;
      total = 0.0;
      opcionalesSeleccionados = new List();
      opcionalesSeleccionadosCant = new List();
      countIngredientsIncluded = 0;
    });
  }

  void _addOptional(String nombreOpcional) {
    setState(() {
      if (opcionalesSeleccionados.contains(nombreOpcional)) {
        var index = opcionalesSeleccionados.indexOf(nombreOpcional);
        var cantActual = opcionalesSeleccionadosCant[index];
        cantActual += 1;

        opcionalesSeleccionadosCant[index] = cantActual;
      } else {
        opcionalesSeleccionados.add(nombreOpcional);
        opcionalesSeleccionadosCant.add(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Opcionales"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clear,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              "Opcionales seleccionados: $catidadSeleccionada",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: (maximumAllowed == 0)
                ? Text("!Escoge!",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue))
                : Text(
                    "Opcionales restantes disponibles: ${maximumAllowed - catidadSeleccionada}",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: ((maximumAllowed - catidadSeleccionada) == 0)
                            ? Colors.red
                            : Colors.lightGreen),
                  ),
          ),
          exclusive
              ? Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    "Solo puede escoger 1",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                )
              : Text(''),
          opcionalesSeleccionados == null
              ? Text("No ha seleccionado ningun opcional")
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                        itemCount: opcionalesSeleccionados.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Column(
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  "${opcionalesSeleccionados[index]}",
                                ),
                                trailing: Text(
                                    "x${opcionalesSeleccionadosCant[index]}"),
                              ),
                            ],
                          );
                        }),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              "Total: \$${total.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List>(
              future: _getOptionals(),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemBuilder: (BuildContext context, int index) {
                          maximumAllowed =
                              int.parse(snapshot.data[index]['MaximumAllowed']);
                          ingredientsIncluded = int.parse(
                              snapshot.data[index]['IngredientsIncluded']);
                          exclusive = snapshot.data[index]['Exclusive'] == '1';
                          if (exclusive) {
                            maximumAllowed = 1;
                          }
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => {
                                    _sumOptional(
                                        double.parse(
                                            snapshot.data[index]['Price']),
                                        snapshot.data[index]['OptionalName'])
                                  },
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
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: <Widget>[
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                  children: [
                                                    TextSpan(
                                                      text: snapshot.data[index]
                                                          ['OptionalName'],
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontFamily:
                                                            'Metropolis',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                  children: [
                                                    TextSpan(
                                                      text: "+\$" +
                                                          snapshot.data[index]
                                                              ['Price'],
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontFamily:
                                                            'Metropolis',
                                                        fontWeight:
                                                            FontWeight.bold,
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
                        itemCount:
                            snapshot.data == null ? 0 : snapshot.data.length,
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
