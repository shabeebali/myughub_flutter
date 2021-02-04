import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../baseConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class SettingsPage extends StatelessWidget {
  Future<String> attemptLogOut() async {
    var jwt = await storage.read(key: "jwt");
    var res = await http.get(
      "$SERVER_IP/api/sanctum/logout",
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer $jwt"
      },
    );
    print(res.body);
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return body['message'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.cyan,
      ),
      body: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: OutlineButton(
              child: Text('Logout'),
              onPressed: () async {
                var response = await attemptLogOut();
                if (response != null && response == 'success') {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login', (Route<dynamic> route) => false);
                }
              },
            ),
          )),
    );
  }
}
