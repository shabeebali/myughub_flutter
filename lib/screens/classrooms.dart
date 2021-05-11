import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_myughub/Arguments/ClassroomArgument.dart';
import 'package:flutter_myughub/Models/ClassroomModel.dart';
import 'package:flutter_myughub/Models/InstitutionModel.dart';
import 'package:flutter_myughub/Models/UserModel.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';

import '../baseConfig.dart';
import 'Classrooms/view.dart';

class ClassroomsIndex extends StatefulWidget {
  @override
  ClassroomState createState() => ClassroomState();
}
class ClassroomState extends State<ClassroomsIndex>{

  String jwt = '';
  List<ClassroomModel> classrooms = [];
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadClassrooms();
  }

  Future<bool> loadClassrooms() async {
    setState(() {
      loading = true;
    });
    this.classrooms = [];
    this.jwt = await storage.read(key: "jwt");
    final response = await http.get(
      '$SERVER_IP/api/classrooms',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer ${this.jwt}"
      },
    );
    // print(response.body);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      //data.forEach((element) {print(element);});
      data.forEach((e) => this.classrooms.add(new ClassroomModel(
        name: e['name'],
        subject: e['subject'],
        id: e['id'],
        institution: e['institution'] != null ? new InstitutionModel(
          id: e['institution']['id'],
          name: e['institution']['name'],
          short_name: e['institution']['short_name'],
          university_id: e['institution']['university_id'],
        ) : null,
        code: e['code'],
        created_by_id: e['created_by_id'],
        created_by: new UserModel(
          firstname: e['created_by']['firstname'],
          lastname: e['created_by']['lastname'],
          email: e['created_by']['email'],
          uid:  e['created_by']['uid']
        )
      )));
      // print(this.classrooms);
      setState(() {
        loading = false;
      });
      return true;
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text("Classrooms"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              loadClassrooms();
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          )
        ],
      ),
      body: LoadingOverlay(
        child: Builder(
          builder: (BuildContext context) {
            return ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 1,
                );
              },
              itemCount: classrooms.length,
              itemBuilder: (context, index) {
                ClassroomModel _model = classrooms[index];
                return Container(
                  child:Card(
                    color: Colors.black12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(_model.name, style: TextStyle(color: Colors.white),),
                          subtitle: Text(_model.subject, style: TextStyle(color: Colors.white54),),
                          trailing: InkWell(
                              child: Icon(Icons.more_vert, color: Colors.white,),
                            onTap: () {}
                            ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: _model.institution != null ? Row(
                                children:[
                                  Icon(Icons.school, color: Colors.white70,),
                                  SizedBox(width: 5.0,),
                                  Text(_model.institution!.name, style: TextStyle(color: Colors.white54),),
                                ]
                              ) : null,
                              padding: EdgeInsets.only(left: 16.0)
                            ),
                            TextButton(onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ViewClassroom(id:_model.id))
                              )
                            }, child: Text('Enter', style: TextStyle(color: Colors.white, fontSize:16.0)),)
                          ],
                        )
                      ],
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                );
              },
            );
          }
        ),
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
        isLoading: loading,
        color: Colors.black,
      ),
      backgroundColor: Colors.blue.shade900,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 125,
                child: Column(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed('/classroom_create');
                        },
                        child: RichText(
                            text: TextSpan(
                                text: 'Create Classroom',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.blueAccent)))),
                    TextButton(
                        onPressed: () {},
                        child: RichText(
                            text: TextSpan(
                                text: 'Join Classroom',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.blueAccent))))
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}


