import 'dart:convert';
import 'package:flutter/material.dart';
import '../../baseConfig.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import '../../loadingIndicator.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

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

  Future<String> sendMail(String email) async {
    await Future.delayed(Duration(seconds: 1));
    return 'yes';
    /*
    var res = await http.post(
      "$SERVER_IP/api/email_validation",
      body: jsonEncode(<String, String>{
        "email": email,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8'
      },
    );
    print(res.body);
    if (res.statusCode == 200) {
      return res.body;
    }
    return null;*/
  }

  void showLoadingIndicator([String text]) {
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
                content: LoadingIndicator(text: text),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create an account'),
          backgroundColor: Colors.cyan,
        ),
        body: Builder(builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) => !EmailValidator.validate(val, true)
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        validator: (val) => !isPasswordCompliant(val)
                            ? 'Password should contain atleast 6 characters, one uppercase, one lowercase, one digit and one special character.'
                            : null),
                    SizedBox(
                      height: 16.0,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        var email = _emailController.text;
                        if (_formKey.currentState.validate()) {
                          DialogBuilder(context).showLoadingIndicator('');
                          var res = await sendMail(email);
                          if (res != null) {
                            DialogBuilder(context).hideOpenDialog();
                            print('email sent successfully');
                            FocusScope.of(context).unfocus();
                            showModalBottomSheet<void>(
                              context: context,
                              isDismissible: false,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: Container(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                              'An OTP has been sent to ${_emailController.text}. Please enter OTP below.'),
                                          SizedBox(
                                            height: 16.0,
                                          ),
                                          Text(
                                            'Note: Please check your email inbox as well as spam folder !!',
                                            style: TextStyle(
                                                color: Colors.amber.shade900),
                                          ),
                                          Center(
                                            child: OTPTextField(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              textFieldAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              fieldWidth: 50,
                                              fieldStyle: FieldStyle.underline,
                                              style: TextStyle(fontSize: 17),
                                              onCompleted: (pin) {
                                                print("Completed: " + pin);
                                              },
                                            ),
                                          ),
                                          ElevatedButton(
                                            child:
                                                const Text('Close BottomSheet'),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          )
                                        ],
                                      ),
                                    ));
                              },
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        onPrimary: Colors.white,
                        primary: Colors.cyan.shade500,
                        padding: EdgeInsets.symmetric(horizontal: 75.0),
                      ),
                      child: Text('Next'),
                    ),
                  ],
                )),
          ));
        }));
  }
}
