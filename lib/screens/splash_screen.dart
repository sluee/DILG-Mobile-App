import 'dart:async';

import 'package:DILGDOCS/main.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final bool isAuthenticated; // Define isAuthenticated here

  SplashScreen({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // After a certain duration, navigate to either login or home screen
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => AuthenticationWrapper(isAuthenticated: widget.isAuthenticated),
      ));
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            width: 130.0,
            height: 140.0,
            image: AssetImage('assets/Tngkrw.png'),
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16),
          Text(
            'TANGKARAW DILG-Bohol',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.blue[900]
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          // CircularProgressIndicator(), // Place the CircularProgressIndicator here
        ],
      ),
    ),
  );
}
}