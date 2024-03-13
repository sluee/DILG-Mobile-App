import 'dart:convert';
import 'package:DILGDOCS/models/latest_issuances.dart';
import 'package:DILGDOCS/screens/file_utils.dart';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Services/globals.dart';
import 'details_screen.dart';
import 'package:http/http.dart' as http;
class LatestIssuances extends StatefulWidget {
  @override
  _LatestIssuancesState createState() => _LatestIssuancesState();
   
}

class _LatestIssuancesState extends State<LatestIssuances> {
  List<LatestIssuance> _latestIssuances = [];
  List<LatestIssuance> _filteredLatestIssuances = []; // Initialize filtered list
  TextEditingController _searchController = TextEditingController();
  bool _hasInternetConnection = true;
  bool _isLoading = true;
 


  @override
  void initState() {
    super.initState();
    // fetchLatestIssuances();
     _checkInternetConnection();
     _loadContentIfConnected();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          _hasInternetConnection = false;
        });
      } else {
        _loadContentIfConnected();
      }
    });
  }

   Future<void> _loadContentIfConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      setState(() {
        _hasInternetConnection = true;
      });
      fetchLatestIssuances();
    }
  }


Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _hasInternetConnection = false;
      });
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
    final Map<String, dynamic>? responseData = json.decode(response.body);

    if (responseData != null && responseData.containsKey('latests')) {
      final List<dynamic> data = responseData['latests'];

      setState(() {
        _latestIssuances = data.map((item) => LatestIssuance.fromJson(item)).toList();
        _filteredLatestIssuances = _latestIssuances;
         _isLoading = false;
      });
    } else {
      print('Failed to load latest opinions: Data format error');
      print('Response body: ${response.body}'); // Print response body for debugging
    }
  } else {
    print('Failed to load latest opinions');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

Future<void> _openWifiSettings() async {
  const url = 'app-settings:';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unable to open Wi-Fi settings'),
          content: Text('Please open your Wi-Fi settings manually via the device settings.'),
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
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Latest Issuances',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
         iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[900],
      ),
        body: _hasInternetConnection 
    ? (_isLoading 
        ? _buildLoadingWidget() 
        : _buildBody())
    : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No internet connection',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                _openWifiSettings();
              },
              child: Text('Connect to Internet'),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(), // Circular progress indicator
          SizedBox(height: 16),
          Text(
            'Loading Files',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

 Widget _buildBody() {
     if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      );
    
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          // Search Input
          Container(
            margin: EdgeInsets.only(top: 16.0),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              style: TextStyle(fontSize: 16.0),
              onChanged: (value) {
                // Call the function to filter the list based on the search query
                _filterLatestIssuances(value); 
              },
            ),
          ),
          // Display the filtered latest issuances or "No latest issuances found" message
          _filteredLatestIssuances.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No latest issuances found',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  for (int index = 0;
                      index < _filteredLatestIssuances.length;
                      index++)
                    InkWell(
                      onTap: () {
                        _navigateToDetailsPage(
                            context, _filteredLatestIssuances[index]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color:
                                    const Color.fromARGB(255, 203, 201, 201),
                                width: 1.0),
                          ),
                        ),
                        child: Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.article, color: Colors.blue[900]),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text.rich(
                                        highlightMatches(
                                          _filteredLatestIssuances[index]
                                              .issuance
                                              .title,
                                          _searchController.text,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 4.0),
                                      Text.rich(
                                        _filteredLatestIssuances[index]
                                                    .issuance
                                                    .referenceNo !=
                                                'N/A'
                                            ? highlightMatches(
                                                'Ref #: ${_filteredLatestIssuances[index].issuance.referenceNo}',
                                                _searchController.text)
                                            : TextSpan(text: ''),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      // Text.rich(
                                      //   _filteredLatestIssuances[index]
                                      //               .outcome !=
                                      //           'N/A'
                                      //       ? highlightMatches(
                                      //           'Outcome Area: ${_filteredLatestIssuances[index].outcome}',
                                      //           _searchController.text)
                                      //       : TextSpan(text: ''),
                                      //     style: TextStyle(
                                      //     fontSize: 12,
                                      //     color: Colors.grey,
                                      //     overflow: TextOverflow.ellipsis,
                                      //   ),
                                      // ),
                                      
                                      Text(
                                        _filteredLatestIssuances[index]
                                            .category !=
                                                'N/A'
                                            ? 'Category: ${_filteredLatestIssuances[index].category}'
                                            : '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Text(
                                  _filteredLatestIssuances[index]
                                              .issuance
                                              .date !=
                                          'N/A'
                                      ? DateFormat('MMMM dd, yyyy').format(
                                          DateTime.parse(
                                              _filteredLatestIssuances[index]
                                                  .issuance
                                                  .date))
                                      : '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
        ],
      ),
    );
  }

  void _navigateToDetailsPage(BuildContext context, LatestIssuance issuance) {
  print('PDF URL: ${issuance.issuance.urlLink}');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetailsScreen(
        title: issuance.issuance.title,
        content: 'Ref #: ${issuance.issuance.referenceNo != 'N/A' ? issuance.issuance.referenceNo + '\n' : ''}'
                '${issuance.issuance.date != 'N/A' ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date)) + '\n' : ''}'
                '${issuance.category != 'N/A' ? 'Category: ${issuance.category}\n' : ''}',
        pdfUrl: issuance.issuance.urlLink,
        type: getTypeForDownload(issuance.issuance.type),
      ),
    )
  );
}
Widget buildContent(LatestIssuance issuance) {
  List<InlineSpan> spans = [];

  if (issuance.issuance.referenceNo != 'N/A') {
    spans.add(TextSpan(text: 'Ref #${issuance.issuance.referenceNo}\n'));
  }

  if (issuance.issuance.date != 'N/A') {
    spans.add(TextSpan(text: '${DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date))}\n'));
  }

  if (issuance.category != 'N/A') {
    spans.add(TextSpan(text: 'Category: ${issuance.category}\n'));
  }

  return RichText(
    text: TextSpan(children: spans),
    textAlign: TextAlign.start,
  );
}


 void _filterLatestIssuances(String query) {
  setState(() {
    // Filter the latest issuances based on the search query
    _filteredLatestIssuances = _latestIssuances.where((issuance) {
      final title = issuance.issuance.title.toLowerCase();
      final referenceNo = issuance.issuance.referenceNo.toLowerCase();
      return title.contains(query.toLowerCase()) || referenceNo.contains(query.toLowerCase());
    }).toList();
  });
}


TextSpan highlightMatches(String text, String query) {
  if (query.isEmpty) {
    return TextSpan(text: text);
  }

  List<TextSpan> textSpans = [];

  // Create a regular expression pattern with case-insensitive matching
  RegExp regex = RegExp(query, caseSensitive: false);

  // Find all matches of the query in the text
  Iterable<Match> matches = regex.allMatches(text);

  // Start index for slicing the text
  int startIndex = 0;

  // Add text segments with and without highlighting
  for (Match match in matches) {
    // Add text segment before the match
    textSpans.add(TextSpan(text: text.substring(startIndex, match.start)));

    // Add the matching segment with highlighting
    textSpans.add(TextSpan(
      text: text.substring(match.start, match.end),
      style: TextStyle(
        color: Colors.blue, 
        fontWeight: FontWeight.bold, 
      ),
    ));

    // Update the start index for the next segment
    startIndex = match.end;
  }

  // Add the remaining text segment
  textSpans.add(TextSpan(text: text.substring(startIndex)));

  return TextSpan(children: textSpans);
}

 String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength) + '...';
    }
 }
void _navigateToSelectedPage(BuildContext context, int index) {}
}