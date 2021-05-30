import 'dart:convert';

import 'package:flutter/material.dart';
import '../../baseConfig.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:email_validator/email_validator.dart';
import '../../homeScreenArguments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
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

  Future<Map> signInWithGoogle() async {
    // Trigger the interactive authentication flow
    GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    // Registering a Stream to watch signout function to get fired. If that happens trigger disconnect() of GoogleSignIn Class
    // to make able the user choose account on login again
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) async {
      if (user == null) {
        _googleSignIn.disconnect();
      }
    });
    if(googleUser != null) {
      setState(() {
        showLoading = true;
      });
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;
      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      if (userCredential != null && userCredential.user != null) {
        var tokId = await FirebaseAuth.instance.currentUser!.getIdToken();
        var res = await http.post(
          Uri.parse("$SERVER_IP/api/sanctum/token"),
          body: jsonEncode(<String, String>{
            "idToken": tokId
          }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json; charset=UTF-8'
          },
        );
        setState(() {
          showLoading = true;
        });
        Map<String, dynamic> body = jsonDecode(res.body);
        if (res.statusCode == 200) {
          return {
            'success': true,
            'oauth_user': userCredential.user,
            'token': body['token'],
            'user': body['user']
          };
        }
        return {
          'success': false,
          'message': 'Something went Wrong'
        };
      } else {
        setState(() {
          showLoading = true;
        });
        return {
          'success': false,
          'message': 'Something went Wrong'
        };
      }
    }
    return {
      'success': false,
      'message': 'Sign In Aborted'
    };
  }

  Future<Map> attemptLogIn(String email, String password) async {
    setState(() {
      showLoading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      if (userCredential != null && userCredential.user != null) {
        var idToken = await userCredential.user!.getIdToken();
        var res = await http.post(
          Uri.parse("$SERVER_IP/api/sanctum/token"),
          body: jsonEncode(<String, String>{
            "idToken": idToken,
          }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json; charset=UTF-8'
          },
        );
        Map<String, dynamic> body = jsonDecode(res.body);
        if (res.statusCode == 200) {
          return {
            'success': true,
            'token': body['token'],
            'user': body['user']
          };
        }
        return {
          'success': false,
          'message': 'Something went Wrong'
        };
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return {
          'success': false,
          'message': 'No user found for that email.'
        };
      } else if (e.code == 'wrong-password') {
        return {
          'success': false,
          'message': 'Wrong password provided for that user.'
        };
      }
    }
    return {
      'success': false,
      'message': 'Something went Wrong'
    };
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
                                !EmailValidator.validate(val!, true)
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
                              if (value!.isEmpty) {
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
                              if (_formKey.currentState!.validate()) {
                                var email = _emailController.text;
                                var password = _passwordController.text;
                                var res = await attemptLogIn(email, password);
                                if (res['success'] == true) {
                                  storage.write(key: "jwt", value: res['token']);
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
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content:
                                        Text(res['message']),
                                  ));
                                }
                              }
                            },
                            child: Text("Log In")),
                        Center(child: Text('OR',style: TextStyle(color: Colors.white),),),
                        SignInButton(
                          Buttons.Google,
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            var res = await signInWithGoogle();
                            if (res['success'] == true) {
                              storage.write(key: "jwt", value: res['token']);
                              if(FirebaseAuth.instance.currentUser!.emailVerified == false)
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/verify_email',
                                        (Route<dynamic> route) => false,
                                );
                              else
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                    Text(res['message']),
                                  ));
                            }
                          },
                        ),
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
