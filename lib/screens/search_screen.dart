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
  String searchInput = ''; // Add this line to declare and initialize searchInput
  List<String> _recentSearches = [""];
  List<SearchResult> searchResults = [];
  List<MemoCircular> _memoCirculars = [];
  List<MemoCircular> get memoCirculars => _memoCirculars;
  List<PresidentialDirective> _presidentialDirectives = [];
  List<PresidentialDirective> get presidentialDirectives => _presidentialDirectives;
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
        _draftIssuances = data.map((item) => DraftIssuance.fromJson(item)).toList();
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
        _jointCirculars = data.map((item) => JointCircular.fromJson(item)).toList();
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
          _presidentialDirectives = data.map((item) => PresidentialDirective.fromJson(item)).toList();
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

//Republic Acts
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

//Memo Circularsss 
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
        _memoCirculars = data.map((item) => MemoCircular.fromJson(item)).toList();
      });
    } else {
      // Handle error
      print('Failed to load latest issuances');     
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  //legal Opinions
  Future<void> fetchLegalOpinions() async {
    final response = await http.get(
        Uri.parse('$baseURL/legal_opinions'),
        headers: {
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
        _latestIssuances = data.map((item) => LatestIssuance.fromJson(item)).toList();
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
    appBar: AppBar(
      title: Text(
        'Search',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: Builder(
        builder:(context) => IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      backgroundColor: Colors.blue[900],
    ),
    drawer:Sidebar(
      currentIndex: 0,
      onItemSelected: (index){
        _navigateToSelectedPage(context, index);
      },
    ),
  //       bottomNavigationBar: BottomNavigation(
  //   currentIndex: 1, // Set the current index according to your requirement
  //   onTabTapped:(index) {
  //     // Handle the tap event here if needed
  //   },
  // ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20), // Add margin-top here
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20), // Adjust the border radius as needed
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                _handleSearch(); // Call the search function whenever the text changes
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
            SizedBox(height: 20), // Add margin-bottom here
            _buildSearchResultsContainer(), // Updated to manage search results container
          ],
        ),
      ),
    ),
  );
}


Widget _buildSearchResultsContainer() {
  // Check if search results are available
  if (searchResults.isNotEmpty) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSearchResults(searchResults, searchInput),
          SizedBox(height: 20), // Add space between search results and recent searches
        ],
      ),
    );
  } else {
    // Return only recent searches container if no search results
    return _buildRecentSearchesContainer();
  }
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
  Widget _buildSearchResults(List<SearchResult> searchResults, String searchInput) {
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
                          text: highlightTextWithOriginalTitle(result.title, searchInput),
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
  
  // Find indices of matches
  List<int> matches = [];
  int index = text.toLowerCase().indexOf(highlight.toLowerCase());
  while (index != -1) {
    matches.add(index);
    index = text.toLowerCase().indexOf(highlight.toLowerCase(), index + 1);
  }

  // Create text spans with highlighting
  int prevIndex = 0;
  for (int match in matches) {
    
    
        spans.add(TextSpan(
      text: text.substring(prevIndex, match),
      style: TextStyle(color: Colors.black, fontSize: 15), 
    ));
    // Highlight the matching characters
    spans.add(TextSpan(
      text: text.substring(match, match + highlight.length),
      style: TextStyle( color: Colors.blue, fontSize: 15), 
    ));
    prevIndex = match + highlight.length;
  }
  // Add the remaining original text
  spans.add(TextSpan(
    text: text.substring(prevIndex),
    style: TextStyle(color: Colors.black, fontSize: 15), 
  ));

  return TextSpan(children: spans);
}

void _handleSearch() {
  String searchInput = _searchController.text.toLowerCase();

  print('Search Input: $searchInput');

  // Check if the search input is empty
  if (searchInput.isNotEmpty) {
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
    List<SearchResult> searchResults = allData.where((data) {
    
      if (data is MemoCircular) {
        return data.issuance.title.toLowerCase().contains(searchInput) || data.issuance.keyword.toLowerCase().contains(searchInput);
      } else if (data is PresidentialDirective) {
        return data.issuance.title.toLowerCase().contains(searchInput) || data.issuance.keyword.toLowerCase().contains(searchInput);
      } else if (data is RepublicAct) {
        return data.issuance.title.toLowerCase().contains(searchInput) || data.issuance.keyword.toLowerCase().contains(searchInput);
      } else if (data is LegalOpinion) {
        return data.issuance.title.toLowerCase().contains(searchInput) || data.issuance.keyword.toLowerCase().contains(searchInput);
      } else if (data is JointCircular) {
        return data.issuance.title.toLowerCase().contains(searchInput) || data.issuance.keyword.toLowerCase().contains(searchInput);
      } else if (data is DraftIssuance) {
        return data.issuance.title.toLowerCase().contains(searchInput) || data.issuance.keyword.toLowerCase().contains(searchInput);
      } else if (data is LatestIssuance) {
        return data.issuance.title.toLowerCase().contains(searchInput) || data.issuance.keyword.toLowerCase().contains(searchInput);
      }
      return false;
    }).map((data) {
      // Convert filtered data to SearchResult objects
      if (data is MemoCircular) {
        return SearchResult(data.issuance.title, data.issuance.urlLink);
      } else if (data is PresidentialDirective) {
        return SearchResult(data.issuance.title, data.issuance.urlLink);
      } else if (data is RepublicAct) {
        return SearchResult(data.issuance.title, data.issuance.urlLink);
      } else if (data is LegalOpinion) {
        return SearchResult(data.issuance.title, data.issuance.urlLink);
      } else if (data is JointCircular) {
        return SearchResult(data.issuance.title, data.issuance.urlLink);
      } else if (data is DraftIssuance) {
        return SearchResult(data.issuance.title, data.issuance.urlLink);
      } else if (data is LatestIssuance) {
        return SearchResult(data.issuance.title,data.issuance.urlLink);
      }
      return SearchResult('',''); // Return a default SearchResult in case of null
    }).where((result) => result.title.isNotEmpty).toList(); // Filter out empty titles

    // Update the search results and search input within the context of a stateful widget
    setState(() {
      this.searchResults = searchResults;
      this.searchInput = searchInput; // Update the search input
    });
  } else {
    // Clear the search results when the search input is empty
    setState(() {
      this.searchResults = [];
      this.searchInput = searchInput; // Update the search input
    });
  }
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
  
  void _navigateToSelectedPage(BuildContext context, int index) {}
}
class SearchResult {
  final String title;
  final String pdfUrl;
  
  SearchResult(
    this.title,
    this.pdfUrl
  );

}




