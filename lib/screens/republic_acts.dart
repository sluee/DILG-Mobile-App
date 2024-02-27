import 'dart:convert';
import 'package:DILGDOCS/Services/globals.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/republic_acts.dart';
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
      Uri.parse('$baseURL/republic_acts'),
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

          // Display the filtered presidential directives
          Column(
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
                                    _filteredRepublicActs[index].issuance.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  
                                  Text(
                                    _filteredRepublicActs[index].responsibleOffice != 'N/A'
                                        ? 'Responsible Office: ${_filteredRepublicActs[index].responsibleOffice}'
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
                              _filteredRepublicActs[index].issuance.date != 'N/A' 
                                ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(_filteredRepublicActs[index].issuance.date))
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
  void _navigateToDetailsPage(BuildContext context, RepublicAct issuance) {
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


