import 'package:flutter/material.dart';
import 'sidebar.dart';

class Developers extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Developers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[900],
        // leading: IconButton(
        //   icon: Icon(Icons.menu, color: Colors.blue[900]),
        //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        // ),
      ),
      // drawer: Sidebar(
      //   currentIndex: 9,
      //   onItemSelected: (index) {
      //     // Handle item selection if needed
      //     _navigateToSelectedPage(context, index);
      //   },
      // ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Large logo
                CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage('assets/mdc-logo.png'),
                ),
                SizedBox(height: 16),
                // Title
                Text(
                  'Mater Dei College Information Technology Interns',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                // Developer Information
                _buildDeveloperInfo('Eunizel R. Gabas', 'Team Leader/Developer',
                    'assets/eunizel.png'),
                _buildDeveloperInfo(
                    'Eula R. Gabas', 'Developer', 'assets/eula.png'),
                _buildDeveloperInfo('Angela Cecilia G. Lenteria', 'Developer',
                    'assets/ace.png'),
                _buildDeveloperInfo(
                    'Jhon Lyod M. Catalan', 'Developer', 'assets/lyod.png'),
                _buildDeveloperInfo(
                    'Bruce R. Unabia', 'Developer', 'assets/bruce.png'),
                SizedBox(height: 16),
                Text(
                  '© All rights reserved 2024',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperInfo(String name, String position, String imagePath) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Builder(
        builder: (BuildContext context) {
          return Row(
            children: [
              // Developer Image
              GestureDetector(
                onTap: () =>
                    _showDeveloperModal(context, name, position, imagePath),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(imagePath),
                ),
              ),
              SizedBox(width: 16),
              // Developer Name and Position
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    position,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeveloperModal(
      BuildContext context, String name, String position, String imagePath) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return DeveloperModal(
            name: name, position: position, imagePath: imagePath);
      },
    );
  }

  void _navigateToSelectedPage(BuildContext context, int index) {
    // Handle navigation if needed
  }
}

class DeveloperModal extends StatelessWidget {
  final String name;
  final String position;
  final String imagePath;

  const DeveloperModal({
    required this.name,
    required this.position,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 200.0, // Set a minimum height
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Developer Image in modal
            Center(
              child: CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage(imagePath),
              ),
            ),
            SizedBox(height: 16),
            // Developer Name and Position in modal
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              position,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
