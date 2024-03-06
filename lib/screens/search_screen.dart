import 'dart:convert';

import 'package:DILGDOCS/Services/globals.dart';
import 'package:DILGDOCS/models/republic_acts.dart';
import 'package:DILGDOCS/screens/details.dart';


import 'package:DILGDOCS/utils/routes.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../models/draft_issuances.dart';
import '../models/joint_circulars.dart';
import '../models/latest_issuances.dart';
import '../models/legal_opinions.dart';
import '../models/memo_circulars.dart';
import '../models/presidential_directives.dart';
import 'sidebar.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String searchInput = '';
  List<String> _recentSearches = [""];
  List<SearchResult> searchResults = [];
  List<MemoCircular> _memoCirculars = [];
  List<MemoCircular> get memoCirculars => _memoCirculars;
  List<PresidentialDirective> _presidentialDirectives = [];
  List<PresidentialDirective> get presidentialDirectives =>
      _presidentialDirectives;
  List<RepublicAct> _republicActs = [];
  List<RepublicAct> get republicActs => _republicActs;
  List<LegalOpinion> _legalOpinions = [];
  List<LegalOpinion> get legalOpinions => _legalOpinions;
  List<JointCircular> _jointCirculars = [];
  List<JointCircular> get jointCirculars => _jointCirculars;
  List<DraftIssuance> _draftIssuances = [];
  List<DraftIssuance> get draftIssuances => _draftIssuances;
  List<LatestIssuance> _latestIssuances = [];
  List<LatestIssuance> get latestIssuances => _latestIssuances;


  bool isSearching = false;
  bool showNoMatchFound = false;

  @override
  void initState() {
    super.initState();
  
    fetchRepublicActs();
    fetchPresidentialCirculars();
    fetchLegalOpinions();
    fetchMemoCirculars();
    fetchLatestIssuances();
    fetchJointCirculars();
    fetchDraftIssuances();
  }


 

  @override
  void dispose() {
    // Cancel any ongoing asynchronous operations here
    // For example, canceling network requests, timers, etc.
    super.dispose();
    _searchController.dispose();
  }

  Future<void> fetchDraftIssuances() async {
    final response = await http.get(
      Uri.parse('$baseURL/draft_issuances'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['drafts'];
      setState(() {
        _draftIssuances =
            data.map((item) => DraftIssuance.fromJson(item)).toList();
      });
    } else {
      // Handle error
      print('Failed to load Draft issuances');

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> fetchJointCirculars() async {
    final response = await http.get(
      Uri.parse('$baseURL/joint_circulars'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['joints'];

      setState(() {
        _jointCirculars =
            data.map((item) => JointCircular.fromJson(item)).toList();
      });
    } else {
      // Handle error
      print('Failed to load latest issuances');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

//Presidential Directives
  Future<void> fetchPresidentialCirculars() async {
    final response = await http.get(
      Uri.parse('$baseURL/presidential_directives'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body)['presidentials'];

      if (data != null) {
        print('Presidential Directives Data: $data');

        setState(() {
          _presidentialDirectives =
              data.map((item) => PresidentialDirective.fromJson(item)).toList();
        });
      } else {
        print('Presidential Directives Data is null');
      }
    } else {
      // Handle error
      print('Failed to load latest issuances');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

// Republic Acts
  Future<void> fetchRepublicActs() async {
    final response = await http.get(
      Uri.parse('$baseURL/republic_acts'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['republics'];

      setState(() {
        _republicActs = data.map((item) => RepublicAct.fromJson(item)).toList();
      });
    } else {
      // Handle error
      print('Failed to load republic acts');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

// Memo Circulars
  Future<void> fetchMemoCirculars() async {
    final response = await http.get(
      Uri.parse('$baseURL/memo_circulars'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['memos'];

      setState(() {
        _memoCirculars =
            data.map((item) => MemoCircular.fromJson(item)).toList();
      });
    } else {
      // Handle error
      print('Failed to load latest issuances');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  // Legal Opinions
  Future<void> fetchLegalOpinions() async {
    final response =
        await http.get(Uri.parse('$baseURL/legal_opinions'), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['legals'];

      setState(() {
        _legalOpinions =
            data.map((item) => LegalOpinion.fromJson(item)).toList();
      });
    } else {
      print('Failed to load latest legal opinions');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> fetchLatestIssuances() async {
    final response = await http.get(
      Uri.parse('$baseURL/latest_issuances'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['latests'];

      setState(() {
        _latestIssuances =
            data.map((item) => LatestIssuance.fromJson(item)).toList();
      });
    } else {
      // Handle error
      print('Failed to load latest issuances');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(
        currentIndex: 0,
        onItemSelected: (index) {
          _navigateToSelectedPage(context, index);
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  // prefixIcon: IconButton(
                                  //   icon: Icon(Icons.mic),
                                  //   onPressed: () {
                                  //     print('Microphone Icon Tapped');
                                  //     _startListening();
                                  //   },
                                  // ),
                                ),
                                onChanged: (value) {
                                  _handleSearch();
                                },
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
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildSearchResultsContainer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsContainer() {
    if (isSearching) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (showNoMatchFound) {
      return Center(
        child: Text('No match found'),
      );
    } else if (searchResults.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchResults(searchResults, searchInput),
            SizedBox(height: 20),
          ],
        ),
      );
    } else {
      return _buildRecentSearchesContainer();
    }
  }

  Widget _buildRecentSearchesContainer() {
    List<Map<String, dynamic>> containerInfo = [
      {
        'name': 'Latest Issuances',
        'route': Routes.latestIssuances,
        'color': Colors.blue,
        'icon': Icons.book
      },
      {
        'name': 'Joint Circulars',
        'route': Routes.jointCirculars,
        'color': Colors.red,
        'icon': Icons.compare_arrows
      },
      {
        'name': 'Memo Circulars',
        'route': Routes.memoCirculars,
        'color': Colors.green,
        'icon': Icons.note
      },
      {
        'name': 'Presidential Directives',
        'route': Routes.presidentialDirectives,
        'color': Colors.pink,
        'icon': Icons.account_balance
      },
      {
        'name': 'Draft Issuances',
        'route': Routes.draftIssuances,
        'color': Colors.purple,
        'icon': Icons.drafts
      },
      {
        'name': 'Republic Acts',
        'route': Routes.republicActs,
        'color': Colors.teal,
        'icon': Icons.gavel
      },
      {
        'name': 'Legal Opinions',
        'route': Routes.legalOpinions,
        'color': Colors.orange,
        'icon': Icons.library_add_check_outlined
      },
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
               fontFamily: 'Poppins'
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          children: List.generate(containerInfo.length, (index) {
            Map<String, dynamic> item = containerInfo[index];
            return Card(
              elevation: 3,
              margin: EdgeInsets.all(8),
              child: InkWell(
                onTap: () {
                  _handleContainerTap(context, item['route']);
                },
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'],
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          item['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                             fontFamily: 'Poppins'
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              color: item['color'],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchResults(
      List<SearchResult> searchResults, String searchInput) {
    if (searchInput.isEmpty) {
      return SizedBox.shrink();
    }
    return searchResults.isNotEmpty
        ? SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final SearchResult result = searchResults[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              searchResult: result,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: RichText(
                          text: highlightTextWithOriginalTitle(
                              result.title, searchInput),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        : Center(child: Text('No results found'));
  }

  TextSpan highlightTextWithOriginalTitle(String text, String highlight) {
    List<TextSpan> spans = [];

    List<int> matches = [];
    int index = text.toLowerCase().indexOf(highlight.toLowerCase());
    while (index != -1) {
      matches.add(index);
      index = text.toLowerCase().indexOf(highlight.toLowerCase(), index + 1);
    }

    int prevIndex = 0;
    for (int match in matches) {
      spans.add(TextSpan(
        text: text.substring(prevIndex, match),
        style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Poppins'),
      ));
      spans.add(TextSpan(
        text: text.substring(match, match + highlight.length),
        style: TextStyle(color: Colors.blue, fontSize: 15,  fontFamily: 'Poppins'),
      ));
      prevIndex = match + highlight.length;
    }
    spans.add(TextSpan(
      text: text.substring(prevIndex),
      style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Poppins'),
    ));

    return TextSpan(children: spans);
  }

  void _handleSearch() {
  String searchInput = _searchController.text.toLowerCase();

  // Check if the search input meets the minimum character requirement
  if (searchInput.length >= 2) {
    // Perform the search operation
    _performSearch(searchInput);
  } else {
    // Clear the search results when the search input doesn't meet the minimum character requirement
    setState(() {
      this.searchResults = [];
      this.searchInput = searchInput; // Update the search input
    });
  }
}

void _performSearch(String searchInput) {
  // Flatten the list of lists into a single list
  List<dynamic> allData = [
    ..._memoCirculars,
    ..._presidentialDirectives,
    ..._republicActs,
    ..._legalOpinions,
    ..._jointCirculars,
    ..._draftIssuances,
    ..._latestIssuances,
  ];

  // Filter the data based on search input and convert to SearchResult objects
  List<SearchResult> searchResults = allData
      .where((data) =>
          (data is MemoCircular ||
              data is PresidentialDirective ||
              data is RepublicAct ||
              data is LegalOpinion ||
              data is JointCircular ||
              data is DraftIssuance ||
              data is LatestIssuance) &&
          (data.issuance.title.toLowerCase().contains(searchInput) ||
              data.issuance.keyword.toLowerCase().contains(searchInput)))
      .map((data) => SearchResult(data.issuance.title, data.issuance.urlLink))
      .where((result) => result.title.isNotEmpty)
      .toList();

  // Update the search results and search input within the context of a stateful widget
 
      setState(() {
    this.searchResults = searchResults;
    this.searchInput = searchInput;
    isSearching = false;
    showNoMatchFound = searchResults.isEmpty;
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

  void _handleContainerTap(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  void _navigateToSelectedPage(BuildContext context, int index) {}
}

class SearchResult {
  final String title;
  final String pdfUrl;

  SearchResult(this.title, this.pdfUrl);
}