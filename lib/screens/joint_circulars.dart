import 'dart:convert';
import 'package:DILGDOCS/Services/globals.dart';
import 'package:DILGDOCS/screens/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// Import other necessary files
import '../models/joint_circulars.dart';
// import 'sidebar.dart';
import 'details_screen.dart';
// import 'bottom_navigation.dart';/

class JointCirculars extends StatefulWidget {
  @override
  State<JointCirculars> createState() => _JointCircularsState();
}

class _JointCircularsState extends State<JointCirculars> {
  TextEditingController _searchController = TextEditingController();
  List<JointCircular> _jointCirculars = [];
  List<JointCircular> _filteredJointCirculars = [];

  @override
  void initState() {
    super.initState();
    fetchJointCirculars();
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
        _filteredJointCirculars = _jointCirculars;
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
          'Joint Circulars',
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
    //   bottomNavigationBar: BottomNavigation(
    //   currentIndex: 0,
    //   onTabTapped:(index){
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
              _filterJointCirculars(value);
            },
          ),
        ), 

        // Display the filtered joint circulars or "No joint circulars found" message
        _filteredJointCirculars.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No joint circulars found',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  for (int index = 0; index < _filteredJointCirculars.length; index++)
                    InkWell(
                      onTap: () {
                        _navigateToDetailsPage(context, _filteredJointCirculars[index]);
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
                                          highlightMatches(_filteredJointCirculars[index].issuance.title, _searchController.text),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      SizedBox(height: 4.0),
                                       Text.rich(
                                        highlightMatches('Ref #: ${_filteredJointCirculars[index].issuance.referenceNo}', _searchController.text),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text.rich(
                                        highlightMatches('Responsible Office: ${_filteredJointCirculars[index].responsible_office}', _searchController.text),
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
                                  _filteredJointCirculars[index].issuance.date != 'N/A' 
                                    ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(_filteredJointCirculars[index].issuance.date))
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



  void _filterJointCirculars(String query) {
    setState(() {
      // Filter the joint circulars based on the search query
      _filteredJointCirculars = _jointCirculars.where((joint) {
        final title = joint.issuance.title.toLowerCase();
        final referenceNo = joint.issuance.referenceNo.toLowerCase();
        final responsibleOffice = joint.responsible_office.toLowerCase();
        final searchLower = query.toLowerCase();

        return title.contains(searchLower) ||
            referenceNo.contains(searchLower) ||
            responsibleOffice.contains(searchLower);
      }).toList();
    });
  }

  void _navigateToDetailsPage(BuildContext context, JointCircular issuance) {
    Navigator.push(
      context,
     MaterialPageRoute(
        builder: (context) => DetailsScreen(
          title: issuance.issuance.title,
           content: 'Ref #: ${issuance.issuance.referenceNo != 'N/A' ? issuance.issuance.referenceNo + '\n' : ''}'
                '${issuance.issuance.date != 'N/A' ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date)) + '\n' : ''}',
          pdfUrl: issuance.issuance.urlLink, // Provide a default value if urlLink is null
          type: getTypeForDownload(issuance.issuance.type),
        ),
      ),


    );
  }

  void _navigateToSelectedPage(BuildContext context, int index) {
    // Handle navigation if needed
  }
}

