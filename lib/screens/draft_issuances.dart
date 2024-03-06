import 'dart:convert';
import 'package:DILGDOCS/Services/globals.dart';
import 'package:DILGDOCS/models/draft_issuances.dart';
import 'package:DILGDOCS/screens/file_utils.dart';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'details_screen.dart';
import 'package:http/http.dart' as http;

class DraftIssuances extends StatefulWidget {
  @override
  State<DraftIssuances> createState() => _DraftIssuancesState();
}

class _DraftIssuancesState extends State<DraftIssuances> {
  TextEditingController _searchController = TextEditingController();
  List<DraftIssuance> _draftIssuances = [];
  List<DraftIssuance> _filteredDraftIssuances = [];
  bool _hasInternetConnection = true;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    // fetchDraftIssuances();
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
      // Load your content here
      fetchDraftIssuances();
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
        _filteredDraftIssuances = _draftIssuances;
         _isLoading = false; 
      });
    } else {
      // Handle error
      print('Failed to load Draft issuances');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Draft Issuances',
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
              _filterDraftIssuances(value); // Corrected method call
            },
          ),
        ),

          // Display the filtered draft issuances or "No draft issuances found" message
          _filteredDraftIssuances.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No draft issuances found',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.0),
                    for (int index = 0;
                        index < _filteredDraftIssuances.length;
                        index++)
                      InkWell(
                        onTap: () {
                          _navigateToDetailsPage(
                              context, _filteredDraftIssuances[index]);
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
                                              _filteredDraftIssuances[index]
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
                                          highlightMatches(
                                              'Ref #: ${_filteredDraftIssuances[index].issuance.referenceNo}',
                                              _searchController.text),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text.rich(
                                          highlightMatches(
                                              'Responsible Office: ${_filteredDraftIssuances[index].responsible_office}',
                                              _searchController.text),
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
                                    _filteredDraftIssuances[index]
                                                .issuance
                                                .date !=
                                            'N/A'
                                        ? DateFormat('MMMM dd, yyyy').format(
                                            DateTime.parse(
                                                _filteredDraftIssuances[index]
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

  void _filterDraftIssuances(String query) {
    setState(() {
      // Filter the draft issuances based on the search query
      _filteredDraftIssuances = _draftIssuances.where((issuance) {
        final title = issuance.issuance.title.toLowerCase();
        final referenceNo = issuance.issuance.referenceNo.toLowerCase();
        final responsibleOffice = issuance.responsible_office.toLowerCase();
        return title.contains(query.toLowerCase()) ||
            referenceNo.contains(query.toLowerCase()) ||
            responsibleOffice.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _navigateToDetailsPage(BuildContext context, DraftIssuance issuance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          title: issuance.issuance.title,
          content:
              'Ref #: ${issuance.issuance.referenceNo != 'N/A' ? issuance.issuance.referenceNo + '\n' : ''}'
              '${issuance.issuance.date != 'N/A' ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date)) + '\n' : ''}',
          pdfUrl: issuance.issuance.urlLink,
          type: getTypeForDownload(issuance.issuance.type),
        ),
      ),
    );
  }

  void _navigateToSelectedPage(BuildContext context, int index) {}
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