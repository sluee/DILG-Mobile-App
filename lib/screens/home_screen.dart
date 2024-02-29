import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'sidebar.dart';
import 'edit_user.dart';
import 'bottom_navigation.dart';
import 'issuance_pdf_screen.dart'; // Import the new screen
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

  void _clearRecentIssuances() {
    setState(() {
      _recentlyOpenedIssuances.clear();
    });
    _saveRecentIssuances();
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/dilg-main.png',
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'News and Updates:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 250.0, // Adjust the height as needed
              child: _buildHorizontalScrollableCards(),
            ),
            _buildWideButton('ABOUT', 'https://dilgbohol.com'),
            _buildWideButton(
                'THE PROVINCIAL DIRECTOR', 'https://dilgbohol.com'),
            _buildWideButton('VISION AND MISSION', 'https://dilgbohol.com'),
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
  }

  Widget _buildRecentIssuances() {
    // Map to keep track of seen titles
    Map<String, Issuance> seenTitles = {};

    // Get the first 5 recently opened issuances
    List<Issuance> recentIssuances = _recentlyOpenedIssuances.take(5).toList();

    // Initially, don't show the "See more" link
    Widget seeMoreLink = Container();

    // Show the "See more" link only if there are more than 5 recent issuances
    if (_recentlyOpenedIssuances.length > 5) {
      seeMoreLink = TextButton(
        onPressed: () {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Opened Issuances',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              seeMoreLink,
            ],
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
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          issuance.title.length > 20
                              ? '${issuance.title.substring(0, 20)}...' // Display only the first 25 characters
                              : issuance.title,
                        ),
                        ElevatedButton(
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
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              );
            }
          }).toList(),
          // Add clear list button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Prompt the user to confirm before clearing the list
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Clear List'),
                      content: Text(
                          'Are you sure you want to clear the list of recently opened issuances?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _clearRecentIssuances(); // Clear the list
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Clear'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Clear List'),
            ),
          ),
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
                fontSize: 18.0,
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

  PageController _pageController = PageController();

  Widget _buildHorizontalScrollableCards() {
    return Container(
      height: 150.0,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: 6, // Change the itemCount to 6 for 6 cards
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCard('assets/amu1.png', 'Card Title 0', index);
          } else if (index == 1) {
            return _buildCard('assets/amu2.png', 'Card Title 1', index);
          } else if (index == 2) {
            return _buildCard('assets/amu3.png', 'Card Title 2', index);
          } else if (index == 3) {
            return _buildCard('assets/amu4.png', 'Card Title 3', index);
          } else if (index == 4) {
            return _buildCard('assets/amu5.png', 'Card Title 4', index);
          } else if (index == 5) {
            // Display "See More" container for index 5
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Card(
                elevation: 5.0,
                child: InkWell(
                  onTap: () {
                    // Handle "See More" click
                    print('See More clicked');
                  },
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        // Define the URL to redirect to
                        String url = 'https://dilgbohol.com/news_update';
                        // Open the URL in a web browser
                        launch(url);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Go to News Updates',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          SizedBox(
                              height:
                                  5), // Adjust spacing between text and icon
                          Icon(
                            Icons.arrow_forward,
                            size: 25.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {}
        },
      ),
    );
  }

  Widget _buildCard(String imagePath, String title, int index) {
    return GestureDetector(
      onTap: () {
        // Handle card click
        print('Card $index clicked');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        width: 200.0,
        child: Card(
          elevation: 5.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container
              Container(
                height: 115.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Title container
              Container(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              // Content container
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  style: TextStyle(fontSize: 12.0),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Date container
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Date: ${DateTime.now().toString()}',
                  style: TextStyle(fontSize: 10.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}