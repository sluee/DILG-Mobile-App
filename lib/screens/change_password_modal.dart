import 'dart:convert';
import 'dart:io';
import 'package:DILGDOCS/Services/auth_services.dart';
import 'package:DILGDOCS/Services/globals.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String _confirmPasswordError = '';

  void _showPasswordChangedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Password Changed!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50.0),
            Text(
              'Change Password',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Please enter your password',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20.0),
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
            ),
            SizedBox(height: 8.0),
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
                errorText: _confirmPasswordError.isNotEmpty
                    ? _confirmPasswordError
                    : null,
              ),
              obscureText: _obscureConfirmPassword,
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                _resetPassword();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Center(
                child: Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _resetPassword() async {
    
    var userId = await AuthServices.getUserId(); // Retrieve user ID
    var token = await AuthServices.getToken(); // Retrieve authentication token

    var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Check if token and user ID are not null or empty
      if (token == null || token.isEmpty || userId == null) {
        print('Authentication token or user ID is null or empty. Unable to update profile.');
        return;
      }
      // Check if passwords match
      if (_passwordController.text == _confirmPasswordController.text) {
        // Prepare the data to send
        Map<String, String> data = {
          'new_password': _passwordController.text, // Change this key
        };

        // Send the POST request to your backend API
        // try {
        //   final response = await http.put(
        //     Uri.parse('$baseURL/users/$userId/change-password'),
        //     body: json.encode(data),
        //     headers: headers,
        //   );

        //   // Check the response status code
        //   if (response.statusCode == 200) {
        //     // Password changed successfully
        //     _showPasswordChangedDialog(context);
        //   } else {
        //     // Handle errors based on the response from the server
        //     // For example, display an error message to the user
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text('Failed to update profile: ${response.reasonPhrase}'),
        //       ),
        //     );
        //   }
        // } catch (error) {
        //   // Handle network errors or other exceptions
        //   print('Error: $error');
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text('An error occurred. Please try again later.'),
        //     ),
        //   );
        // }
        try {
      final response = await http.put(
        Uri.parse('$baseURL/users/$userId/change-password'),
        body: json.encode(data),
        headers: headers,
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // Password changed successfully
        _showPasswordChangedDialog(context);
      } else {
        // Handle errors based on the response from the server
        // For example, display an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${response.reasonPhrase}'),
          ),
        );
      }
    } on SocketException catch (error) {
      // Handle no internet connection error
      print('No internet connection: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection. Please check your connection and try again.'),
        ),
      );
    } catch (error) {
      // Handle network errors or other exceptions
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }
      } else {
        // Set an error message that passwords don't match
        setState(() {
          _confirmPasswordError = 'Passwords do not match';
        });
      }
    }

}