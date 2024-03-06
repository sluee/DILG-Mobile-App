import 'dart:convert';
import 'package:DILGDOCS/Services/globals.dart';
import 'package:DILGDOCS/models/legal_opinions.dart';
import 'package:DILGDOCS/screens/file_utils.dart';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'details_screen.dart';
import 'package:http/http.dart' as http;

class LegalOpinions extends StatefulWidget {
  @override
  _LegalOpinionsState createState() => _LegalOpinionsState();
}

class _LegalOpinionsState extends State<LegalOpinions> {
  TextEditingController _searchController = TextEditingController();
  List<LegalOpinion> _legalOpinions = [];
  List<LegalOpinion> _filteredLegalOpinions = []; 
  bool _hasInternetConnection = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // fetchLegalOpinions();
     _loadContentIfConnected();
      _checkInternetConnection();
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
      // Load your content here
      fetchLegalOpinions();
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

Future<void> _openWifiSettings() async {
  const url = 'app-settings:';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    // Provide a generic message for both Android and iOS users
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

  Future<void> fetchLegalOpinions() async {
    final response = await http.get(
      Uri.parse('$baseURL/legal_opinions'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['legals'];

      setState(() {
        _legalOpinions = data.map((item) => LegalOpinion.fromJson(item)).toList();
        _filteredLegalOpinions = _legalOpinions;
        _isLoading = false; 
      });
    } else {
      print('Failed to load latest legal opinions');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Legal Opinions',
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
            SizedBox(height: 16.0), // Adjust the spacing as needed
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              style: TextStyle(fontSize: 16.0),
              onChanged: (value) {
                // Call the function to filter the list based on the search query
                _filterLegalOpinions(value);
              },
            ),
          ),

          // Display the filtered legal opinions or "No legal opinions found" message
          _filteredLegalOpinions.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No legal opinions found',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  for (int index = 0;
                      index < _filteredLegalOpinions.length;
                      index++)
                    InkWell(
                      onTap: () {
                        _navigateToDetailsPage(
                            context, _filteredLegalOpinions[index]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: const Color.fromARGB(
                                    255, 203, 201, 201),
                                width: 1.0),
                          ),
                        ),
                        child: Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.article,
                                    color: Colors.blue[900]),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text.rich(
                                        highlightMatches(
                                            _filteredLegalOpinions[index]
                                                .issuance
                                                .title,
                                            _searchController.text),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 4.0),
                                      Text.rich(
                                        _filteredLegalOpinions[index]
                                                    .issuance
                                                    .referenceNo !=
                                                'N/A'
                                            ? highlightMatches(
                                                'Ref #: ${_filteredLegalOpinions[index].issuance.referenceNo}',
                                                _searchController.text)
                                            : TextSpan(text: 'Ref #: N/A'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        _filteredLegalOpinions[index]
                                                    .category !=
                                                'N/A'
                                            ? 'Category: ${_filteredLegalOpinions[index].category}'
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
                                  _filteredLegalOpinions[index]
                                              .issuance
                                              .date !=
                                          'N/A'
                                      ? DateFormat('MMMM dd, yyyy').format(
                                          DateTime.parse(
                                              _filteredLegalOpinions[index]
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

  void _navigateToDetailsPage(BuildContext context, LegalOpinion issuance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          title: issuance.issuance.title,
          content: 'Ref #: ${issuance.issuance.referenceNo != 'N/A' ? issuance.issuance.referenceNo + '\n' : ''}'
                '${issuance.issuance.date != 'N/A' ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date)) + '\n' : ''}',
          pdfUrl: issuance.issuance.urlLink,
          type: getTypeForDownload(issuance.issuance.type),
        ),
      ),
    );
  }

  void _filterLegalOpinions(String query) {
    setState(() {
      // Filter the legal opinions based on the search query
      _filteredLegalOpinions = _legalOpinions.where((opinion) {
        final title = opinion.issuance.title.toLowerCase();
        final referenceNo = opinion.issuance.referenceNo.toLowerCase();
        return title.contains(query.toLowerCase()) || referenceNo.contains(query.toLowerCase());
      }).toList();
    });
  }
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
void _navigateToSelectedPage(BuildContext context, int index) {}