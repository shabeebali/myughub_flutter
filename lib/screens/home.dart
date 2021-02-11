import 'package:flutter/material.dart';
import '../baseConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class MyHomePage extends StatefulWidget {
  // MyHomePage({Key key, this.title}) : super(key: key);

  final bool newUser;
  MyHomePage({Key key, this.newUser}) : super(key: key);

  _MyHomePageState createState() => _MyHomePageState(newUser: newUser);
}

class _MyHomePageState extends State<MyHomePage> {
  final bool newUser;
  _MyHomePageState({this.newUser});
  void initState() {
    super.initState();
    print(newUser);
    print('Olakka');
  }

  Future<String> get getData async {
    var jwt = await storage.read(key: "jwt");
    // print(jwt);
    return await http.read(
      '$SERVER_IP/api/user',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer $jwt"
      },
    );
  }

  Future<String> get sendMail async {
    var jwt = await storage.read(key: "jwt");
    return await http.read(
      '$SERVER_IP/api/mail',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer $jwt"
      },
    );
  }

  Widget build(BuildContext context) => MaterialApp(
      title: 'Home',
      home: Scaffold(
        appBar: AppBar(
          title: Text(newUser == true ? "EduWay" : "Old Eduway"),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
            )
          ],
        ),
        body: Center(
          child: FutureBuilder(
              future: getData,
              builder: (context, snapshot) => snapshot.hasData
                  ? ListView(
                      padding: const EdgeInsets.all(8),
                      children: <Widget>[
                          FlatButton(
                            onPressed: () async {
                              var response = await sendMail;
                              if (response != null) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(response),
                                ));
                              }
                            },
                            child: Text("Send Email"),
                          )
                        ])
                  : snapshot.hasError
                      ? Text("An error occurred")
                      : CircularProgressIndicator()),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: const <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Drawer Header',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Messages'),
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Profile'),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ],
          ),
        ),
      ));
}
