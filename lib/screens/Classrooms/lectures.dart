import 'package:flutter/material.dart';
import '../Classrooms/create_lecture.dart';

class Lectures extends StatefulWidget{
  final int id;
  const Lectures({
    Key? key,
    required this.id
  }) : super(key: key);
  @override
  LecturesState createState() {
    return LecturesState();
  }
}

class LecturesState extends State<Lectures>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text("Lectures / Classes"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateLecture()));
        },
      ),
    );
  }

}