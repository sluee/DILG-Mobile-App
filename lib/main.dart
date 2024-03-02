import 'package:DILGDOCS/screens/bottom_navigation.dart';
import 'package:DILGDOCS/screens/home_screen.dart';
import 'package:DILGDOCS/screens/library_screen.dart';
import 'package:DILGDOCS/screens/login_screen.dart';
import 'package:DILGDOCS/screens/search_screen.dart';
import 'package:DILGDOCS/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import '../utils/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DILG Bohol',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      initialRoute: Routes.login,
      // routes: Routes.getRoutes(context),
      // home: BottomNavigationPage(), 
      routes: Routes.getRoutes(context),

      
     // onGenerateRoute: (settings) {
      //   // Handle unknown routes, such as pressing the back button
      //   return MaterialPageRoute(builder: (context) => const HomeScreen());
      // },
    );
  }
  
}
class BottomNavigationPage extends StatefulWidget {
  @override
  _BottomNavigationPageState createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _currentIndex = 0;

  // List of titles for each screen
  List<String> _titles = ['Home', 'Search', 'Library', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]), // Dynamic app bar title
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(),
          SearchScreen(),
          LibraryScreen(
            onFileOpened: (fileName, filePath) {
              // Implement your logic when file is opened
              print('File opened: $fileName');
            },
            onFileDeleted: (filePath) {
              // Implement your logic when file is deleted
              print('File deleted: $filePath');
            },
          ),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTabTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
