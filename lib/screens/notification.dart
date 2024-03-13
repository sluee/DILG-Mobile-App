import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:DILGDOCS/Services/auth_services.dart';
import 'package:DILGDOCS/Services/globals.dart';
 import 'package:intl/intl.dart';
import 'package:DILGDOCS/screens/details_screen.dart'; // Import DetailsScreen

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> newIssuances = [];
  List<dynamic> yesterdayIssuances = [];
  List<dynamic> last7DaysIssuances = [];

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
        Map<String, dynamic> recentData = json.decode(response.body)['recentIssuances'];

        setState(() {
          newIssuances = recentData['today'];
          yesterdayIssuances = recentData['yesterday'];
          last7DaysIssuances = recentData['last7Days'];
        });
      } else {
        throw Exception('Failed to load recent issuances');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  void _navigateToDetailsScreen(BuildContext context, dynamic issuance) {
    String referenceNo = issuance['reference_no'] ?? '';
    String date = issuance['date'] ?? '';
    String content = '';

    // Concatenate reference number and formatted date if they are available
    if (referenceNo.isNotEmpty) {
      content += 'Reference #: $referenceNo\n';
    }
    if (date.isNotEmpty) {
      // Format the date using DateFormat
      DateTime parsedDate = DateTime.parse(date);
      String formattedDate = DateFormat('MMMM dd, yyyy').format(parsedDate);
      content += 'Date: $formattedDate\n';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          title: issuance['title'] ?? '',
          content: content,
          pdfUrl: issuance['url_link'] ?? '',
          type: issuance['type'] ?? '',
        ),
      ),
    );
  }



  Widget _buildListTile(dynamic issuance) {
  return Column(
    children: [
      ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in the center
          children: [
            Icon(
              Icons.picture_as_pdf, // Icon for PDF
              color: Colors.blue, // Customize icon color as needed
            ),
            SizedBox(width: 10), // Add some spacing between icon and text
            Text(
              issuance['type'] ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text(issuance['title'] ?? ''),
        onTap: () {
          _navigateToDetailsScreen(context, issuance);
        },
      ),
      Divider(), // Add a divider between list tiles
    ],
  );
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
            title: Text('New Issuances', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (var issuance in newIssuances) _buildListTile(issuance),
        ],
        if (yesterdayIssuances.isNotEmpty) ...[
          ListTile(
            title: Text('Yesterday Issuances', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (var issuance in yesterdayIssuances) _buildListTile(issuance),
        ],
        if (last7DaysIssuances.isNotEmpty) ...[
          ListTile(
            title: Text('Last 7 Days Issuances', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (var issuance in last7DaysIssuances) _buildListTile(issuance),
        ],
      ],
    ),
  );
}

}
