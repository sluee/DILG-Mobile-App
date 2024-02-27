import 'dart:convert';
import 'package:DILGDOCS/Services/globals.dart';
import 'package:DILGDOCS/models/legal_opinions.dart';
import 'package:DILGDOCS/screens/draft_issuances.dart';
import 'package:DILGDOCS/screens/file_utils.dart';
import 'package:DILGDOCS/screens/joint_circulars.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'sidebar.dart';
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

  @override
  void initState() {
    super.initState();
    fetchLegalOpinions();
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
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.blue[900]),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: _buildBody(),
      drawer: Sidebar(
        currentIndex: 7,
        onItemSelected: (index) {
          Navigator.pop(context);
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
                _filterLegalOpinions(value);
              },
            ),
          ),

          // Display the filtered presidential directives
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              for (int index = 0; index < _filteredLegalOpinions.length; index++)
                InkWell(
                  onTap: () {
                    _navigateToDetailsPage(context, _filteredLegalOpinions[index]);
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
                                    _filteredLegalOpinions[index].issuance.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  
                                  Text(
                                    _filteredLegalOpinions[index].issuance.referenceNo != 'N/A'
                                        ? 'Ref #: ${_filteredLegalOpinions[index].issuance.referenceNo}'
                                        : '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    _filteredLegalOpinions[index].category != 'N/A'
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
                              _filteredLegalOpinions[index].issuance.date != 'N/A' 
                                ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(_filteredLegalOpinions[index].issuance.date))
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


  void _navigateToSelectedPage(BuildContext context, int index) {}


