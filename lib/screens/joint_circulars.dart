import 'dart:convert';
import 'package:DILGDOCS/screens/draft_issuances.dart';
import 'package:DILGDOCS/screens/file_utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../utils/routes.dart';
import 'sidebar.dart';
import 'details_screen.dart';
import 'package:http/http.dart' as http;

class JointCirculars extends StatefulWidget {  
  @override
  State<JointCirculars> createState() => _JointCircularsState();
}

class _JointCircularsState extends State<JointCirculars> {
   List<JointCircular> _jointCirculars = [];
   List<JointCircular> get jointCirculars => _jointCirculars;

 
@override
  void initState() {
    super.initState();
    fetchJointCirculars();
  }


 Future<void> fetchJointCirculars() async {
    final response = await http.get(
      Uri.parse('https://issuances.dilgbohol.com/api/joint_circulars'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['joints'];

      setState(() {
        _jointCirculars = data.map((item) => JointCircular.fromJson(item)).toList();
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
                Text(
                  'Joint Circulars',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  // Add margin to the left
                  textAlign: TextAlign.left,
                  // Use the EdgeInsets.only to specify margin for specific sides
                  // In this case, only the left margin is set to 3.0
                  // margin: EdgeInsets.only(left: 3.0),
                ),

                SizedBox(height: 16.0),
                for (int index = 0; index < _jointCirculars.length; index++)
              InkWell(
               onTap: () {
                  _navigateToDetailsPage(context, _jointCirculars[index]);
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
                                _jointCirculars[index].issuance.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Ref #${_jointCirculars[index].issuance.referenceNo}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Ref #${_jointCirculars[index].responsible_office}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(
                            DateTime.parse(_jointCirculars[index].issuance.date),
                          ),
                          style: TextStyle(
                            fontSize: 12,
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

 void _navigateToDetailsPage(BuildContext context, JointCircular issuance) {
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


  void _navigateToSelectedPage(BuildContext context, int index) {
    // Handle navigation if needed
  }
}
class JointCircular {
  final int id;
  final String responsible_office;
   final Issuance issuance;

  JointCircular({
    required this.id,
    required this.responsible_office,
   required this.issuance,
   
  });

  factory JointCircular.fromJson(Map<String, dynamic> json) {
    return JointCircular(
      id: json['id'],
      responsible_office: json['responsible_office'],
      // title: json['issuance']['title'],
     
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

