import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:DILGDOCS/screens/home_screen.dart';
import '../Services/auth_services.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.title});

  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  String emailError = '';
  String passwordError = '';
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoggingIn = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    checkLoggedIn();
  }

  Future<void> saveAuthToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> clearAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  void checkLoggedIn() async {
    String? authToken = await getAuthToken();
    if (authToken != null) {
      bool isValidToken = await AuthServices.validateToken(authToken);
      if (isValidToken) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  HomeScreen()),
        );
      } else {
        clearAuthToken();
      }
    }
  }

  loginPressed() async {
    setState(() {
      _isLoggingIn = true;
    });
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      try {
        http.Response response = await AuthServices.login(
          _emailController.text,
          _passwordController.text,
        );

        Map responseMap = jsonDecode(response.body);

        print("Server Response: $responseMap");

        if (response.statusCode == 200) {
          final token = responseMap['token'];

          await AuthServices.storeToken(token);
          await AuthServices.storeAuthenticated(true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  HomeScreen()),
          );
        } else {
          setState(() {
            emailError = '';
            passwordError = responseMap['message'] ?? 'Login failed';
          });
        }
      } catch (error, stackTrace) {
        print("Error during login: $error");
        print("Stack trace: $stackTrace");
        setState(() {
          emailError = '';
          passwordError = 'Incorrect email or password';
        });
      }
    } else {
      setState(() {
        emailError = 'Enter your email';
        passwordError = 'Enter your password';
      });
    }
    setState(() {
      _isLoggingIn = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 34,
                backgroundImage: AssetImage('assets/dilg-main.png'),
              ),
              SizedBox(height: 15),
              Text(
                'Department of the Interior and Local Government - Bohol Province',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 0, 0, 255)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Sign in to your Account',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: emailError.isNotEmpty ? emailError : null,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText:
                            passwordError.isNotEmpty ? passwordError : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value!;
                            });
                          },
                        ),
                        Text('Remember Me'),
                        Spacer(),
                        ElevatedButton(
                          onPressed: _isLoggingIn ? null : loginPressed,
                          child: _isLoggingIn
                              ? CircularProgressIndicator()
                              : Text('Log in'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              Text(
                '© DILG-Bohol Province 2024',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color.fromARGB(255, 6, 0, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}