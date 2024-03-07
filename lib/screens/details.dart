import 'dart:io';
import 'package:DILGDOCS/screens/pdf_preview.dart';
import 'package:DILGDOCS/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


class DetailsScreen extends StatelessWidget {
  final SearchResult searchResult;
  

  const DetailsScreen({required this.searchResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          searchResult.title,
          style: TextStyle(color: Colors.white,  fontFamily: 'Poppins'),
        ),
         leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[900],
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PdfPreview(url: searchResult.pdfUrl),
            SizedBox(height: 50),
            // Button to download PDF
            ElevatedButton(
              onPressed: () {
                downloadAndSavePdf(context, searchResult.pdfUrl, searchResult.title);
              },
              child: Text('Download PDF'),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildSearchResults(List<SearchResult> searchResults, String searchInput) {
  if (searchInput.isEmpty) {
    return SizedBox.shrink();
  }

  return searchResults.isNotEmpty
      ? SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final SearchResult result = searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            searchResult: result,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        result.title,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        )
      : Center(child: Text('No results found'));
}
 
Future<void> downloadAndSavePdf(
    BuildContext context, String url, String title) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Downloading PDF...'),
            ],
          ),
        ),
      );
    },
  );

  try {
    final appDir = await getExternalStorageDirectory();
    final directoryPath = '${appDir!.path}/PDFs';
    final sanitizedTitle = sanitizeFilename(title); // Sanitize the title
    final truncatedTitle = truncateTitle(sanitizedTitle); // Truncate the title
    final filePath = '$directoryPath/$truncatedTitle.pdf';

    final file = File(filePath);
    if (await file.exists()) {
      Navigator.of(context).pop(); // Close the loading dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('File Already Downloaded'),
            content: Text(
                'The PDF has already been downloaded and saved locally.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      await file.writeAsBytes(response.bodyBytes);

      print('PDF downloaded and saved at: $filePath');

      Navigator.of(context).pop(); // Close the loading dialog

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Download Complete'),
            content: Text('The PDF has been downloaded and saved locally.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      throw Exception('Failed to load PDF: ${response.statusCode}');
    }
  } catch (e) {
    print('Error downloading PDF: $e');
    Navigator.of(context).pop(); // Close the loading dialog
  }
}

String truncateTitle(String title, {int maxLength = 250}) {
  if (title.length <= maxLength) {
    return title;
  } else {
    return title.substring(0, maxLength - 3) + '...';
  }
}


String sanitizeFilename(String filename) {
  // Replace characters that are not allowed in file names
  return filename.replaceAll(RegExp(r'[<>:"/\\|?*]|\$\$'), '_');
}



}