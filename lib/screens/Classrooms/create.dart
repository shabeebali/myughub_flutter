import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../Models/InstitutionModel.dart';
import '../../Models/UniversityModel.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../baseConfig.dart';
import 'package:http/http.dart' as http;

class CreateClassroom extends StatefulWidget {
  @override
  CreateClassroomState createState() => CreateClassroomState();
}
class CreateClassroomState extends State<CreateClassroom> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController universityController = TextEditingController(text: 0.toString());
  final TextEditingController institutionController = TextEditingController(text: 0.toString());

  List<InstitutionModel> institutionRepository = [];
  List<InstitutionModel> institutionSubRepository = [];
  List<UniversityModel> universityRepository = [];

  bool loading = false;

  String jwt = '';

  bool _enableInstitution = false;

  bool _universityClearable = true;

  String? joinMethod = 'approve';

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initFn();
  }

  Future initFn() async {
    setState(() {
      this.loading = true;
    });
    this.jwt = (await storage.read(key: "jwt"))!;
    var res = await Future.wait([
      loadInstitutions(),
      loadUniversities()
    ]);
    if(res[0] == true && res[1] == true) {
      setState(() {
        this.loading = false;
      });
    }
  }

  Future<bool> loadUniversities() async {
    final response = await http.get(
      Uri.parse('$SERVER_IP/api/universities'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer ${this.jwt}"
      },
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      //data.forEach((element) {print(element);});
      data.forEach((e) => this.universityRepository.add(new UniversityModel(
          name: e['name'],
          short_name: e['short_name'],
          id: e['id'])));
      return true;
    }
    return false;
  }

  Future<bool> loadInstitutions() async {
    final response = await http.get(
      Uri.parse('$SERVER_IP/api/institutions'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer ${this.jwt}"
      },
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      //data.forEach((element) {print(element);});
      data.forEach((e) => this.institutionRepository.add(new InstitutionModel(
          name: e['name'],
          short_name: e['short_name'],
          university_id: e['university_id'],
          id: e['id'])));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Create Classroom'),
          backgroundColor: Colors.cyan.shade800,
        ),
        body: LoadingOverlay(
          child: Builder(
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.disabled,
                          decoration:
                              InputDecoration(
                                labelText: 'Name of Classroom',
                                border: OutlineInputBorder()
                              ),
                          validator: (val) =>
                              val == null || val == '' ? 'Required' : null,
                          controller: nameController,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.disabled,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder()
                          ),
                          validator: (val) =>
                              val == null || val == '' ? 'Required' : null,
                          controller: subjectController,
                        ),
                        SizedBox(height: 10),
                        DropdownSearch(
                          autoValidateMode: AutovalidateMode.disabled,
                          showClearButton: _universityClearable,
                          mode: Mode.BOTTOM_SHEET,
                          showSearchBox: true,
                          label: 'University / Board',
                          itemAsString: (UniversityModel model) => model.name,
                          items: this.universityRepository,
                          onChanged: (UniversityModel? item) {
                            if(item != null) {
                              this.universityController.text = item.id.toString();
                              setState(() {
                                this._enableInstitution = true;
                              });
                              institutionSubRepository = institutionRepository.where((element) => element.university_id == item.id).toList();
                            }
                            else {
                              this.universityController.text = 0.toString();
                              this.institutionController.text = 0.toString();
                              setState(() {
                                this._enableInstitution = false;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        DropdownSearch(
                          enabled: _enableInstitution,
                          autoValidateMode: AutovalidateMode.disabled,
                          showClearButton: true,
                          mode: Mode.BOTTOM_SHEET,
                          showSearchBox: true,
                          label: 'Institution',
                          itemAsString: (InstitutionModel model) => model.name,
                          items: this.institutionSubRepository,
                          onChanged: (InstitutionModel? item) {
                            if(item != null) {
                              this.institutionController.text = item.id.toString();
                              setState(() {
                                _universityClearable = false;
                              });
                            }
                            else {
                              setState(() {
                                _universityClearable = true;
                              });
                              this.institutionController.text = 0.toString();
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        Text('Join Method ?', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 5.0,),
                        ListTile(
                          title: Text('Anyone with code can join'),
                          leading: Radio(
                            value: 'anyone',
                            groupValue: joinMethod,
                            onChanged:  (String? value) {
                              setState(() {
                                joinMethod = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text('Join on approval'),
                          leading: Radio(
                            value: 'approve',
                            groupValue: joinMethod,
                            onChanged:  (String? value) {
                              setState(() {
                                joinMethod = value;
                              });
                            },
                          ),
                        ),
                        Center( child:
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.cyan,
                            ),
                            child: Text('Create'),
                            onPressed: () async {
                              if(_formKey.currentState!.validate()) {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  loading = true;
                                });
                                var res = await http.post(
                                  Uri.parse('$SERVER_IP/api/classrooms'),
                                  headers: {
                                    'Content-Type': 'application/json; charset=UTF-8',
                                    'Accept': 'application/json; charset=UTF-8',
                                    HttpHeaders.authorizationHeader: "Bearer ${this.jwt}"
                                  },
                                  body: jsonEncode({
                                    'name' : nameController.text,
                                    'subject': subjectController.text,
                                    'institution_id' : int.parse(institutionController.text),
                                    'university_id' : int.parse(universityController.text),
                                    'join_method' : joinMethod
                                  })
                                );
                                if (res.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                        Text('Classroom Created Successfully'),
                                      ));
                                  Navigator.pop(context);
                                }
                              }
                            },
                          )
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
          isLoading: loading,
          color: Colors.black,
        ));
  }
}



