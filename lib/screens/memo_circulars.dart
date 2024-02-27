import 'dart:convert';
import 'package:DILGDOCS/Services/globals.dart';
import 'package:DILGDOCS/screens/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Import other necessary files
import '../models/memo_circulars.dart';
import 'sidebar.dart';
import 'details_screen.dart';

class MemoCirculars extends StatefulWidget {
  @override
  State<MemoCirculars> createState() => _MemoCircularsState();
}

class _MemoCircularsState extends State<MemoCirculars> {
  TextEditingController _searchController = TextEditingController();
  List<MemoCircular> _memoCirculars = [];
  List<MemoCircular> _filteredMemoCirculars = [];

  @override
  void initState() {
    super.initState();
    fetchMemoCirculars();
  }

  Future<void> fetchMemoCirculars() async {
    final response = await http.get(
      Uri.parse('$baseURL/memo_circulars'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['memos'];

      setState(() {
        _memoCirculars = data.map((item) => MemoCircular.fromJson(item)).toList();
        _filteredMemoCirculars = _memoCirculars; // Initially set the filtered list to all items
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
          'Memo Circulars',
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
                _filterMemoCirculars(value);
              },
            ),
          ),
          // Display the filtered memo circulars
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              for (int index = 0; index < _filteredMemoCirculars.length; index++)
                InkWell(
                  onTap: () {
                    _navigateToDetailsPage(context, _filteredMemoCirculars[index]);
                  },
                  child: Card(
                    elevation: 0,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.article, color: Colors.blue[900]),
                          title: Text(
                            _filteredMemoCirculars[index].issuance.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _filteredMemoCirculars[index].issuance.referenceNo != 'N/A'
                                    ? 'Ref #: ${_filteredMemoCirculars[index].issuance.referenceNo}'
                                    : '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _filteredMemoCirculars[index].responsible_office != 'N/A'
                                    ? 'Responsible Office: ${_filteredMemoCirculars[index].responsible_office}'
                                    : '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          trailing:  Text(
                          _filteredMemoCirculars[index].issuance.date != 'N/A' 
                            ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(_filteredMemoCirculars[index].issuance.date))
                            : '',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        ),
                        Divider(
                          color: Colors.grey[400],
                          height: 0,
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _filterMemoCirculars(String query) {
    setState(() {
      // Filter the memo circulars based on the search query
      _filteredMemoCirculars = _memoCirculars.where((memo) {
        final title = memo.issuance.title.toLowerCase();
        final referenceNo = memo.issuance.referenceNo.toLowerCase();
        final responsibleOffice = memo.responsible_office.toLowerCase();
        final searchLower = query.toLowerCase();

        return title.contains(searchLower) ||
            referenceNo.contains(searchLower) ||
            responsibleOffice.contains(searchLower);
      }).toList();
    });
  }

  void _navigateToDetailsPage(BuildContext context, MemoCircular issuance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          title: issuance.issuance.title,
          content:
              'Ref #${issuance.issuance.referenceNo}\n${DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date))} \br \br ${issuance.responsible_office}',
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




