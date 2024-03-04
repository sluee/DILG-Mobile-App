import 'dart:convert';
import 'dart:io';

import 'package:DILGDOCS/Services/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../screens/login_screen.dart';
import '../utils/routes.dart';

class AuthServices {
  static final _storage = FlutterSecureStorage();

  static Future<http.Response> login(String email, String password) async {
    try {
      Map data = {
        'email': email,
        'password': password,
      };
      var body = json.encode(data);
      var url = Uri.parse('$baseURL/auth/login');

      http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print(response.body);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var token = responseData['token'];
        var user = responseData['user'];
        var userId = user['id'];
        await storeTokenAndUserId(token, userId);
        await fetchAndStoreUserDetails(token);
        await storeAuthenticated(true); // Update authentication status

        print('Login successful');
        return response;
      } else {
        print('Login failed with status code: ${response.statusCode}');
        return response;
      }
    } catch (error) {
      print('Error during login: $error');
      throw error;
    }
  }

  static Future<void> fetchAndStoreUserDetails(String token) async {
    try {
      var url = Uri.parse('$baseURL/user');

      http.Response response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var user = responseData['user'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', user['id']);
        await prefs.setString('userName', user['name']);
        await prefs.setString('userEmail', user['email']);
        await prefs.setString('userAvatar', user['avatar']);
        var avatarUrl = user['avatar'];
        var avatarResponse = await http.get(Uri.parse(avatarUrl));
        if (avatarResponse.statusCode == 200) {
          var appDir = await getApplicationDocumentsDirectory();
          var avatarFile = File('${appDir.path}/avatar.jpg');
          await avatarFile.writeAsBytes(avatarResponse.bodyBytes);
          print('Avatar downloaded and stored locally');
        } else {
          print('Failed to download avatar image');
        }
      } else {
        print('Failed to fetch user details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }
  }

  static Future<void> storeToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> storeTokenAndUserId(String token, int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('userId', userId);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<bool> validateToken(String authToken) async {
    final response = await http.get(
      Uri.parse('$baseURL/auth/validate-token'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    return response.statusCode == 200;
  }

  static Future<void> updateUserNameAndEmail(
      String token, String newName, String newEmail) async {
    try {
      var userId = await getUserId();
      var url = Uri.parse('$baseURL/user/update/$userId');

      http.Response response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': newName,
          'email': newEmail,
        }),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', newName);
        await prefs.setString('userEmail', newEmail);
        print('User name and email updated successfully');
      } else {
        print('Failed to update user details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating user details: $error');
    }
  }

  static Future<void> logout(BuildContext context) async {
    await _storage.delete(key: 'authToken');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const LoginScreen(title: 'Login')),
    );
  }

  static Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('isAuthenticated') &&
        prefs.getBool('isAuthenticated')!;
  }

  static Future<void> storeAuthenticated(bool isAuthenticated) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', isAuthenticated);
  }
}
