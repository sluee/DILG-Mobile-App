import 'package:flutter/material.dart';
import 'sidebar.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6), // Adjust duration as needed
    )..repeat(reverse: true);
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(2, 0), // Adjust end offset as needed
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.blue[900]),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Sidebar(
        currentIndex: 1,
        onItemSelected: (index) {
          // Handle item selection if needed
          _navigateToSelectedPage(context, index);
        },
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.grey.shade100, Colors.grey.shade200],
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(seconds: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.grey.shade300, Colors.grey.shade400],
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(seconds: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.grey.shade500, Colors.grey.shade600],
              ),
            ),
          ),
          Center(
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
        ],
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
