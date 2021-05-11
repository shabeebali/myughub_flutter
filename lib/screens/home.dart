import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../homeScreenArguments.dart';
class MyHomePage extends StatefulWidget {
  // MyHomePage({Key key, this.title}) : super(key: key);

  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState();
  }

  void showWelcomeMsg(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Successful'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Welcome to Eduway.'),
                  Text('Explore your new academic assistant'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Get Started'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget build(BuildContext context) {
    HomeScreenArguments args = ModalRoute.of(context)!.settings.arguments as HomeScreenArguments;

    Future.delayed(
        Duration.zero,
        () => {
              if (args != null && args.newUser == true)
                {showWelcomeMsg(context)}
            });

        return Scaffold(
            backgroundColor: const Color(0xffeeeeee),
            appBar: AppBar(
              backgroundColor: const Color(0xffeeeeee),
              elevation: 0,
              title: Text("EduWay", style: TextStyle(color: Colors.black54),),
              actions: [
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.black54,),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                )
              ],
            ),
            body: WillPopScope(
              child:GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                primary: false,
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  GestureDetector(
                    onTap: () => {Navigator.pushNamed(context, '/classrooms')},
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      elevation: 0,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.only(left:15.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(
                                        Icons.assignment,
                                        color: Colors.indigo.shade500,
                                        size: 30.0,
                                      ),
                                    ])),
                            Container(
                                padding: EdgeInsets.only(left:15.0, top: 5.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text('Classrooms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ])),
                            Container(
                                padding: EdgeInsets.only(top:15.0,left: 15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Messages: 0',
                                      style: TextStyle(color: Colors.indigo),
                                    ),
                                  ],
                                )),
                          ]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {},
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      elevation: 0,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.only(left:15.0),
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(
                                        Icons.notification_important,
                                        color: Colors.blue.shade500,
                                        size: 30.0,
                                      ),
                                    ])),
                            Container(
                                padding: EdgeInsets.only(left:15.0, top: 5.0),
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text('Notice Board', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ])),
                            Container(
                                padding: EdgeInsets.only(top:15.0,left: 15.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Coming Soom',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                )),
                          ]),
                    ),
                  ),
                ]
              ),
              onWillPop: onWillPop,
            )
        );

  }
  DateTime? currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('Press back again to exit'),
          ));
      return Future.value(false);
    }
    return Future.value(true);
  }
}
