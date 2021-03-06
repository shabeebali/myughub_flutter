import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../baseConfig.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import '../../loadingIndicator.dart';
import '../../homeScreenArguments.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool isPasswordCompliant(String password, [int minLength = 6]) {
    if (password == null || password.isEmpty) {
      return false;
    }

    bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(new RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
    bool hasSpecialCharacters =
        password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length > minLength;

    return hasDigits &
        hasUppercase &
        hasLowercase &
        hasSpecialCharacters &
        hasMinLength;
  }

  Future<String?> registerUser(
      String email, String password, String firstname, String lastname) async {
    var res = await http.post(
      Uri.parse("$SERVER_IP/api/register"),
      body: jsonEncode(<String, String>{
        "email": email,
        "password": password,
        "firstname": firstname,
        "lastname": lastname,
        "device_name": "Android",
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8'
      },
    );
    if (res.statusCode == 200) {
      print(res.body);
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return res.body;
    }
    return null;
  }

  void showLoadingIndicator([String? text]) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                backgroundColor: Colors.black87,
                content: LoadingIndicator(text: text!),
              ));
        });
  }

  showAlertDialog(BuildContext context, String title, String msg) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Create an account'),
          backgroundColor: Colors.cyan,
        ),
        body: Builder(builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Form(
            key: _formKey,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    TextFormField(
                      autovalidateMode: AutovalidateMode.disabled,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        icon: const Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: const Icon(Icons.person)),
                      ),
                      validator: (val) =>
                          val == null || val == '' ? 'Required' : null,
                      controller: _firstnameController,
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.disabled,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        icon: const Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: const Icon(Icons.text_format_outlined)),
                      ),
                      validator: (val) =>
                          val == null || val == '' ? 'Required' : null,
                      controller: _lastnameController,
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.disabled,
                      validator: (val) => !EmailValidator.validate(val!, true)
                          ? 'Not a valid email.'
                          : null,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          icon: const Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: const Icon(Icons.mail))),
                      controller: _emailController,
                    ),
                    TextFormField(
                        autovalidateMode: AutovalidateMode.disabled,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: _obscureText
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off),
                            onPressed: _toggle,
                          ),
                          labelText: 'Password',
                          errorMaxLines: 3,
                          icon: const Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: const Icon(Icons.lock)),
                        ),
                        controller: _passwordController,
                        validator: (val) => !isPasswordCompliant(val!)
                            ? 'Password should contain atleast 6 characters, one uppercase, one lowercase, one digit and one special character.'
                            : null),
                    SizedBox(
                      height: 16.0,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          showLoadingIndicator('');
                          // showOtpBottomSheet(context);
                          var password = _passwordController.text;
                          var firstname = _firstnameController.text;
                          var lastname = _lastnameController.text;
                          var email = _emailController.text;
                          var res = await registerUser(
                              email, password, firstname, lastname);
                          if (res != null) {
                            Map<String, dynamic> data = jsonDecode(res);
                            if (data['message'] == 'success') {
                              storage.write(key: "jwt", value: data['token']);
                              await FirebaseAuth.instance.currentUser!.reload();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/verify_email',
                                (Route<dynamic> route) => false,
                              );
                              /*
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/dashboard', (Route<dynamic> route) => false,
                                  arguments: HomeScreenArguments(true));

                               */
                            } else if (data.containsKey('message')) {
                              DialogBuilder(context).hideOpenDialog();
                              showAlertDialog(
                                  context, 'Alert', data['message']);
                            } else {
                              DialogBuilder(context).hideOpenDialog();
                              showAlertDialog(context, 'Alert',
                                  'Something went wrong. Try Again');
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        onPrimary: Colors.white,
                        primary: Colors.cyan.shade500,
                        padding: EdgeInsets.symmetric(horizontal: 75.0),
                      ),
                      child: Text('Register'),
                    ),
                  ],
                )),
          ));
        }));
  }
}

