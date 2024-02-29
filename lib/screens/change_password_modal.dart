import 'package:flutter/material.dart';

class ChangePasswordModal extends StatefulWidget {
  @override
  _ChangePasswordModalState createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  String _passwordError = '';
  String _confirmPasswordError = '';

  void _showPasswordUpdatedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Password Updated'),
          content: Text('Your password has been successfully updated.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Close the modal
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _validatePasswords() {
    setState(() {
      _passwordError = '';
      _confirmPasswordError = '';

      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password is required';
      }

      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Confirm Password is required';
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      }

      if (_passwordError.isEmpty && _confirmPasswordError.isEmpty) {
        // Implement logic to change the password
        _showPasswordUpdatedDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Your modal content goes here
            Text(
              'Change Password',
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            // New Password TextField
            TextFormField(
              controller: _passwordController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.black),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
              obscureText: _obscurePassword,
              onChanged: (value) {
                setState(() {
                  _passwordError = '';
                });
              },
            ),
            if (_passwordError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _passwordError,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 10.0),
            // Confirm Password TextField
            TextFormField(
              controller: _confirmPasswordController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Colors.black),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
              obscureText: _obscureConfirmPassword,
              onChanged: (value) {
                setState(() {
                  _confirmPasswordError = '';
                });
              },
            ),
            if (_confirmPasswordError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _confirmPasswordError,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the modal
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      backgroundColor: Colors.grey,
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _validatePasswords,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      backgroundColor: Colors.blue[900],
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}