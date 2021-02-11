import 'package:flutter/material.dart';
// import 'init.dart';
import 'splash.dart';
import 'screens/home.dart';
import 'baseConfig.dart';
import 'screens/auth/login.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'screens/settings_page.dart';
import 'screens/auth/register.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Future<String> get firebaseToken async {
    final _initialization = await Firebase.initializeApp();
    if (_initialization != null) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String token = await messaging.getToken(
        vapidKey:
            "BGcyl6peVrJ9w4d6u4--2TahwpJr6ql5iU0m8XdjB7UXZ1C8gbIqosS_FgsnA9q7E87UpDnnR_Q4tx9fd_WAuhY",
      );
      if (token != null) {
        return token;
      } else {
        return null;
      }
    }
    return null;
  }

  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    print(jwt);
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
        // print(response.body);
        // If the server did return a 200 OK response,
        // then parse the JSON.
        return jwt;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        // throw Exception('Failed jwt');
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
          future: Future.wait([jwtOrEmpty, firebaseToken]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SplashScreen();
            if (snapshot.data[0] != "") {
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
      },
    );
  }
}
