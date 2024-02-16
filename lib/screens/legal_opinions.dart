import 'dart:convert';
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
      Uri.parse('https://issuances.dilgbohol.com/api/legal_opinions'),
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
          SizedBox(height: 16.0),

          // List of Legal Opinions
         Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
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
                          bottom: BorderSide(
                            color: const Color.fromARGB(255, 203, 201, 201),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.article, color: Colors.blue[900]),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _filteredLegalOpinions[index].issuance.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          DateFormat('MMMM dd, yyyy').format(
                                            DateTime.parse(_filteredLegalOpinions[index].issuance.date),
                                          ),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Ref #: ${_filteredLegalOpinions[index].issuance.referenceNo}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
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
          content: 'Ref #${issuance.issuance.referenceNo}\n${DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date))}',
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


class LegalOpinion {
  final int id;
  final String category;
  final Issuance issuance;

  LegalOpinion({
    required this.id,
    required this.category,
    required this.issuance,
  });

  factory LegalOpinion.fromJson(Map<String, dynamic> json) {
    return LegalOpinion(
      id: json['id'],
      category: json['category'],
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
      type: json['type'],
    );
  }
}
