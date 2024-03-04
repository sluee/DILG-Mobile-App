import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import '../Services/auth_services.dart';

class EditUser extends StatefulWidget {
  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  Widget? _userImage;
  bool isAuthenticated = false;
  String? _selectedAvatarPath;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isAuthenticated') ?? false;
    String? name = prefs.getString('userName');
    String? email = prefs.getString('userEmail');
    String? selectedAvatarPath = prefs.getString('selectedAvatarPath');
    setState(() {
      isAuthenticated = loggedIn;
      _nameController.text = name ?? '';
      _emailController.text = email ?? '';
      _selectedAvatarPath = selectedAvatarPath;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromAssets() async {
    List<String> assetImages = [
      'assets/girl 1.png',
      'assets/girl 2.png',
      'assets/girl 3.png',
      'assets/pic 1.png',
      'assets/pic 2.png',
      'assets/pic 3.png',
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 270,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
            ),
            itemCount: assetImages.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatarPath = assetImages[index];
                  });
                  Navigator.pop(context);
                },
                child: Image.asset(
                  assetImages[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'View Profile',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _pickImageFromAssets();
                },
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                    image: _selectedAvatarPath != null
                        ? DecorationImage(
                            image: AssetImage(_selectedAvatarPath!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedAvatarPath == null
                      ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 110,
                        )
                      : null,
                ),
              ),
              SizedBox(height: 16),
              _buildTextField('Name', Icons.person, _nameController),
              SizedBox(height: 16),
              _buildTextField('Email', Icons.email, _emailController),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  String newName = _nameController.text;
                  String newEmail = _emailController.text;
                  _updateNameAndEmail(newName, newEmail);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[300],
                                size: 40,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Profile Updated',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[300],
                                ),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }

  Future<void> _updateNameAndEmail(String newName, String newEmail) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Internet Connection'),
            content: Text('Please connect to the internet to update profile.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/settings');
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('selectedAvatarPath', _selectedAvatarPath ?? '');
      String? token = await AuthServices.getToken();
      if (token != null) {
        await AuthServices.updateUserNameAndEmail(token, newName, newEmail);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[300],
                      size: 40,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Profile Updated',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[300],
                      ),
                      child: Text('OK'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        print('Authentication token is null');
      }
    } catch (error) {
      print('Error updating profile: $error');
    }
  }

  void updateAvatar(String newAvatarUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userAvatar', newAvatarUrl);
  }
}
