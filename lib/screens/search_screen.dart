import 'package:DILGDOCS/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'dart:math';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [""];
  

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _handleSearch();
                  },
                ),
              ],
            ),
            SizedBox(height: 20), // Add some space between the search bar and recent searches
            _buildRecentSearchesContainer(),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildRecentSearchesContainer() {
  // Define a list of container names, routes, colors, and icons
  List<Map<String, dynamic>> containerInfo = [
    {'name': 'Latest Issuances', 'route': Routes.latestIssuances, 'color': Colors.blue, 'icon': Icons.book},
    {'name': 'Joint Circulars', 'route': Routes.jointCirculars, 'color': Colors.red, 'icon': Icons.compare_arrows},
    {'name': 'Memo Circulars', 'route': Routes.memoCirculars, 'color': Colors.green, 'icon': Icons.note},
    {'name': 'Presidential Directives', 'route': Routes.presidentialDirectives, 'color': Colors.pink, 'icon': Icons.account_balance},
    {'name': 'Draft Issuances', 'route': Routes.draftIssuances, 'color': Colors.purple, 'icon': Icons.drafts},
    {'name': 'Republic Acts', 'route': Routes.republicActs, 'color': Colors.teal, 'icon': Icons.gavel},
    {'name': 'Legal Opinions', 'route': Routes.legalOpinions, 'color': Colors.orange, 'icon': Icons.library_add_check_outlined},
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Browse All',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Disable GridView scrolling
        crossAxisCount: 2, // Adjust the cross axis count as needed
        children: List.generate(containerInfo.length, (index) {
          Map<String, dynamic> item = containerInfo[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                _handleContainerTap(context, item['route']); // Pass the route of the tapped container
              },
              child: AspectRatio(
                aspectRatio: 1, // Set the aspect ratio as needed
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'], // Use the predefined icon
                        color: Colors.white, // Set icon color to white
                      ),
                      SizedBox(height: 8),
                      Text(
                        item['name'], // Use the predefined name
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Set text color to white
                        ),
                        textAlign: TextAlign.center, // Center align the text horizontally
                      ),
                    ],
                  ),
                ),
              ),
            ),
            color: item['color'], // Use the predefined color
          );
        }),
      ),
    ],
  );
}


  // Method to handle the search button press
  void _handleSearch() {
    String searchInput = _searchController.text;
    // Implement the search functionality here
    // For now, let's just print the search input
    print('Searching for: $searchInput');

    // Add the search input to recent searches
    setState(() {
      _recentSearches.insert(0, searchInput);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    });
  }

  // Method to handle the tapped recent search item
  void _handleRecentSearchTap(String value) {
    // Implement the handling of tapped recent search item
    setState(() {
      _recentSearches.remove(value);
      _recentSearches.insert(0, value);
    });
  }

  void _handleContainerTap(context, String route) {
    // Use Navigator to navigate to the desired route
    Navigator.pushNamed(context, route);
  }
}
