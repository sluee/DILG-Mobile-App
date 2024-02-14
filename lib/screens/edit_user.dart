import 'package:flutter/material.dart';
import 'sidebar.dart';

class EditUser extends StatefulWidget {
  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  // Controllers for text fields
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'View Profile',
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //     ),
      //   ),
      //   leading: Builder(
      //     builder: (context) => IconButton(
      //       icon: Icon(Icons.menu, color: Colors.white),
      //       onPressed: () => Scaffold.of(context).openDrawer(),
      //     ),
      //   ),
      //   backgroundColor: Colors.blue[900],
      // ),
      drawer: Sidebar(
        currentIndex: 1,
        onItemSelected: (index) {
          // Handle item selection if needed
          _navigateToSelectedPage(context, index);
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 16),

              // Default container for an image
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[900],
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 110,
                ),
              ),

              SizedBox(height: 16),

              // Name input field
              _buildTextField('Name', Icons.person, _nameController),
              SizedBox(height: 16),

              // Email input field
              _buildTextField('Email', Icons.email, _emailController),
              SizedBox(height: 16),

              // Password input field
              _buildTextField('Password', Icons.lock, _passwordController,
                  isPassword: true),
              SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: () {
                  // Handle form submission

                  // Clear input fields
                  _nameController.clear();
                  _emailController.clear();
                  _passwordController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile Updated'),
                      duration:
                          Duration(seconds: 3), // You can adjust the duration
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[900],
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
      String label, IconData icon, TextEditingController controller,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _navigateToSelectedPage(BuildContext context, int index) {
    // Handle navigation if needed
  }
}