import 'package:DILGDOCS/Services/auth_services.dart';
import 'package:DILGDOCS/Services/globals.dart';
import 'change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_user.dart';
import 'about_screen.dart';
import 'developers_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String? avatarPath;

  const SettingsScreen({Key? key, this.avatarPath}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isAuthenticated = false;
  String userName = '';
  String email = '';
  String? _selectedAvatarPath;

  // Future<void> fetchUserDetails() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? avatarFileName = prefs.getString('userAvatar');
  //   var userId = await AuthServices.getUserId();

  //   if (avatarFileName != null && avatarFileName.isNotEmpty) {
  //     setState(() {
  //       // Construct the complete URL for fetching the avatar image
  //       userAvatarUrl = '$baseURL/$avatarFileName';
  //     });

  //     // Print statements for debugging
  //     print('Image URL: $userAvatarUrl');

  //     // Display the image using NetworkImage within an Image widget
  //     setState(() {
  //       avatarImage = Image.network(userAvatarUrl!);
  //     });
  //   } else {
  //     // Handle case where avatarFileName is null or empty
  //     print('Avatar file name is null or empty');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    // fetchUserDetails();
    _getSelectedAvatarPath();
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
      _getSelectedAvatarPath();
    });
  }

  Future<void> _getSelectedAvatarPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedAvatarPath = prefs.getString('selectedAvatarPath');
    setState(() {
      _selectedAvatarPath = selectedAvatarPath ?? 'assets/default.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // No app bar in settings screen
      bottomNavigationBar: null,
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
                  backgroundImage: _selectedAvatarPath != null
                      ? AssetImage(_selectedAvatarPath!)
                      : AssetImage('assets/default.png'),
                  radius: 50,
                ),
                SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25.0),
                    Text(
                      'Welcome, ',
                      style: TextStyle(color: Colors.blue),
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
                ).then((_) =>
                    _getUserInfo()); // Refresh user info when returning from EditUser
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
                          color: Colors.blue,
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
                          color: Colors.blue,
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
                _launchURL('https://dilgbohol.com/faqs');
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
                          color: Colors.blue,
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
                          color: Colors.blue,
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
                          color: Colors.blue,
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
                          color: Colors.blue,
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
                logout(context);
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    await clearAuthToken();

    // Set isAuthenticated to false
    await AuthServices.storeAuthenticated(false);

    // Navigate to the login screen and remove all previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

// Function to clear authentication token
  Future<void> clearAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}
