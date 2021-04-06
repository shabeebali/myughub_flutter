import 'package:flutter/material.dart';
import 'package:badges/badges.dart';

class Classrooms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Classrooms',
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.cyan.shade700,
            title: Text("Classrooms"),
            actions: [
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
          body: ListView.separated(
            separatorBuilder: (context, index) {
              return Divider(
                thickness: 1,
              );
            },
            itemCount: ClassroomModel.dummyData.length,
            itemBuilder: (context, index) {
              ClassroomModel _model = ClassroomModel.dummyData[index];
              if (_model.message != '') {
                return ListTile(
                    title: Row(
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            child: Text(
                              _model.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    ),
                    subtitle: Row(children: [
                      Flexible(
                          child: Container(
                            child: Text(
                              _model.message,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        _model.message == '' ? '' : _model.datetime,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ]),
                    trailing: _getCount(_model));
              }
              return ListTile(
                  title: Row(
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          child: Text(
                            _model.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ],
                  ),
                  trailing: _getCount(_model));
            },
          ),
        ));
  }

  Widget _getCount(ClassroomModel model) {
    if (model.message != '') {
      return SizedBox(
          width: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Badge(
                elevation: 0,
                shape: BadgeShape.circle,
                padding: EdgeInsets.all(7),
                badgeContent: Text(
                  model.count.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ));
    }
    return Icon(
      Icons.arrow_forward_ios,
      size: 14,
    );
  }
}

class ClassroomModel {
  final String name;
  final String datetime;
  final String message;
  final int count;

  ClassroomModel({this.name, this.datetime, this.message, this.count});
  static final List<ClassroomModel> dummyData = [
    ClassroomModel(
        name: "Maths Class [GVHSS - Calicut][2021]",
        datetime: "20:18",
        message: "How about meeting tomorrow?",
        count: 10),
    ClassroomModel(
        name: "Physics Class [GVHSS - Calicut][2021]",
        datetime: "19:22",
        message: "I love that idea, it's great!",
        count: 5),
    ClassroomModel(
        name: "Biology Class [GVHSS - Calicut][2021]",
        datetime: "14:34",
        message: "I wasn't aware of that. Let me check",
        count: 238),
    ClassroomModel(
        name: "Social Science Class [GVHSS - Calicut][2021]",
        datetime: "11:05",
        message: '',
        count: 0),
    ClassroomModel(
        name: "English Class  [GVHSS - Calicut][2021]",
        datetime: "09:46",
        message: "It totally makes sense to get some extra day-off.",
        count: 1),
    ClassroomModel(
        name: "Computer Class  [GVHSS - Calicut][2021]",
        datetime: "08:15",
        message: "It has been re-scheduled to next Saturday 7.30pm",
        count: 99),
  ];
}
