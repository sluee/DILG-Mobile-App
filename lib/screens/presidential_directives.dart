import 'dart:convert';
import 'package:DILGDOCS/Services/globals.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/presidential_directives.dart';
import '../utils/routes.dart';
import 'sidebar.dart';
import 'details_screen.dart';
import 'package:http/http.dart' as http;
import "file_utils.dart";
// import 'bottom_navigation.dart';

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
      Uri.parse('$baseURL/presidential_directives'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body)['presidentials'];

      if (data != null) {
        setState(() {
          _presidentialDirectives = data.map((item) => PresidentialDirective.fromJson(item)).toList();
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
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: _buildBody(),
      // drawer: Sidebar(
      //   currentIndex: 4,
      //   onItemSelected: (index) {
      //     _navigateToSelectedPage(context, index);
      //   },
      // ),
    //   bottomNavigationBar: BottomNavigation(
    //    currentIndex: 0,
    //    onTabTapped:(index){

    //   },
    // ),
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
                                 Text.rich(
                                    highlightMatches(_filteredPresidentialDirectives[index].issuance.title, _searchController.text),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                 Text.rich(
                                  highlightMatches('Ref #: ${_filteredPresidentialDirectives[index].issuance.referenceNo}', _searchController.text),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text.rich(
                                  highlightMatches('Responsible Office: ${_filteredPresidentialDirectives[index].responsible_office}', _searchController.text),
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
                              _filteredPresidentialDirectives[index].issuance.date != 'N/A' 
                                ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(_filteredPresidentialDirectives[index].issuance.date))
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
           content: 'Ref #: ${directive.issuance.referenceNo != 'N/A' ? directive.issuance.referenceNo + '\n' : ''}'
                '${directive.issuance.date != 'N/A' ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(directive.issuance.date)) + '\n' : ''}'
                '${directive.responsible_office != 'N/A' ? 'Category: ${directive.responsible_office}\n' : ''}',
          pdfUrl: directive.issuance.urlLink,
          type: getTypeForDownload(directive.issuance.type),
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


