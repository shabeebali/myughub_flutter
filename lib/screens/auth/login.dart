import 'dart:convert';

import 'package:flutter/material.dart';
import '../../baseConfig.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:email_validator/email_validator.dart';
import '../../homeScreenArguments.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool showLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  Future<String> attemptLogIn(String email, String password) async {
    setState(() {
      showLoading = true;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: LoadingOverlay(
          child: Builder(
              // Create an inner BuildContext so that the onPressed methods
              // can refer to the Scaffold with Scaffold.of().
              builder: (BuildContext context) {
            return Form(
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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: _emailController,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(color: Colors.red.shade200),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: TextStyle(height: 1),
                            validator: (val) =>
                                !EmailValidator.validate(val, true)
                                    ? 'Not a valid email.'
                                    : null,
                          ),
                          margin: EdgeInsets.symmetric(vertical: 20.0),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                          child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(color: Colors.red.shade200),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: TextStyle(height: 1),
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
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
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
                                      (Route<dynamic> route) => false,
                                      arguments: HomeScreenArguments(false));

                                  /*
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyHomePage(jwt)));
                            */
                                } else {
                                  setState(() {
                                    showLoading = false;
                                  });
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
                              ],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pushNamed('/register');
                          },
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 75.0),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        )
                      ]),
                ));
          }),
          isLoading: showLoading,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
        ));
  }
}
