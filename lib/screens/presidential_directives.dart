import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../utils/routes.dart';
import 'sidebar.dart';
import 'details_screen.dart';
import 'package:http/http.dart' as http;
import "file_utils.dart";

class PresidentialDirectives extends StatefulWidget {
  @override
  State<PresidentialDirectives> createState() => _PresidentialDirectivesState();
}

class _PresidentialDirectivesState extends State<PresidentialDirectives> {
  TextEditingController _searchController = TextEditingController();
  List<PresidentialDirective> _presidentialDirectives = [];
  List<PresidentialDirective> _filteredPresidentialDirectives = [];

  @override
  void initState() {
    super.initState();
    fetchPresidentialCirculars();
  }

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
        setState(() {
          _presidentialDirectives =
              data.map((item) => PresidentialDirective.fromJson(item)).toList();
          _filteredPresidentialDirectives = _presidentialDirectives;
        });
      }
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
          'Presidential Directives',
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
          _navigateToSelectedPage(context, index);
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
                _filterPresidentialDirectives(value);
              },
            ),
          ),

          // Display the filtered presidential directives
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              for (int index = 0; index < _filteredPresidentialDirectives.length; index++)
                InkWell(
                  onTap: () {
                    _navigateToDetailsPage(context, _filteredPresidentialDirectives[index]);
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
                                    _filteredPresidentialDirectives[index].issuance.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Ref #: ${_filteredPresidentialDirectives[index].issuance.referenceNo}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _filteredPresidentialDirectives[index].responsible_office != 'N/A'
                                        ? 'Responsible Office: ${_filteredPresidentialDirectives[index].responsible_office}'
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
                                DateTime.parse(_filteredPresidentialDirectives[index].issuance.date),
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

  void _filterPresidentialDirectives(String query) {
    setState(() {
      // Filter the presidential directives based on the search query
      _filteredPresidentialDirectives = _presidentialDirectives.where((directive) {
        final title = directive.issuance.title.toLowerCase();
        final referenceNo = directive.issuance.referenceNo.toLowerCase();
        final responsibleOffice = directive.responsible_office.toLowerCase();
        return title.contains(query.toLowerCase()) ||
            referenceNo.contains(query.toLowerCase()) ||
            responsibleOffice.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _navigateToDetailsPage(BuildContext context, PresidentialDirective directive) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          title: directive.issuance.title,
          content:
              'Ref #: ${directive.issuance.referenceNo}\n${DateFormat('MMMM dd, yyyy').format(DateTime.parse(directive.issuance.date))} \n \n ${directive.responsible_office}',
          pdfUrl: directive.issuance.urlLink,
          type: getTypeForDownload(directive.issuance.type),
        ),
      ),
    );
  }

  void _navigateToSelectedPage(BuildContext context, int index) {
    // Handle navigation if needed
  }
}

class PresidentialDirective {
  final int id;
  final String responsible_office;
  final Issuance issuance;

  PresidentialDirective({
    required this.id,
    required this.responsible_office,
    required this.issuance,
  });

  factory PresidentialDirective.fromJson(Map<String, dynamic> json) {
    return PresidentialDirective(
      id: json['id'],
      responsible_office: json['responsible_office'] ?? 'N/A',
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
