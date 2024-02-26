import 'package:DILGDOCS/Services/auth_services.dart';
import 'package:flutter/material.dart';
import 'latest_issuances.dart';
import 'joint_circulars.dart';
import 'memo_circulars.dart';
import 'presidential_directives.dart';
import 'draft_issuances.dart';
import 'republic_acts.dart';
import 'legal_opinions.dart';
import 'home_screen.dart';
import 'about_screen.dart';
import 'developers_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const Sidebar({required this.currentIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue[900],
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[900]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/dilg-main.png',
                    width: 70.0,
                    height: 70.0,
                  ),
                  SizedBox(width: 8.0),
                  const Text(
                    'DILG - BOHOL PROVINCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildSidebarItem(Icons.home, 'Home', 0, context),
            _buildSidebarItem(Icons.article, 'Latest Issuances', 1, context),
            _buildSidebarItem(
                Icons.compare_arrows, 'Joint Circulars', 2, context),
            _buildSidebarItem(Icons.note, 'Memo Circulars', 3, context),
            _buildSidebarItem(
                Icons.gavel, 'Presidential Directives', 4, context),
            _buildSidebarItem(Icons.drafts, 'Draft Issuances', 5, context),
            _buildSidebarItem(
                Icons.account_balance, 'Republic Acts', 6, context),
            _buildSidebarItem(
                Icons.library_books, 'Legal Opinions', 7, context),
            Divider(color: Colors.white),
            _buildSidebarItem(Icons.info, 'About', 8, context),
            _buildSidebarItem(Icons.people, 'Developers', 9, context),
            Divider(color: Colors.white),
          _buildSidebarItem(Icons.exit_to_app, 'Logout', 10, context, onPressed: () async {
            try {
              // Call the logout method (assuming you've implemented it)
              await AuthServices.logout();
              // Clear the stored token
              await clearToken();
              // Navigate to the login screen and remove all previous routes
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            } catch (error) {
              print('Error during logout: $error');
              // Handle the error, if any
            }
          }),
          ],
        ),
      ),
    );
  }
Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
}
  Widget _getPageByIndex(int index) {
    switch (index) {
      case 0:
        return HomeScreen(userData: {},);
      case 1:
        return LatestIssuances();
      case 2:
        return JointCirculars();
      case 3:
        return MemoCirculars();
      case 4:
        return PresidentialDirectives();
      case 5:
        return DraftIssuances();
      case 6:
        return RepublicActs();
      case 7:
        return LegalOpinions();
      case 8:
        return About();
      case 9:
        return Developers();
      // Add cases for other items
      // ...
      default:
        return Container(); // Return a default widget or an empty container
    }
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
    onItemSelected(
        0); // Reset the selected index to home when navigating to a new page
  }

  Widget _buildSidebarItem(
      IconData icon, String title, int index, BuildContext context,
      {VoidCallback? onPressed}) {
    return InkWell(
      onTap: () {
        onItemSelected(index);
        Navigator.of(context).pop(); // Close the sidebar
        _navigateToPage(context, _getPageByIndex(index));
        if (onPressed != null) {
          onPressed();
        }
      },
      child: ListTile(
        title: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24.0),
            SizedBox(width: 8.0),
            Text(
              title,
              style: TextStyle(
                color: currentIndex == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                fontWeight:
                    currentIndex == index ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}