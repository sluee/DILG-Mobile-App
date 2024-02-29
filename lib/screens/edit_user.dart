import 'package:DILGDOCS/Services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'sidebar.dart';

class EditUser extends StatefulWidget {
  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  File? _userImage;
  bool isAuthenticated = false; // Variable to store the selected user image


  @override
  void initState() {
    super.initState();  
    _getUserInfo(); // // Replace 'initial email' with the actual email
  }

 Future<void> _getUserInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool loggedIn = prefs.getBool('isAuthenticated') ?? false;
  String? name = prefs.getString('userName');
  String? email = prefs.getString('userEmail');
  setState(() {
    isAuthenticated = loggedIn;
    _nameController.text = name ?? ''; // Set text of the name controller
    _emailController.text = email ?? ''; // Set text of the email controller
  });
}
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _userImage = File(pickedImage.path);
      });
    }
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
        color: Colors.white, // Change the color of the back button arrow here
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
            // Editable container for an image
            GestureDetector(
              onTap: () {
                // Allow users to pick an image
                _pickImage(ImageSource.gallery);
              },
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[900],
                  image: _userImage != null
                      ? DecorationImage(
                          image: FileImage(_userImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _userImage == null
                    ? Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 110,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 16),
            // Name input field
            _buildTextField('Name', Icons.person, _nameController),
            SizedBox(height: 16),
            // Email input field
            _buildTextField('Email', Icons.email, _emailController),
            SizedBox(height: 32),
            // Submit button
            ElevatedButton(
              onPressed: () {
                // Get updated name and email
                String newName = _nameController.text;
                String newEmail = _emailController.text;

                // Call method to update name and email in authentication service
                _updateNameAndEmail(newName, newEmail);

                // Show dialog after the update
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
                                Navigator.pop(context);
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

// Future<void> _updateNameAndEmail(String newName, String newEmail) async {
//   try {
//     // Get the authentication token
//     String? token = await AuthServices.getToken();
//     if (token != null) {
//       // Call the method to update name and email
//       await AuthServices.updateUserNameAndEmail(token, newName, newEmail);
//       // Show success dialog
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Container(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.check_circle,
//                     color: Colors.green[300],
//                     size: 40,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Profile Updated',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue[300],
//                     ),
//                     child: Text('OK'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     } else {
//       // Handle case where token is null
//       print('Authentication token is null');
//     }
//   } catch (error) {
//     // Handle error
//     print('Error updating profile: $error');
//     // Show error dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Error'),
//           content: Text('Failed to update profile. Please try again.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

  void _navigateToSelectedPage(BuildContext context, int index) {
    // Handle navigation if needed
  }

  

  Future<void> _updateNameAndEmail(String newName, String newEmail) async {
    try {
      // Get the authentication token
      String? token = await AuthServices.getToken();
      if (token != null) {
        // Call the method to update name and email
        await AuthServices.updateUserNameAndEmail(token, newName, newEmail);
        // Show success dialog
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
                        Navigator.pop(context);
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
        // Handle case where token is null
        print('Authentication token is null');
      }
    } catch (error) {
      // Handle error
      print('Error updating profile: $error');
    }
  }
}