import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const BottomNavigation({
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTabTapped,
      items: const [
        BottomNavigationBarItem(
          backgroundColor: Color.fromARGB(255, 3, 80, 162),
          icon: Icon(
            Icons.home,
            size: 25,
            color: Colors.white,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.search,
            size: 25,
            color: Colors.white,
          ),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.library_books,
            size: 25,
            color: Colors.white,
          ),
          label: 'Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.people,
            size: 25,
            color: Colors.white,
          ),
          label: 'Profile',
        ),
      ],
      backgroundColor: Color.fromARGB(255, 3, 80, 162),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.5),
    );
  }
}