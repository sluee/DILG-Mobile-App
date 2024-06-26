import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:DILGDOCS/Services/auth_services.dart';
import 'package:DILGDOCS/Services/globals.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:DILGDOCS/screens/details_screen.dart';

class Issuance {
  final int id;
  final String type;
  final String title;
  final String referenceNo;
  final String date;
  final String pdfUrl;
  bool viewed;

  Issuance({
    required this.id,
    required this.type,
    required this.title,
    required this.referenceNo,
    required this.date,
    required this.pdfUrl,
    this.viewed = false,
  });
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Issuance> newIssuances = [];
  List<Issuance> yesterdayIssuances = [];
  List<Issuance> last7DaysIssuances = [];

  @override
  void initState() {
    super.initState();
    fetchRecentIssuances();
  }

  Future<void> fetchRecentIssuances() async {
    try {
      String? token = await AuthServices.getToken();
      final response = await http.get(
        Uri.parse('$baseURL/recent-issuances'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> recentData =
            json.decode(response.body)['recentIssuances'];

        SharedPreferences prefs = await SharedPreferences.getInstance();

        setState(() {
          newIssuances = (recentData['today'] as List<dynamic>).map((issuance) {
            return Issuance(
              id: issuance['id'],
              type: issuance['type'] ?? '',
              title: issuance['title'] ?? '',
              referenceNo: issuance['reference_no'] ?? '',
              date: issuance['date'] ?? '',
              pdfUrl: issuance['url_link'] ?? '',
              viewed: prefs.getBool(issuance['id'].toString()) ?? false,
            );
          }).toList();

          yesterdayIssuances =
              (recentData['yesterday'] as List<dynamic>).map((issuance) {
            return Issuance(
              id: issuance['id'],
              type: issuance['type'] ?? '',
              title: issuance['title'] ?? '',
              referenceNo: issuance['reference_no'] ?? '',
              date: issuance['date'] ?? '',
              pdfUrl: issuance['url_link'] ?? '',
              viewed: prefs.getBool(issuance['id'].toString()) ?? false,
            );
          }).toList();

          last7DaysIssuances =
              (recentData['last7Days'] as List<dynamic>).map((issuance) {
            return Issuance(
              id: issuance['id'],
              type: issuance['type'] ?? '',
              title: issuance['title'] ?? '',
              referenceNo: issuance['reference_no'] ?? '',
              date: issuance['date'] ?? '',
              pdfUrl: issuance['url_link'] ?? '',
              viewed: prefs.getBool(issuance['id'].toString()) ?? false,
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load recent issuances');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  

  void _navigateToDetailsScreen(BuildContext context, Issuance issuance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String content = '';

    if (issuance.referenceNo.isNotEmpty) {
      content += 'Reference #: ${issuance.referenceNo}\n';
    }
    if (issuance.date.isNotEmpty) {
      DateTime parsedDate = DateTime.parse(issuance.date);
      String formattedDate = DateFormat('MMMM dd, yyyy').format(parsedDate);
      content += 'Date: $formattedDate\n';
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          title: issuance.title,
          content: content,
          pdfUrl: issuance.pdfUrl,
          type: issuance.type,
        ),
      ),
    );

    setState(() {
      issuance.viewed = true;
      prefs.setBool(
          issuance.id.toString(), true);
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView(
        children: [
          if (newIssuances.isNotEmpty) ...[
            ListTile(
              title: Text('New Issuances',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            for (var issuance in newIssuances)
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!issuance.viewed) {
                        _navigateToDetailsScreen(context, issuance);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: issuance.viewed
                            ? Colors.transparent
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.notification_important,
                            color: Colors.blue),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              issuance.type,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              issuance.title,
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _navigateToDetailsScreen(context, issuance);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                      height: 4), // Add a smaller SizedBox instead of Divider
                ],
              ),
          ],
          if (yesterdayIssuances.isNotEmpty) ...[
            ListTile(
              title: Text('Yesterday Issuances',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            for (var issuance in yesterdayIssuances)
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!issuance.viewed) {
                        _navigateToDetailsScreen(context, issuance);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: issuance.viewed
                            ? Colors.transparent
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.notification_important,
                            color: Colors.blue),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              issuance.type,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              issuance.title,
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _navigateToDetailsScreen(context, issuance);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                      height: 4), // Add a smaller SizedBox instead of Divider
                ],
              ),
          ],
          if (last7DaysIssuances.isNotEmpty) ...[
            ListTile(
              title: Text('Last 7 Days Issuances',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            for (var issuance in last7DaysIssuances)
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!issuance.viewed) {
                        _navigateToDetailsScreen(context, issuance);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: issuance.viewed
                            ? Colors.transparent
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.notification_important,
                            color: Colors.blue),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              issuance.type,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              issuance.title,
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _navigateToDetailsScreen(context, issuance);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                      height: 4), // Add a smaller SizedBox instead of Divider
                ],
              ),
          ],
        ],
      ),
    );
  }
}
