import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 65.0,
                  child: Image.asset(
                    'assets/eduway.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                LinearProgressIndicator(
                  backgroundColor: Colors.cyan,
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                  minHeight: 7.0,
                )
              ],
            ),
          ),
        ),
      );
}
