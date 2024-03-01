import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'setting_screen.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTabTapped,
  }) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  // Define a list of pages/screens to navigate to
  final List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(
      onFileOpened: (fileName, filePath) {
        // Implement your logic when file is opened
        print('File opened: $fileName');
      },
      // onFileDeleted: null, // or provide a default callback if applicable
    ),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      key: UniqueKey(),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      currentIndex: widget.currentIndex,
      onTap: (index) {
        // Update the state to reflect the selected index
        widget.onTabTapped(index);
        // Use Navigator to navigate to the selected screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => _pages[index]),
        );
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      backgroundColor: Colors.blue[900],
    );
  }

  void navigateToSelectedPage(BuildContext context, int index) {
    Widget page = _pages[index];

    Navigator.pushReplacement(
      context,
      PageTransition(
        child: page,
        type: PageTransitionType.fade, // or choose your transition type
        duration: Duration(milliseconds: 500),
      ),
    );
  }
}
