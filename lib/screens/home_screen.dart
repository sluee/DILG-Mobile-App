import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_screen.dart';
import 'sidebar.dart';
import 'edit_user.dart';
import 'bottom_navigation.dart';
import 'issuance_pdf_screen.dart';
import 'library_screen.dart';

class Issuance {
  final String title;
  Issuance({required this.title});
}

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

  List<Issuance> _recentlyOpenedIssuances = [];

  @override
  void initState() {
    super.initState();
    _loadRecentIssuances();
  }

  void _loadRecentIssuances() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? recentIssuances = prefs.getStringList('recentIssuances');
      if (recentIssuances != null) {
        setState(() {
          _recentlyOpenedIssuances =
              recentIssuances.map((title) => Issuance(title: title)).toList();
        });
      }
    } catch (e) {
      // Handle error while loading recent issuances
      print('Error loading recent issuances: $e');
    }
  }

  void _saveRecentIssuances() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> titles =
          _recentlyOpenedIssuances.map((issuance) => issuance.title).toList();
      await prefs.setStringList('recentIssuances', titles);
    } catch (e) {
      // Handle error while saving recent issuances
      print('Error saving recent issuances: $e');
    }
  }

  @override
  void dispose() {
    _saveRecentIssuances();
    super.dispose();
  }

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          currentBackPressTime = DateTime.now();
          return false;
        } else {
          return true;
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
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildRecentIssuances(),
          ],
        );
      case 1:
        return SearchScreen();
      case 2:
        return LibraryScreen(
          onFileOpened: (title, subtitle) {
            // Add the opened file to recently opened issuances
            setState(() {
              _recentlyOpenedIssuances.insert(
                0,
                Issuance(title: title),
              );
            });
          },
        );
      case 3:
        return EditUser();
      default:
        return Container();
    }
  }

  Widget _buildRecentIssuances() {
    // Map to keep track of seen titles
    Map<String, Issuance> seenTitles = {};

    // Get the first 5 recently opened issuances
    List<Issuance> recentIssuances = _recentlyOpenedIssuances.take(5).toList();

    Widget seeMoreLink = Container(); // Initially, don't show the link

    // Show the "See more" link only if there are more than 5 recent issuances
    if (_recentlyOpenedIssuances.length > 5) {
      seeMoreLink = GestureDetector(
        onTap: () {
          // Navigate to the Library screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LibraryScreen(
                onFileOpened: (title, subtitle) {
                  // Add the opened file to recently opened issuances
                  setState(() {
                    _recentlyOpenedIssuances.insert(
                      0,
                      Issuance(title: title),
                    );
                  });
                },
              ),
            ),
          );
        },
        child: Text(
          'See more',
          style: TextStyle(
            color: Colors.blue, // Set the color to blue
            decoration: TextDecoration.none, // Remove underline
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Recently Opened Issuances',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        if (_recentlyOpenedIssuances.isEmpty)
          Center(
            child: Text(
              'No recently opened Issuance/s',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (_recentlyOpenedIssuances.isNotEmpty) ...[
          ...recentIssuances.map((issuance) {
            // Check if the title has already been seen
            if (seenTitles.containsKey(issuance.title)) {
              // If yes, skip displaying this issuance
              return Container();
            } else {
              // Otherwise, add it to seen titles and display it
              seenTitles[issuance.title] = issuance;
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      issuance.title.length > 25
                          ? '${issuance.title.substring(0, 25)}...' // Display only the first 25 characters
                          : issuance.title,
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Remove the current issuance from the list
                        setState(() {
                          _recentlyOpenedIssuances.remove(issuance);
                        });
                        // Add the current issuance to the top of the list
                        setState(() {
                          _recentlyOpenedIssuances.insert(0, issuance);
                        });
                        // Navigate to the PDF screen when the button is pressed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IssuancePDFScreen(
                              title: issuance.title,
                            ),
                          ),
                        );
                      },
                      child: Text('View'),
                    ),
                  ),
                  const Divider(),
                ],
              );
            }
          }).toList(),
          seeMoreLink, // Show the "See more" link
        ],
      ],
    );
  }
}
