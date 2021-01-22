import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'baseConfig.dart';
import 'package:http/http.dart' as http;
import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  Future<String> attemptLogIn(String email, String password) async {
    var res = await http.post(
      "$SERVER_IP/api/sanctum/token",
      body: jsonEncode(<String, String>{
        "email": email,
        "password": password,
        'device_name': 'android'
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8'
      },
    );
    //print(res.body);
    if (res.statusCode == 200) {
      return res.body;
    }
    return null;
  }

  Future<int> attemptSignUp(String email, String password) async {
    var res = await http.post('$SERVER_IP/signup',
        body: {"email": email, "password": password});
    return res.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
            // Create an inner BuildContext so that the onPressed methods
            // can refer to the Scaffold with Scaffold.of().
            builder: (BuildContext context) {
          return Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade700, Colors.cyan.shade700],
                )),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 50.0,
                        child: Image.asset(
                          "assets/eduway_white.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              errorStyle: TextStyle(color: Colors.red.shade200),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                              filled: true,
                              fillColor: Colors.blue.shade500,
                              focusColor: Colors.white),
                          style: TextStyle(color: Colors.white, height: 0.5),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter email';
                            }
                            return null;
                          },
                        ),
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              errorStyle: TextStyle(color: Colors.red.shade200),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                              filled: true,
                              fillColor: Colors.blue.shade500,
                              focusColor: Colors.white),
                          style: TextStyle(color: Colors.white, height: 0.5),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                        ),
                        margin: EdgeInsets.only(bottom: 20.0),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            onPrimary: Colors.white,
                            primary: Colors.cyan.shade500,
                            padding: EdgeInsets.symmetric(horizontal: 75.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                          ),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState.validate()) {
                              var email = _emailController.text;
                              var password = _passwordController.text;
                              var jwt = await attemptLogIn(email, password);
                              if (jwt != null) {
                                storage.write(key: "jwt", value: jwt);
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/dashboard',
                                    (Route<dynamic> route) => false);

                                /*
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyHomePage(jwt)));
                          */
                              } else {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content:
                                      Text('Email / password are incorrect'),
                                ));
                              }
                            }
                          },
                          child: Text("Log In")),
                      Container(
                        margin: EdgeInsets.only(top: 12.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Don\'t have an Account? ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    var email = _emailController.text;
                                    var password = _passwordController.text;

                                    if (email.length < 4)
                                      displayDialog(context, "Invalid Username",
                                          "The username should be at least 4 characters long");
                                    else if (password.length < 4)
                                      displayDialog(context, "Invalid Password",
                                          "The password should be at least 4 characters long");
                                    else {
                                      var res =
                                          await attemptSignUp(email, password);
                                      if (res == 201)
                                        displayDialog(context, "Success",
                                            "The user was created. Log in now.");
                                      else if (res == 409)
                                        displayDialog(
                                            context,
                                            "That username is already registered",
                                            "Please try to sign up using another username or log in if you already have an account.");
                                      else {
                                        displayDialog(context, "Error",
                                            "An unknown error occurred.");
                                      }
                                    }
                                  },
                              ),
                            ],
                          ),
                        ),
                      )
                    ]),
              ));
        }));
  }
}
