import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  
  static final _storage = FlutterSecureStorage();

  static Future<http.Response> login(String email, String password) async {
    try {
      Map data = {
        'email': email,
        'password': password,
      };
      var body = json.encode(data);
      var url = Uri.parse('https://issuances.dilgbohol.com/api/auth/login');

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
        var token = responseData['token']; // Retrieve token from response
        await storeToken(token); // Store token locally
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

  static Future<void> storeToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> logout() async {
    // Clear the authentication token from secure storage
    await _storage.delete(key: 'authToken');
  }

 static Future<bool> validateToken(String authToken) async {
  final response = await http.get(
    Uri.parse('https://issuances.dilgbohol.com/auth/validate-token'),
    headers: {'Authorization': 'Bearer $authToken'},
  );

  return response.statusCode == 200;
}
}