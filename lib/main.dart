import 'package:flutter/material.dart';
import 'package:DILGDOCS/screens/splash_screen.dart';
import '../utils/routes.dart';
import '../Services/auth_services.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

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
        ...Routes.getRoutes(context),
      },
    );
  }
}



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
