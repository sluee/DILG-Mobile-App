import 'dart:convert';
import 'package:DILGDOCS/screens/file_utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'sidebar.dart';
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

  @override
  void initState() {
    super.initState();
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: _buildBody(),
      drawer: Sidebar(
        currentIndex: 1,
        onItemSelected: (index) {
          // _navigateToSelectedPage(context, index);
        },
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
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Ref #${_filteredDraftIssuances[index].issuance.referenceNo}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _filteredDraftIssuances[index].responsible_office != 'N/A'
                                        ? 'Responsible Office: ${_filteredDraftIssuances[index].responsible_office}'
                                        : '',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Text(
                              DateFormat('MMMM dd, yyyy').format(
                                DateTime.parse(_filteredDraftIssuances[index].issuance.date),
                              ),
                              style: TextStyle(
                                fontSize: 10,
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
          content: 'Ref #${issuance.issuance.referenceNo}\n${DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date))}',
          pdfUrl: issuance.issuance.urlLink,
          type: getTypeForDownload(issuance.issuance.type),
        ),
      ),
    );
  }
}

class DraftIssuance {
  final int id;
  final String responsible_office;
  final Issuance issuance;

  DraftIssuance({
    required this.id,
    required this.responsible_office,
    required this.issuance,
  });

  factory DraftIssuance.fromJson(Map<String, dynamic> json) {
    return DraftIssuance(
      id: json['id'],
      responsible_office: json['responsible_office'],
      issuance: Issuance.fromJson(json['issuance']),
    );
  }
}

class Issuance {
  final int id;
  final String date;
  final String title;
  final String referenceNo;
  final String keyword;
  final String urlLink;
  final String type;

  Issuance({
    required this.id,
    required this.date,
    required this.title,
    required this.referenceNo,
    required this.keyword,
    required this.urlLink,
    required this.type,
  });

  factory Issuance.fromJson(Map<String, dynamic> json) {
    return Issuance(
        id: json['id'],
        date: json['date'],
        title: json['title'],
        referenceNo: json['reference_no'],
        keyword: json['keyword'],
        urlLink: json['url_link'],
        type: json['type']);
  }
}
