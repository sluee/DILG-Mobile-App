// Import necessary packages
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:DILGDOCS/Services/auth_services.dart';
import 'package:DILGDOCS/Services/globals.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:DILGDOCS/screens/details_screen.dart'; // Import DetailsScreen

// Define Issuance class with viewed status
class Issuance {
  final String type;
  final String title;
  final String referenceNo;
  final String date;
  final String pdfUrl;
  bool viewed; // New field to track whether the issuance has been viewed or not

  Issuance({
    required this.type,
    required this.title,
    required this.referenceNo,
    required this.date,
    required this.pdfUrl,
    this.viewed = false, // Default value for viewed is false
  });
}

// NotificationScreen class
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

  // Fetch recent issuances
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
              type: issuance['type'] ?? '',
              title: issuance['title'] ?? '',
              referenceNo: issuance['reference_no'] ?? '',
              date: issuance['date'] ?? '',
              pdfUrl: issuance['url_link'] ?? '',
              viewed: prefs.getBool(issuance['title'] ?? '') ?? false,
            );
          }).toList();

          yesterdayIssuances =
              (recentData['yesterday'] as List<dynamic>).map((issuance) {
            return Issuance(
              type: issuance['type'] ?? '',
              title: issuance['title'] ?? '',
              referenceNo: issuance['reference_no'] ?? '',
              date: issuance['date'] ?? '',
              pdfUrl: issuance['url_link'] ?? '',
              viewed: prefs.getBool(issuance['title'] ?? '') ?? false,
            );
          }).toList();

          last7DaysIssuances =
              (recentData['last7Days'] as List<dynamic>).map((issuance) {
            return Issuance(
              type: issuance['type'] ?? '',
              title: issuance['title'] ?? '',
              referenceNo: issuance['reference_no'] ?? '',
              date: issuance['date'] ?? '',
              pdfUrl: issuance['url_link'] ?? '',
              viewed: prefs.getBool(issuance['title'] ?? '') ?? false,
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

  // Navigate to DetailsScreen and update viewed status
  void _navigateToDetailsScreen(BuildContext context, Issuance issuance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String content = '';

    // Concatenate reference number and formatted date if they are available
    if (issuance.referenceNo.isNotEmpty) {
      content += 'Reference #: ${issuance.referenceNo}\n';
    }
    if (issuance.date.isNotEmpty) {
      // Format the date using DateFormat
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

    // Update viewed status and persist in SharedPreferences
    setState(() {
      issuance.viewed = true;
      prefs.setBool(issuance.title, true);
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
          // Display new issuances
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
                  SizedBox(height: 4),
                ],
              ),
          ],
          // Display yesterday's issuances
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
                  SizedBox(height: 4),
                ],
              ),
          ],
          // Display last 7 days' issuances
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
                  SizedBox(height: 4),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
