import 'dart:convert';
import 'package:DILGDOCS/models/latest_issuances.dart';
import 'package:DILGDOCS/screens/file_utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../Services/globals.dart';
import '../models/latest_issuances.dart';
import '../utils/routes.dart';
import 'sidebar.dart';
import 'details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:anim_search_bar/anim_search_bar.dart';
class LatestIssuances extends StatefulWidget {
  @override
  _LatestIssuancesState createState() => _LatestIssuancesState();
}

class _LatestIssuancesState extends State<LatestIssuances> {
  List<LatestIssuance> _latestIssuances = [];
  List<LatestIssuance> get latestIssuances => _latestIssuances;
  TextEditingController _searchController = TextEditingController();
   List<String> categories = [
    'All Outcome Area',
    'ACCOUNTABLE, TRANSPARENT, PARTICIPATIVE',
    'AND EFFECTIVE LOCAL GOVERNANCE',
    'PEACEFUL, ORDERLY AND SAFE LGUS STRATEGIC PRIORITIES',
    'SOCIALLY PROTECTIVE LGUS',
    'ENVIRONMENT-PROTECTIVE, CLIMATE CHANGE ADAPTIVE AND DISASTER RESILIENT LGUS',
    'BUSINESS-FRIENDLY AND COMPETITIVE LGUS',
    'STRENGTHENING OF INTERNAL GOVERNANCE'
  ];

  String selectedCategory = 'All Outcome Area';// Default selection


@override
  void initState() {
    super.initState();
    fetchLatestIssuances();
  }


 Future<void> fetchLatestIssuances() async {
    final response = await http.get(
      Uri.parse('$baseURL/latest_issuances'),
      headers: {
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['latests'];

      setState(() {
        _latestIssuances = data.map((item) => LatestIssuance.fromJson(item)).toList();
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
          'Latest Issuances',
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
         Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 5.0, right: 5.0),
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      
                      SizedBox(height: 8.0),
                      Container(
                        margin: EdgeInsets.only(top: 0.1, bottom: 0.1),
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            }
                          },
                          items: categories
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_downward, color: Colors.blue[900]), 
                                    SizedBox(width: 6.0),
                                    Expanded(
                                      child: Text(
                                        value,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: AnimSearchBar(
                  width: 400,
                  onSubmitted: (query) {
                    print('Search submitted: $query');
                  },
                  onSuffixTap: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                  color: Colors.blue[400]!,
                  helpText: "Search...",
                  autoFocus: true,
                  closeSearchOnSuffixTap: true,
                  animationDurationInMilli: 1000,
                  rtl: true,
                  textController: _searchController,
                ),
              ),
            ],
          ),
          Container(
            // padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 14.0),
                for (int index = 0; index < _latestIssuances.length; index++)
                InkWell(
                  onTap: () {
                    _navigateToDetailsPage(context, _latestIssuances[index]);
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
                                _latestIssuances[index].issuance.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                _latestIssuances[index].issuance.referenceNo !='N/A' ? 'Ref #: ${_latestIssuances[index].issuance.referenceNo}' : '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                               Text(
                                'Outcome Area: ${_latestIssuances[index].outcome}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                   overflow: TextOverflow.ellipsis,
                                ),
                              ),
                               Text(
                                _latestIssuances[index].category !='N/A' ? 'Category: ${_latestIssuances[index].category}' : '',
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
                          _latestIssuances[index].issuance.date != 'N/A' 
                            ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(_latestIssuances[index].issuance.date))
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
          ),  
        ],
      ),
    );
  }

 void _navigateToDetailsPage(BuildContext context, LatestIssuance issuance) {
  print('PDF URL: ${issuance.issuance.urlLink}');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetailsScreen(
        title: issuance.issuance.title,
        content: 'Ref #: ${issuance.issuance.referenceNo != 'N/A' ? issuance.issuance.referenceNo + '\n' : ''}'
                '${issuance.issuance.date != 'N/A' ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date)) + '\n' : ''}'
                '${issuance.category != 'N/A' ? 'Category: ${issuance.category}\n' : ''}',
        pdfUrl: issuance.issuance.urlLink,
        type: getTypeForDownload(issuance.issuance.type),
      ),
    )
  );
}
Widget buildContent(LatestIssuance issuance) {
  List<InlineSpan> spans = [];

  if (issuance.issuance.referenceNo != 'N/A') {
    spans.add(TextSpan(text: 'Ref #${issuance.issuance.referenceNo}\n'));
  }

  if (issuance.issuance.date != 'N/A') {
    spans.add(TextSpan(text: '${DateFormat('MMMM dd, yyyy').format(DateTime.parse(issuance.issuance.date))}\n'));
  }

  if (issuance.category != 'N/A') {
    spans.add(TextSpan(text: 'Category: ${issuance.category}\n'));
  }

  return RichText(
    text: TextSpan(children: spans),
    textAlign: TextAlign.start,
  );
}


  void _navigateToSelectedPage(BuildContext context, int index) {
    // Handle navigation if needed
  }
}

 String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength) + '...';
    }
  }

