import 'package:flutter/material.dart';
import 'package:anim_search_bar/anim_search_bar.dart';

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
              AnimSearchBar(
                width: 400,
                onSubmitted: (query) {
                  // Handle the submitted search query
                  print('Search submitted: $query');
                },
                onSuffixTap: () {
                  setState(() {
                    _searchController.clear();
                  });
                },
                color: Colors.blue[400]!,
                helpText: "Search...",
                autoFocus: true,
                closeSearchOnSuffixTap: true,
                animationDurationInMilli: 750,
                rtl: true,
                textController: _searchController,
              ),
              _buildRecentSearchesContainer(),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the search input with rounded border
  // Widget _buildSearchInput() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(10),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.5),
  //           spreadRadius: 1,
  //           blurRadius: 3,
  //           offset: Offset(0, 2),
  //         ),
  //       ],
  //     ),

  //   );
  // }

  // Method to build the recent searches container or card
  Widget _buildRecentSearchesContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200], // Gray background
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Recent Searches as Faded Color Dropdown
              if (_recentSearches.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No recent searches',
                    style: TextStyle(color: Colors.black),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: _recentSearches.map((String value) {
                      return ListTile(
                        title: Text(
                          value,
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          _handleRecentSearchTap(value);
                        },
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
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
}