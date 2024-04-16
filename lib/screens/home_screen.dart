import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'setting_screen.dart';
import 'sidebar.dart';
import 'bottom_navigation.dart';
import 'issuance_pdf_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Issuance {
  final String title;

  Issuance({required this.title});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  List<String> _drawerMenuItems = [
    'Home',
    'Search',
    'Library',
    'Settings',
  ];

  DateTime? currentBackPressTime;
  List<Issuance> _recentlyOpenedIssuances = [];

  @override
  void initState() {
    super.initState();
    _loadRecentIssuances();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    _saveRecentIssuances();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveRecentIssuances();
    }
  }

  // Load recently opened issuances from SharedPreferences
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

  // Save recently opened issuances to SharedPreferences
  void _saveRecentIssuances() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> titles =
        _recentlyOpenedIssuances.map((issuance) => issuance.title).toList();
    await prefs.setStringList('recentIssuances', titles);
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
        ),
        body: _buildBody(),
        drawer: Sidebar(
          currentIndex: 0,
          onItemSelected: (int) {},
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
                WebViewWideButton(
                  label: 'NEWS AND UPDATES',
                  url: 'https://dilgbohol.com/news_update',
                ),
                WebViewWideButton(
                  label: 'THE PROVINCIAL DIRECTOR',
                  url: 'https://dilgbohol.com/provincial_director',
                ),
                WebViewWideButton(
                  label: 'VISION AND MISSION',
                  url: 'https://dilgbohol.com/about_us',
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
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
            setState(() {
              _recentlyOpenedIssuances.insert(0, Issuance(title: title));
            });
          },
          onFileDeleted: (title) {
            setState(() {
              _recentlyOpenedIssuances
                  .removeWhere((issuance) => issuance.title == title);
            });
          },
        );
      case 3:
        return SettingsScreen();
      default:
        return SizedBox();
    }
  }

  Widget _buildRecentIssuances() {
    Map<String, Issuance> seenTitles = {};
    List<Issuance> recentIssuances = _recentlyOpenedIssuances.take(5).toList();

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
                  fontFamily: 'Poppins',
                ),
              ),
              if (_recentlyOpenedIssuances.length >= 1)
                GestureDetector(
                  onTap: () {
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
                        fontFamily: 'Poppins',
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
                fontFamily: 'Poppins',
              ),
            ),
          ),
        if (_recentlyOpenedIssuances.isNotEmpty) ...[
          ...recentIssuances.map((issuance) {
            if (seenTitles.containsKey(issuance.title)) {
              return Container();
            } else {
              seenTitles[issuance.title] = issuance;
              return Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    issuance.title.length > 30
                        ? '${issuance.title.substring(0, 30)}...'
                        : issuance.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _recentlyOpenedIssuances.remove(issuance);
                      _recentlyOpenedIssuances.insert(0, issuance);
                    });
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
}

class WebViewWideButton extends StatelessWidget {
  final String label;
  final String url;

  const WebViewWideButton({Key? key, required this.label, required this.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(url: url, label: label),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.blue[600],
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
                fontFamily: 'Poppins',
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
}

class WebViewPage extends StatelessWidget {
  final String label;
  final String url;

  const WebViewPage({Key? key, required this.label, required this.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(label), // Use the label as the title
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}