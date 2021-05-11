// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_myughub/screens/Classrooms/view.dart';
// import 'init.dart';
import 'splash.dart';
import 'screens/home.dart';
import 'baseConfig.dart';
import 'screens/auth/login.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'screens/settings_page.dart';
import 'screens/classrooms.dart';
import 'screens/Classrooms/create.dart';
import 'screens/verify_email.dart';
import 'screens/auth/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt != null) {
      final response = await http.get(
        '$SERVER_IP/api/user',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: "Bearer $jwt"
        },
      );
      if (response.statusCode == 200) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null)
          return jwt;
        return "";
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null)
          await FirebaseAuth.instance.signOut();
        return "";
      }
    } else
      return "";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
          future: jwtOrEmpty,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SplashScreen();
            if (snapshot.data != "") {
              print('Email Verified: ${FirebaseAuth.instance.currentUser.emailVerified}');
              if(FirebaseAuth.instance.currentUser.emailVerified == false)
                return VerifyEmail();
              return MyHomePage();
            } else {
              return LoginPage();
            }
          }),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => new LoginPage(),
        '/dashboard': (BuildContext context) => new MyHomePage(),
        '/settings': (BuildContext context) => new SettingsPage(),
        '/register': (BuildContext context) => new RegisterPage(),
        '/classrooms': (BuildContext context) => new ClassroomsIndex(),
        '/classroom_create': (BuildContext context) => new CreateClassroom(),
        '/verify_email': (BuildContext context) => new VerifyEmail(),
        '/classroom' : (BuildContext context) => new ViewClassroom(),
      },
    );
  }
}
