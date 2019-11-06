import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List _toDOList = [];
  Map<String, dynamic> _ultimoRemovido;
  int _ultimoRemovidoPos;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDOList = json.decode(data);
      });
    });
  }

  void _addToDO() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["ok"] = false;
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      _toDOList.add(newToDo);
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDOList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("Add"),
                  textColor: Colors.white,
                  onPressed: _addToDO,
                )
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: _toDOList.length,
              itemBuilder: buildItem,
            ),
          ))
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDOList[index]["title"]),
        value: _toDOList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon((_toDOList[index])["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (bool c) {
          setState(() {
            _toDOList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direcao) {
        setState(() {
          _ultimoRemovido = Map.from((_toDOList[index]));
          _ultimoRemovidoPos = index;
          _toDOList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_ultimoRemovido["title"]}\""),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _toDOList.insert(_ultimoRemovidoPos, _ultimoRemovido);
                });
              },
            ),
          );

          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDOList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
