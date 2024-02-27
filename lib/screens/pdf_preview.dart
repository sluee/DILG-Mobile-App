import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
class PdfPreview extends StatelessWidget {
  final String url;

  const PdfPreview({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _loadPdfFromUrl(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 40),
                Text(
                  'Previewing PDF...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'No PDF Link available',
              style: TextStyle(fontSize: 16),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return Expanded(
            child: PDFView(
              filePath: snapshot.data!.path,
              pageSnap: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
              onError: (error) {
                print('Error loading PDF: $error');
              },
            ),
          );
        } else {
           return Center(child: Text('Error loading PDF: ${snapshot.error}'));
          
        }
      },
    );
  }

  Future<File> _loadPdfFromUrl(String url) async {
    final filename = url.split('/').last;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    if (await file.exists()) {
      return file;
    } else {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
    }
  }
}