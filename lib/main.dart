import 'package:DILGDOCS/Services/globals.dart';
import 'package:flutter/material.dart';
import 'package:DILGDOCS/screens/splash_screen.dart'; // Import your splash screen widget here
import '../utils/routes.dart';
import '../Services/auth_services.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isAuthenticated = await AuthServices.isAuthenticated();

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.isAuthenticated}) : super(key: key);

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
     incrementDailyUserCount();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tangkaraw',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyText2: TextStyle(
            fontFamily: 'Poppins', // Replace with your font family name
          ),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins', // Replace with your font family name
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
      ),
      // Use SplashScreen as the initial route
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(isAuthenticated: isAuthenticated), // Pass isAuthenticated to SplashScreen
        // Define other routes here
        ...Routes.getRoutes(context),
      },
    );
  }
}

// SplashScreen widget


// AuthenticationWrapper widget
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key, required this.isAuthenticated})
      : super(key: key);

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return isAuthenticated
        ? const HomeScreen()
        : const LoginScreen(title: 'Login');
  }
}

void incrementDailyUserCount() async {
  String localIdentifier = Uuid().v4();

  var response = await http.post(
    Uri.parse('$baseURL/visitor/count'),
    body: {
      'user_identifier': localIdentifier,
    },
  );

  if (response.statusCode == 200) {
    print('Daily user count incremented successfully');
  } else {
    print('Failed to increment daily user count: ${response.statusCode}');
  }
}