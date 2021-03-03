import 'package:flutter/material.dart';
import '../baseConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
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
    HomeScreenArguments args = ModalRoute.of(context).settings.arguments;

    Future.delayed(
        Duration.zero,
        () => {
              if (args != null && args.newUser == true)
                {print('called'), showWelcomeMsg(context)}
            });

    return MaterialApp(
        title: 'Home',
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.cyan,
              title: Text("EduWay"),
              actions: [
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                )
              ],
            ),
            body: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => {
                        Navigator.pushNamed(context, '/classrooms')
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        color: Colors.indigo.shade500,
                        elevation: 10.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:<Widget>[
                            ListTile(
                              leading: Icon(Icons.assignment, color: Colors.white,),
                              title: Text('Classrooms', style: TextStyle(color: Colors.white),),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Messages: 0', style: TextStyle(color: Colors.white60),),
                                  IconButton(icon: Icon(Icons.arrow_forward_rounded, color: Colors.white,), onPressed: () => {

                                  }),
                                ],
                              )
                            ),
                          ]
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.blue.shade500,
                      elevation: 10.0,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:<Widget>[
                            ListTile(
                              leading: Icon(Icons.notification_important, color: Colors.white,),
                              title: Text('Notifications', style: TextStyle(color: Colors.white),),
                            ),
                           
                          ]
                      ),
                    )
                  ]
                )
            )
        )
    );
  }
}
