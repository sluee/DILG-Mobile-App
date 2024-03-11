import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'settings_screen.dart';
import 'sidebar.dart';
import 'bottom_navigation.dart';
import 'issuance_pdf_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package

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
    'Setting',
  ];

  DateTime? currentBackPressTime;

  List<Issuance> _recentlyOpenedIssuances = [];

  @override
  void initState() {
    super.initState();
    _loadRecentIssuances();
  }

  void _loadRecentIssuances() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentIssuances = prefs.getStringList('recentIssuances');
    if (recentIssuances != null) {
      setState(() {
        _recentlyOpenedIssuances =
            recentIssuances.map((title) => Issuance(title: title)).toList();
      });
    }
  }

  void _saveRecentIssuances() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> titles =
        _recentlyOpenedIssuances.map((issuance) => issuance.title).toList();
    await prefs.setStringList('recentIssuances', titles);
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
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/tngkrw.png',
                      width: 60.0,
                      height: 60.0,
                    ),
                    const SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REPUBLIC OF THE PHILIPPINES',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        Text(
                          'DEPARTMENT OF THE INTERIOR AND LOCAL GOVERNMENT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                        Text(
                          'BOHOL PROVINCE',
                          style: TextStyle(
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                _buildWideButton(
                    'NEWS AND UPDATES', 'https://dilgbohol.com/news_update'),
                _buildWideButton('THE PROVINCIAL DIRECTOR',
                    'https://dilgbohol.com/provincial_director'),
                _buildWideButton(
                    'VISION AND MISSION', 'https://dilgbohol.com/about_us'),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical, // Ensure vertical scrolling
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRecentIssuances(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      case 1:
        return SearchScreen();
      case 2:
        return LibraryScreen(
          onFileOpened: (title, subtitle) {
            // Add the opened file to recently opened issuances
            setState(() {
              _recentlyOpenedIssuances.insert(0, Issuance(title: title));
            });
          },
          onFileDeleted: (title) {
            // Remove the deleted issuance from the list of recently opened issuances
            setState(() {
              _recentlyOpenedIssuances
                  .removeWhere((issuance) => issuance.title == title);
            });
          },
        );
      case 3:
        return SettingsScreen();

      default:
        return SizedBox(); // Return an empty widget for unsupported index
    }
  }

  Widget _buildRecentIssuances() {
    // Map to keep track of seen titles
    Map<String, Issuance> seenTitles = {};

    // Get the first 5 recently opened issuances
    List<Issuance> recentIssuances = _recentlyOpenedIssuances.take(5).toList();

    // Show the "Clear List" button only if there are recent issuances
    Widget clearListButton = _recentlyOpenedIssuances.isNotEmpty
        ? ElevatedButton(
            onPressed: () {
              setState(() {
                _recentlyOpenedIssuances.clear();
              });
            },
            child: Text('Clear List'),
          )
        : SizedBox();

    // See More Button
    Widget seeMoreButton = SizedBox();
    if (_recentlyOpenedIssuances.length > 4) {
      seeMoreButton = TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LibraryScreen(
                onFileOpened:
                    (title, subtitle) {}, // Provide dummy function or null
              ),
            ),
          );
        },
        child: Text('See More'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Opened Issuances',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 2,
                height: 2,
              ),
              GestureDetector(
                onTap: () {
                  // Add your clear list logic here
                  // For example, you can clear the list by setting _recentlyOpenedIssuances to an empty list
                  setState(() {
                    _recentlyOpenedIssuances.clear();
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Clear List',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14.0),
        if (_recentlyOpenedIssuances.isEmpty)
          Center(
            child: Text(
              'No recently opened Issuance/s',
              style: TextStyle(
                fontSize: 14,
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
              return Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    issuance.title.length > 30
                        ? '${issuance.title.substring(0, 30)}...'
                        : issuance.title,
                  ),
                  onTap: () {
                    // Remove the current issuance from the list
                    setState(() {
                      _recentlyOpenedIssuances.remove(issuance);
                    });
                    // Add the current issuance to the top of the list
                    setState(() {
                      _recentlyOpenedIssuances.insert(0, issuance);
                    });
                    // Navigate to the PDF screen when the item is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IssuancePDFScreen(
                          title: issuance.title,
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildWideButton(String label, String url) {
    return GestureDetector(
      onTap: () {
        _launchURL(url);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.blue[600], // Adjust the color as needed
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch URLs
  void _launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}
