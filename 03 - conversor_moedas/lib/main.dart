import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const requisicao =
    "https://api.hgbrasil.com/finance?format=json-cors&key=5edac571";

void main() async {
  print(await getData());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(requisicao);
  return json.decode(response.body)["results"];
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar, euro;
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void realChange(String text) {
    print(text);
  }

  void dolarChange(String text) {
    print(text);
  }

  void euroChange(String text) {
    print(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text("\$ Conversor de Moedas \$"),
        backgroundColor: Colors.amber,
        actions: <Widget>[],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (contex, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text("Carregando dados...",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center));
            default:
              if (snapshot.hasError) {
                return Center(
                    child: Text("Erro ao carregar dados :(",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25.0,
                        ),
                        textAlign: TextAlign.center));
              } else {
                dolar = snapshot.data["currencies"]["USD"]["buy"];
                dolar = snapshot.data["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          "Reais", "R\$ ", realController, realChange),
                      Divider(),
                      buildTextField(
                          "Dólares", "US\$ ", dolarController, dolarChange),
                      Divider(),
                      buildTextField("Euros", "€ ", euroController, euroChange),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    onChanged: f,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
  );
}
