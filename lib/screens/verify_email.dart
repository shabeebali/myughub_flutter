import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../homeScreenArguments.dart';
import '../loadingIndicator.dart';

class VerifyEmail extends StatefulWidget {
  @override
  _VerifyEmailState createState() {
    return _VerifyEmailState();
  }
}
class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(

      onWillPop: () async => false,

      child: Scaffold(
        appBar: AppBar(
          title: Text('Verify Email'),
          backgroundColor: Colors.cyan,
        ),
        body: Builder(
          builder: (BuildContext context) {
            var email = FirebaseAuth.instance.currentUser.email;
            return Material(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: ListView(
                    children: [
                      RichText(text: new TextSpan(
                          style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black
                          ),
                          children: [
                            new TextSpan(text: 'A verification E-main has been sent to '),
                            new TextSpan(text: email, style: new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(text: '. Please visit the E-mail inbox and click on verification link provided. After that click on '),
                            new TextSpan(text: 'Refresh Button', style: new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(text: ' below')
                          ]
                      )),
                      SizedBox(height: 16.0,),
                      Center(
                          child: Ink(
                            decoration: const ShapeDecoration(
                              color: Colors.lightBlue,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                                icon: const Icon(Icons.refresh),
                                color: Colors.white,
                                onPressed: () async {
                                  var db = new DialogBuilder(context);
                                  db.showLoadingIndicator('');
                                  await FirebaseAuth.instance.currentUser.reload();
                                  if(FirebaseAuth.instance.currentUser.emailVerified == true) {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                        '/dashboard', (Route<dynamic> route) => false,
                                        arguments: HomeScreenArguments(true));
                                  } else {
                                    db.hideOpenDialog();
                                  }
                                }),
                          )
                      )
                    ]
                )
              )
            );
          },
        )
      )
    );
  }

}