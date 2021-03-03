import 'package:flutter/material.dart';

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
             icon: Icon(Icons.more_vert),
             onPressed: () {
             },
           )
         ],
       ),
      )
    );
  }
}