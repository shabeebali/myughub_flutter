import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Models/ClassroomModel.dart';
import '../../Models/UserModel.dart';
import '../../screens/Classrooms/lectures.dart';

import '../../baseConfig.dart';
import 'package:http/http.dart' as http;

class ViewClassroom extends StatefulWidget {
  final int id;
  const ViewClassroom({
    Key? key,
    required this.id
  }) : super(key: key);
  @override
  ViewClassroomState createState() => ViewClassroomState();
}

class ViewClassroomState extends State<ViewClassroom> {

  late String jwt;
  ClassroomModel? model;
  bool invitationRequestVisible = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadClassroom();
  }
  Future<bool> loadClassroom() async {
    jwt = (await storage.read(key: "jwt"))!;

    final response = await http.get(
      Uri.parse('$SERVER_IP/api/classrooms/${widget.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer ${this.jwt}"
      },
    );
    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        model = new ClassroomModel(
            id: data['id'],
            name: data['name'],
            subject: data['subject'],
            code: data['code'],
            created_by_id: data['created_by_id'],
            created_by: new UserModel(
                firstname: data['created_by']['firstname'],
                lastname: data['created_by']['lastname'],
                email: data['created_by']['email'],
                uid: data['created_by']['uid']
            )
        );
      });
      if( FirebaseAuth.instance.currentUser!.uid == model!.created_by.uid ) {
        setState(() {
          invitationRequestVisible = true;
        });
      }

    }
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text(model != null ? model!.name : ''),
        actions: [

        ],
      ),
      backgroundColor: Colors.blue.shade900,
      body:GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          primary: false,
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            GestureDetector(
              onTap: () => {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Lectures(id: model!.id)))
              },
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

                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.video_collection,
                                  color: Colors.indigo.shade500,
                                  size: 30.0,
                                ),
                              ])),
                      Container(

                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Classes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ])),

                    ]),
              ),
            ),
            GestureDetector(
              onTap: () => {Navigator.pushNamed(context, '/notifications')},
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

                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.assignment_ind,
                                  color: Colors.blue.shade500,
                                  size: 30.0,
                                ),
                              ])),
                      Container(

                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Assignments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ])),

                    ]),
              ),
            ),
            GestureDetector(
              onTap: () => {Navigator.pushNamed(context, '/notifications')},
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

                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.add_chart,
                                  color: Colors.deepOrange.shade500,
                                  size: 30.0,
                                ),
                              ])),
                      Container(

                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ])),

                    ]),
              ),
            ),
            GestureDetector(
              onTap: () => {Navigator.pushNamed(context, '/notifications')},
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

                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.chat,
                                  color: Colors.lightGreen,
                                  size: 30.0,
                                ),
                              ])),
                      Container(

                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Discussions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ])),

                    ]),
              ),
            ),
            Visibility(
              child: GestureDetector(
                onTap: () => {Navigator.pushNamed(context, '/notifications')},
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

                            child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.notification_important_sharp,
                                    color: Colors.redAccent,
                                    size: 30.0,
                                  ),
                                ])),
                        Container(

                            child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('Invitation Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ])),

                      ]),
                ),
              ),
              visible: invitationRequestVisible,
            )
          ])
    );
  }
}