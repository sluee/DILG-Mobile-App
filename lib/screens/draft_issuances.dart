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
      
    );
  }

  Widget _buildBody() {
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
                _filterDraftIssuances(value);
              },
            ),
          ),

          // Display the filtered draft issuances
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              for (int index = 0; index < _filteredDraftIssuances.length; index++)
                InkWell(
                  onTap: () {
                    _navigateToDetailsPage(context, _filteredDraftIssuances[index]);
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
                                  Text(
                                    _filteredDraftIssuances[index].issuance.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                      _filteredDraftIssuances[index].issuance.referenceNo != 'N/A'
                                    ? 'Ref #: ${_filteredDraftIssuances[index].issuance.referenceNo}'
                                    : '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _filteredDraftIssuances[index].responsible_office != 'N/A'
                                        ? 'Responsible Office: ${_filteredDraftIssuances[index].responsible_office}'
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
                              _filteredDraftIssuances[index].issuance.date != 'N/A' 
                                ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(_filteredDraftIssuances[index].issuance.date))
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
           content: 'Ref #: ${issuance.issuance.referenceNo != 'N/A' ? issuance.issuance.referenceNo + '\n' : ''}'
                '${issuance.issuance.date != 'N/A' ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date)) + '\n' : ''}',
          pdfUrl: issuance.issuance.urlLink,
          type: getTypeForDownload(issuance.issuance.type),
        ),
      ),
    );
  }
}