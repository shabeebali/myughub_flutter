import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Models/ClassroomModel.dart';
import '../Models/InstitutionModel.dart';
import '../Models/UserModel.dart';
import '../loadingIndicator.dart';
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
  bool codeCopied = false;
  String? joinCode = '';
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
    this.jwt = (await storage.read(key: "jwt"))!;
    final response = await http.get(
      Uri.parse('$SERVER_IP/api/classrooms'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer ${this.jwt}"
      },
    );
    print(response.body);
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
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded( child:
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_model.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                                    SizedBox(height: 5.0,),
                                    Text(_model.subject, style: TextStyle(color: Colors.white54), overflow: TextOverflow.ellipsis)
                                  ],
                                ),
                              ),
                              InkWell(
                                  child: Icon(Icons.more_vert, color: Colors.white,),
                                  onTap: () {
                                    showModalBottomSheet(context: context, builder: (BuildContext context) {
                                      return Container(
                                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                                          height: 200,
                                          child: Column (
                                              children: [
                                                SizedBox(height: 16.0,),
                                                Text('Invitation Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                                                SizedBox(height: 16.0),
                                                Center(
                                                    child: TextField(
                                                      readOnly: true,
                                                      controller: TextEditingController(text:_model.code),
                                                      decoration: InputDecoration(
                                                        suffixIcon: TextButton.icon(
                                                            label: codeCopied == false ? Text('Copy') : Text('Copied', style: TextStyle(color: Colors.green),),
                                                            icon: codeCopied == false ? Icon(Icons.copy) : Icon(Icons.check,color: Colors.green,),
                                                            onPressed: () {
                                                              Clipboard.setData(ClipboardData(text: _model.code));
                                                              setState(() {
                                                                codeCopied = true;
                                                              });
                                                              Future.delayed(const Duration(milliseconds: 2000), () => setState((){
                                                                codeCopied = false;
                                                              }));
                                                            }
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                ),

                                              ]
                                          )
                                      );
                                    });
                                  }
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(_model.institution!.name, style: TextStyle(color: Colors.white54,), overflow: TextOverflow.ellipsis,)),
                              InkWell(
                                  child: Icon(Icons.arrow_forward, color: Colors.white,),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewClassroom(id: _model.id),
                                      ),
                                    );
                                  }
                              ),
                            ],
                          )
                        ]
                      )
                    )
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
                        onPressed: () {
                          Navigator.pop(context);
                          _displayJoinDialog(context);
                        },
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
  Future<void> _displayJoinDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Classroom Code ?'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  joinCode = value;
                });
              },
              decoration: InputDecoration(hintText: "Enter Classroom code here"),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Join Classroom'),
                onPressed: () async {
                  if(joinCode != '') {
                    FocusScope.of(context).unfocus();
                    DialogBuilder dB = new DialogBuilder(context);
                    dB.showLoadingIndicator();
                    var res = await http.post(
                      Uri.parse('$SERVER_IP/api/classrooms/join'),
                      headers: {
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Accept': 'application/json; charset=UTF-8',
                        HttpHeaders.authorizationHeader: "Bearer ${this.jwt}"
                      },
                      body: jsonEncode({
                        "code": joinCode
                      })
                    );
                    // print(res.body);
                    if(res.statusCode == 200) {
                      var data = jsonDecode(res.body);
                      print(data);
                      if(data['status'] == 'PENDING'){
                        dB.hideOpenDialog();
                        _showAlertDialog('Pending Approval', 'Join request has been sent to teacher of the class. You will enter the class once teacher approve your request');
                      } else if(data['status'] == 'JOINED') {
                        dB.hideOpenDialog();
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ViewClassroom(id:data.id))
                        );
                      } else if(data['status'] == 'CLASSROOM_DOES_NOT_EXIST') {
                        dB.hideOpenDialog();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Classroom does not exist for this code'), backgroundColor: Colors.deepOrangeAccent,));
                      } else if(data['status'] == 'ALREADY_JOINED') {
                        dB.hideOpenDialog();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You Already Joined the classroom'), backgroundColor: Colors.green,));
                      }
                    } else {
                      dB.hideOpenDialog();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Something went wrong'), backgroundColor: Colors.red,));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Code'),backgroundColor: Colors.red,));
                    Navigator.pop(context);
                  }
                },
              ),

            ],
          );
        });
  }
  Future<void> _showAlertDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


