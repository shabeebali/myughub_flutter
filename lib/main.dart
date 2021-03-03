import 'package:flutter/material.dart';
// import 'init.dart';
import 'splash.dart';
import 'screens/home.dart';
import 'baseConfig.dart';
import 'screens/auth/login.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'screens/settings_page.dart';
import 'screens/classrooms.dart';
import 'screens/auth/register.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Future<bool> get firebaseInit async {
    final _initialization = await Firebase.initializeApp();
    if (_initialization != null) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String token = await messaging.getToken(
        vapidKey:
            "BGcyl6peVrJ9w4d6u4--2TahwpJr6ql5iU0m8XdjB7UXZ1C8gbIqosS_FgsnA9q7E87UpDnnR_Q4tx9fd_WAuhY",
      );
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('app_icon');
        final InitializationSettings initializationSettings =
            InitializationSettings(android: initializationSettingsAndroid);
        flutterLocalNotificationsPlugin.initialize(initializationSettings);
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails('your channel id', 'your channel name',
                'your channel description',
                importance: Importance.max,
                priority: Priority.high,
                showWhen: false);
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
        // If `onMessage` is triggered with a notification, construct our own
        // local notification to show to users using the created channel.
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(notification.hashCode,
              notification.title, notification.body, platformChannelSpecifics,
              payload: 'item x');
        }
      });

      if (token != null) {
        print(token);
        return true;
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
          future: Future.wait([jwtOrEmpty, firebaseInit]),
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
        '/classrooms': (BuildContext context) => new Classrooms(),
      },
    );
  }
}
