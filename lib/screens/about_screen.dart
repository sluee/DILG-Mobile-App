import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
         iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[900],
      ),
    
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Large logo
              CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/dilg-main.png'),
              ),
              SizedBox(height: 16),
              // Text below the logo
              AnimatedTextFade(
                text:
                    'Department of the Interior and Local Government Bohol Province',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 16),
              // Additional text
              AnimatedTextFade(
                text:
                    'The DILG Bohol Issuances App is designed to house various issuances from the DILG Bohol Province, including the Latest Issuances, Joint Circulars, Memo Circulars, Presidential Directives, Draft Issuances, Republic Acts, and Legal Opinions. The primary objective of this app is to offer a comprehensive resource for accessing and staying updated on official documents and legal materials relevant to the province.',
                fontSize: 16,
              ),
              SizedBox(height: 16),
              AnimatedTextFade(
                text: '© DILG-Bohol Province 2024',
                fontSize: 12,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSelectedPage(BuildContext context, int index) {
    // Handle navigation if needed
  }
}

class AnimatedTextFade extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const AnimatedTextFade({
    required this.text,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeOut,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}