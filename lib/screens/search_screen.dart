import 'dart:convert';
import 'dart:io';

import 'package:DILGDOCS/screens/draft_issuances.dart';
import 'package:DILGDOCS/screens/joint_circulars.dart';
import 'package:DILGDOCS/screens/latest_issuances.dart';
import 'package:DILGDOCS/screens/legal_opinions.dart';
import 'package:DILGDOCS/screens/memo_circulars.dart';
import 'package:DILGDOCS/screens/presidential_directives.dart';
import 'package:DILGDOCS/screens/republic_acts.dart';
import 'package:DILGDOCS/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// import 'package:anim_search_bar/anim_search_bar.dart';
// import 'dart:math';
import 'package:http/http.dart' as http;

import 'details_screen.dart';

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

Future<void> fetchDraftIssuances() async {
    final response = await http.get(
      Uri.parse('https://issuances.dilgbohol.com/api/draft_issuances'),
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
      Uri.parse('https://issuances.dilgbohol.com/api/joint_circulars'),
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
      Uri.parse('https://issuances.dilgbohol.com/api/presidential_directives'),
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
      Uri.parse('https://issuances.dilgbohol.com/api/republic_acts'),
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
      Uri.parse('https://issuances.dilgbohol.com/api/memo_circulars'),
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
        Uri.parse('https://issuances.dilgbohol.com/api/legal_opinions'),
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
      Uri.parse('https://issuances.dilgbohol.com/api/latest_issuances'),
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
                    onChanged: (value) {
                      _handleSearch(); // Call the search function whenever the text changes
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _handleSearch(); // You can remove this line if you want to rely only on text input for searching
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            SingleChildScrollView( // Wrap _buildSearchResults with SingleChildScrollView
              child: _buildSearchResults(searchResults, searchInput), // Display search results if available
            ),
            SizedBox(height: 20), // Add some space between search results and recent searches
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
Widget _buildSearchResults(List<SearchResult> searchResults, String searchInput) {
  if (searchInput.isEmpty) {
    return SizedBox.shrink(); // Return an empty SizedBox if there's no search input
  }

  return searchResults.isNotEmpty
      ? ListView.builder(
          shrinkWrap: true,
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final SearchResult result = searchResults[index];
            return GestureDetector(
 onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DetailsScreen(
      searchResult: result, // Pass the SearchResult object
    )),
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
    child: Text(
      result.title,
      style: TextStyle(fontSize: 16),
    ),
  ),
);

          },
        )
      : Center(child: Text('No results found')); // Display a message if there are no search results
}



  // Method to handle the search button press
 // Method to handle the search button press
// Method to handle the search button press
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
      // Implement your search logic here
      // For example, you can search for a specific property in each data item
      // You can customize this logic based on your data structure
      if (data is MemoCircular) {
        return data.issuance.title.toLowerCase().contains(searchInput);
      } else if (data is PresidentialDirective) {
        return data.issuance.title.toLowerCase().contains(searchInput);
      } else if (data is RepublicAct) {
        return data.issuance.title.toLowerCase().contains(searchInput);
      } else if (data is LegalOpinion) {
        return data.issuance.title.toLowerCase().contains(searchInput);
      } else if (data is JointCircular) {
        return data.issuance.title.toLowerCase().contains(searchInput);
      } else if (data is DraftIssuance) {
        return data.issuance.title.toLowerCase().contains(searchInput);
      } else if (data is LatestIssuance) {
        return data.issuance.title.toLowerCase().contains(searchInput);
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
}
class SearchResult {
  final String title;
  final String pdfUrl;
  
  SearchResult(
    this.title,
    this.pdfUrl
  );

}
class DetailsScreen extends StatelessWidget {
  final SearchResult searchResult;

  const DetailsScreen({required this.searchResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(searchResult.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display any details you want about the search result
            // Display PDF preview
            PdfPreview(url: searchResult.pdfUrl),
            SizedBox(height: 50),
            // Button to download PDF
            ElevatedButton(
              onPressed: () {
                downloadAndSavePdf(context, searchResult.pdfUrl, searchResult.title);
              },
              child: Text('Download PDF'),
            ),
          ],
        ),
      ),
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
                      child: Text(
                        result.title,
                        style: TextStyle(fontSize: 12),
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



  
Future<void> downloadAndSavePdf(
      BuildContext context, String url, String title) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Downloading PDF...'),
              ],
            ),
          ),
        );
      },
    );

    try {
      final appDir = await getExternalStorageDirectory();
      final directoryPath = '${appDir!.path}/PDFs';
      final filePath = '$directoryPath/$title.pdf';

      final file = File(filePath);
      if (await file.exists()) {
        Navigator.of(context).pop(); // Close the loading dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('File Already Downloaded'),
              content: Text(
                  'The PDF has already been downloaded and saved locally.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final directory = Directory(directoryPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        await file.writeAsBytes(response.bodyBytes);

        print('PDF downloaded and saved at: $filePath');

        Navigator.of(context).pop(); // Close the loading dialog

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Download Complete'),
              content: Text('The PDF has been downloaded and saved locally.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      Navigator.of(context).pop(); // Close the loading dialog
    }
  }
}

class PdfPreview extends StatelessWidget {
  final String url;

  const PdfPreview({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _loadPdfFromUrl(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Previewing PDF...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading PDF: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return Expanded(
            child: PDFView(
              filePath: snapshot.data!.path,
              pageSnap: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
              onError: (error) {
                print('Error loading PDF: $error');
              },
            ),
          );
        } else {
          return Center(child: Text('Unknown error occurred'));
        }
      },
    );
  }

  Future<File> _loadPdfFromUrl(String url) async {
    final filename = url.split('/').last;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    if (await file.exists()) {
      return file;
    } else {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
    }
  }
}

