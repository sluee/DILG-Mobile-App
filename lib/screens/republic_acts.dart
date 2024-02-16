import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../screens/sidebar.dart';
import '../screens/details_screen.dart';
import 'package:http/http.dart' as http;
import 'file_utils.dart';

class RepublicActs extends StatefulWidget {
  @override
  _RepublicActsState createState() => _RepublicActsState();
}

class _RepublicActsState extends State<RepublicActs> {
  TextEditingController _searchController = TextEditingController();
  List<RepublicAct> _republicActs = [];
  List<RepublicAct> _filteredRepublicActs = [];

  @override
  void initState() {
    super.initState();
    fetchRepublicActs();
  }

  Future<void> fetchRepublicActs() async {
    final response = await http.get(
      Uri.parse('https://issuances.dilgbohol.com/api/republic_acts'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['republics'];

      setState(() {
        _republicActs = data.map((item) => RepublicAct.fromJson(item)).toList();
        _filteredRepublicActs = _republicActs;
      });
    } else {
      // Handle error
      print('Failed to load republic acts');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Republic Acts',
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
        currentIndex: 6,
        onItemSelected: (index) {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBody() {
    TextEditingController searchController = TextEditingController();

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
                _filterRepublicActs(value);
              },
            ),
          ), 
          SizedBox(height: 16.0),

          // Sample Table Section
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.0),
                for (int index = 0; index < _filteredRepublicActs.length; index++)
                  InkWell(
                    onTap: () {
                      _navigateToDetailsPage(context, _filteredRepublicActs[index]);
                    },
                    child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: const Color.fromARGB(255, 203, 201, 201), width: 1.0),
                      ),
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.article,
                                color: Colors.blue[900]), // Replace with your desired icon
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Text(
                                _filteredRepublicActs[index].issuance.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Text(
                              DateFormat('MMMM dd, yyyy').format(
                                DateTime.parse(_filteredRepublicActs[index].issuance.date),
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
          ),
        ],
      ),
    );
  }

  void _navigateToDetailsPage(BuildContext context, RepublicAct issuance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          title: issuance.issuance.title,
          content: 'Ref #: ${issuance.issuance.referenceNo}\n${DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date))}',
          pdfUrl: issuance.issuance.urlLink, 
          type: getTypeForDownload(issuance.issuance.type),
      
        ),
      ),
    );
  }

  void _filterRepublicActs(String query) {
    setState(() {
      // Filter the republic acts based on the search query
      _filteredRepublicActs = _republicActs.where((act) {
        final title = act.issuance.title.toLowerCase();
        final referenceNo = act.issuance.referenceNo.toLowerCase();
        return title.contains(query.toLowerCase()) || referenceNo.contains(query.toLowerCase());
      }).toList();
    });
  }
}


//for Latest getters and setters
class RepublicAct{
  final int id;
  final String responsible_office;
  
  final Issuance issuance;

  RepublicAct({
    required this.id,
    required this.responsible_office,

    required this.issuance,
  });

  factory RepublicAct.fromJson(Map<String, dynamic> json) {
    return RepublicAct(
      id: json['id'],
      responsible_office: json['responsible_office'],
      issuance: Issuance.fromJson(json['issuance']),
    );
  }
}

//for Issuance
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

String getTypeForDownload(String issuanceType) {
  // Map issuance types to corresponding download types
  switch (issuanceType) {
    case 'Latest Issuance':
      return 'Latest Issuance';
    case 'Joint Circulars':
      return 'Joint Circulars';
    case 'Memo Circulars':
      return 'Memo Circulars';
     case 'Presidential Directives':
      return 'Presidential Directives';  
     case 'Draft Issuances':
      return 'Draft Issuances';  
     case 'Republic Acts':
      return 'Republic Acts';  
     case 'Legal Opinions':
      return 'Legal Opinions';  
  
    default:
      return 'Other';
  }
}

