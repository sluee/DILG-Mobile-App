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

    List<PresidentialDirective> _presidentialDirectives = [];
    List<PresidentialDirective> get presidentialDirectives => _presidentialDirectives;
      

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
        print('Presidential Directives Data: $data');

        setState(() {
          _presidentialDirectives = data.map((item) => PresidentialDirective.fromJson(item)).toList();
        });
      } else {
        print('Presidential Directives Data is null');
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
    TextEditingController searchController = TextEditingController();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Filter Category Dropdown
         
          // Search Input
          Container(
            // margin: EdgeInsets.only(top: 4.0),
            padding: EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                // Handle search input changes
              },
            ),
          ), // Adjust the spacing as needed

          // Sample Table Section
          Container(
            // padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               

                SizedBox(height: 16.0),
                for (int index = 0; index < _presidentialDirectives.length; index++)
              InkWell(
               onTap: () {
                  _navigateToDetailsPage(context, _presidentialDirectives[index]);
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
                                _presidentialDirectives[index].issuance.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Ref #: ${_presidentialDirectives[index].issuance.referenceNo}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                               Text(
                            _presidentialDirectives[index].responsible_office != 'N/A' ? 
                              'Responsible Office: ${_presidentialDirectives[index].responsible_office}' : 
                              '',
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
                            DateTime.parse(_presidentialDirectives[index].issuance.date),
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


 void _navigateToDetailsPage(BuildContext context, PresidentialDirective issuance) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetailsScreen(
        title: issuance.issuance.title,
        content: 'Ref #${issuance.issuance.referenceNo}\n${DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date))} \n \n ${issuance.responsible_office}',
        pdfUrl: issuance.issuance.urlLink,
         type: getTypeForDownload(issuance.issuance.type),
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
    required this.type
  });

  factory Issuance.fromJson(Map<String, dynamic> json) {
    return Issuance(
      id: json['id'],
      date: json['date'],
      title: json['title'],
      referenceNo: json['reference_no'],
      keyword: json['keyword'],
      urlLink: json['url_link'],
      type: json['type']
    );
  }
}

