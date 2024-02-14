import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'sidebar.dart';
import 'latest_issuances.dart';
import 'edit_user.dart';
import 'bottom_navigation.dart'; // Import the BottomNavigation widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<String> _drawerMenuItems = [
    'Home',
    'Search',
    'Library',
    'View Profile',
  ];

  DateTime? currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        } else if (currentBackPressTime == null ||
            DateTime.now().difference(currentBackPressTime!) >
                Duration(seconds: 2)) {
          // Show a toast or snackbar indicating to press back again to exit
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          currentBackPressTime = DateTime.now();
          return false; // Do not exit
        } else {
          return true; // Exit the app
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _drawerMenuItems[
                _currentIndex.clamp(0, _drawerMenuItems.length - 1)],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: _currentIndex == 0
              ? Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: Colors.blue[900]),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : null,
          automaticallyImplyLeading: true,
        ),
        body: _buildBody(),
        drawer: Sidebar(
          currentIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() {
              _currentIndex = index.clamp(0, _drawerMenuItems.length - 1);
            });
          },
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: _currentIndex,
          onTabTapped: (index) {
            setState(() {
              _currentIndex = index.clamp(0, _drawerMenuItems.length - 1);
            });
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        // Home Screen
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Recently Opened Issuances
            const Text(
              'Recently Opened Issuances',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecentIssuances(),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Recently Downloaded Issuances
          ],
        );
      case 1:
        // Search Screen
        return SearchScreen();
      case 2:
        // Library Screen
        return LibraryScreen();
      case 3:
        return EditUser();
      default:
        return Container();
    }
  }

  Widget _buildRecentIssuances() {
    List<Map<String, String>> recentIssuances = [
      {'title': 'Issuance 1', 'subtitle': 'Subtitle for Issuance 1'},
      {'title': 'Issuance 2', 'subtitle': 'Subtitle for Issuance 2'},
      {'title': 'Issuance 3', 'subtitle': 'Subtitle for Issuance 3'},
      {'title': 'Issuance 4', 'subtitle': 'Subtitle for Issuance 4'},
      {'title': 'Issuance 5', 'subtitle': 'Subtitle for Issuance 5'},
      {'title': 'Issuance 6', 'subtitle': 'Subtitle for Issuance 6'},
      {'title': 'Issuance 7', 'subtitle': 'Subtitle for Issuance 7'},
      {'title': 'Issuance 8', 'subtitle': 'Subtitle for Issuance 8'},
      {'title': 'Issuance 9', 'subtitle': 'Subtitle for Issuance 9'},
      {'title': 'Issuance 10', 'subtitle': 'Subtitle for Issuance 10'},
      // Add more issuances as needed
    ];

    return Column(
      children: recentIssuances
          .take(10) // Display a maximum of 10 recent issuances
          .map((issuance) {
        return Column(
          children: [
            ListTile(
              title: Text(issuance['title']!),
              subtitle: Text(issuance['subtitle']!),
              trailing: ElevatedButton(
                onPressed: () {
                  // Handle button press
                },
                child: Text('View'),
              ),
            ),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

  // Widget _buildRecentlyDownloadedIssuances() {
  //   return SizedBox(
  //     height: 300.0,
  //     child: ListView.builder(
  //       itemCount: 1,
  //       itemBuilder: (context, index) {
  //         return const Card(
  //           child: ListTile(
  //             title: Text('Issuance 1'),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  void _navigateToLatestIssuances(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LatestIssuances(),
      ),
    );
  }
}