import 'dart:convert';
import 'package:DILGDOCS/Services/globals.dart';
import 'package:DILGDOCS/screens/file_utils.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Import other necessary files
import '../models/memo_circulars.dart';
import 'sidebar.dart';
import 'details_screen.dart';

class MemoCirculars extends StatefulWidget {
  @override
  State<MemoCirculars> createState() => _MemoCircularsState();
}

class _MemoCircularsState extends State<MemoCirculars> {
  TextEditingController _searchController = TextEditingController();
  List<MemoCircular> _memoCirculars = [];
  List<MemoCircular> _filteredMemoCirculars = [];
  bool _hasInternetConnection = true;

  @override
  void initState() {
    super.initState();
    // fetchMemoCirculars();
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
      // Load your memo circulars
      fetchMemoCirculars();
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
        _filteredMemoCirculars = _memoCirculars; // Initially set the filtered list to all items
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
          'Memo Circulars',
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
      body: _hasInternetConnection ? _buildBody() : Center(
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
      // drawer: Sidebar(
      //   currentIndex: 1,
      //   onItemSelected: (index) {
      //     _navigateToSelectedPage(context, index);
      //   },
      // ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
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
                _filterMemoCirculars(value);
              },
            ),
          ),
          // Display the filtered memo circulars
           Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            for (int index = 0; index < _filteredMemoCirculars.length; index++)
              InkWell(
                onTap: () {
                  _navigateToDetailsPage(context, _filteredMemoCirculars[index]);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: const Color.fromARGB(255, 203, 201, 201), width: 1.0),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                               Text.rich(
                                    highlightMatches(_filteredMemoCirculars[index].issuance.title, _searchController.text),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                SizedBox(height: 4.0),
                                 Text.rich(
                                  highlightMatches('Ref #: ${_filteredMemoCirculars[index].issuance.referenceNo}', _searchController.text),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text.rich(
                                  highlightMatches('Responsible Office: ${_filteredMemoCirculars[index].responsible_office}', _searchController.text),
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
                            _filteredMemoCirculars[index].issuance.date != 'N/A' 
                              ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(_filteredMemoCirculars[index].issuance.date))
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

  void _filterMemoCirculars(String query) {
    setState(() {
      // Filter the memo circulars based on the search query
      _filteredMemoCirculars = _memoCirculars.where((memo) {
        final title = memo.issuance.title.toLowerCase();
        final referenceNo = memo.issuance.referenceNo.toLowerCase();
        final responsibleOffice = memo.responsible_office.toLowerCase();
        final searchLower = query.toLowerCase();

        return title.contains(searchLower) ||
            referenceNo.contains(searchLower) ||
            responsibleOffice.contains(searchLower);
      }).toList();
    });
  }

  void _navigateToDetailsPage(BuildContext context, MemoCircular issuance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          title: issuance.issuance.title,
         content: 'Ref #: ${issuance.issuance.referenceNo != 'N/A' ? issuance.issuance.referenceNo + '\n' : ''}'
                '${issuance.issuance.date != 'N/A' ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date)) + '\n' : ''}'
                '${issuance.responsible_office != 'N/A' ? 'Category: ${issuance.responsible_office}\n' : ''}',
          pdfUrl: issuance.issuance.urlLink,
          type: getTypeForDownload(issuance.issuance.type),
        ),
      ),
    );
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

  void _navigateToSelectedPage(BuildContext context, int index) {
    // Handle navigation if needed
  }
}