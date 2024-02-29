import 'package:DILGDOCS/Services/globals.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'change_password_modal.dart';
import 'edit_user.dart';
import 'login_screen.dart';
import 'about_screen.dart';
import 'developers_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen();

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isAuthenticated = false;
  String userName = '';
  String email = '';
  String userAvatar = '';

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isAuthenticated') ?? false;
    String? name = prefs.getString('userName');
    String? userEmail = prefs.getString('userEmail');
    setState(() {
      isAuthenticated = loggedIn;
      userName = name ?? '';
      email = userEmail ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              color: Colors.white,
            ),
            SizedBox(width: 8.0),
            Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            // Profile Section
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50.0,
                  backgroundImage: userAvatar.isNotEmpty
                      ? NetworkImage('$baseURL/images/$userAvatar') as ImageProvider
                      : AssetImage('assets/eula.png'),
                ),
                SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25.0),
                    Text(
                      'Welcome',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.0),
            // User Profile Button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditUser()),
                ).then((_) => _getUserInfo()); // Refresh user info when returning from EditUser
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'User Profile',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[900],
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 1,
              thickness: 1,
            ),
            SizedBox(height: 10.0),
            // Change Password Button
            InkWell(
               onTap: () {
                // Navigate to the ChangePasswordScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[900],
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 1,
              thickness: 1,
            ),
            SizedBox(height: 10.0),
            // FAQs Button
             InkWell(
              onTap: () {
                _launchURL();
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.question_answer,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'FAQs',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[900],
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 1,
              thickness: 1,
            ),
            SizedBox(height: 10.0),
            // About Button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => About()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[900],
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 1,
              thickness: 1,
            ),
            SizedBox(height: 10.0),
            // Developers Button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Developers()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Developers',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[900],
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 1,
              thickness: 1,
            ),
            SizedBox(height: 10.0),
            // Logout Button
            InkWell(
              onTap: () {
                _showLogoutDialog(context);
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.exit_to_app,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[900],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Divider(
              color: Colors.grey,
              height: 1,
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isAuthenticated', false);

    setState(() {
      isAuthenticated = false;
    });

    Navigator.pushReplacementNamed(context, '/login');
  }

  

    void _launchURL() async {
    const url = 'https://dilgbohol.com/faqs'; // Replace this URL with your desired destination URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
