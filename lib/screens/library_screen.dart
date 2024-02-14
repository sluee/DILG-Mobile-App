import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'downloadedfile_screen.dart';
import 'dart:io'; // Import 'dart:io' for File and Directory
import 'package:path_provider/path_provider.dart'; // Import 'package:path_provider/path_provider.dart' for getApplicationDocumentsDirectory


class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> downloadedFiles = [];
  List<String> filteredFiles = [];
  bool isSearching = false;
  String _selectedSortOption = 'Date'; // Initialize with default sorting option
List<String> _sortOptions = ['Date', 'Name']; // Define sorting options




//For Latest Issuances
 @override
void initState() {
  super.initState();
  _loadRootDirectory();
}

void _loadRootDirectory() async {

    final appDir = await getExternalStorageDirectory();
    print('Root directory path: ${appDir?.path}');
    if (appDir == null) {
      print('Error: Failed to get the root directory path');
      return;
    }

    final rootDirectory = Directory(appDir.path);
    await loadDownloadedFiles(rootDirectory); // Use await here

    // Populate filteredFiles with all downloaded files
    setState(() {
      filteredFiles.addAll(downloadedFiles);
    });
  }
Future<void> loadDownloadedFiles(Directory directory) async {
  // Map to store files grouped by their folder names
   List<FileSystemEntity> entities = directory.listSync();

  // Iterate over each entity in the directory
  for (var entity in entities) {
    // If the entity is a directory, recursively call loadDownloadedFiles on it
    if (entity is Directory) {
      await loadDownloadedFiles(entity); // Use await here
    }
    // If the entity is a file and ends with .pdf, add its path to downloadedFiles
    else if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
      downloadedFiles.add(entity.path);
    }
  }
  // Sort the downloaded files alphabetically
  downloadedFiles.sort();
  // Add the PDF files from the current directory to the downloadedFiles list
  
}

//for Latest Issuances - API@override
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchAndFilterRow(),
            _buildPdf(context),
          ],
        ),
      ),
    );
  }

Widget _buildSearchAndFilterRow() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isSearching ? MediaQuery.of(context).size.width - 96 : 48,
                decoration: BoxDecoration(
                  color: isSearching ? Colors.grey[200] : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Visibility(
                        visible: isSearching,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            _filterFiles(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(isSearching ? Icons.clear : Icons.search),
                      color: isSearching ? Colors.blue : null,
                      onPressed: () {
                        setState(() {
                          isSearching = !isSearching;
                          if (!isSearching) {
                            _searchController.clear();
                            _filterFiles('');
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedSortOption,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSortOption = newValue!;
                  _sortFiles(newValue);
                });
              },
              items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    ),
  );
}



  Widget _buildPdf(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16),
        if (filteredFiles.isEmpty)
          Center(
            child: Text(
              'No downloaded issuances',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        if (filteredFiles.isNotEmpty)
          Column(
            children: [
              Text(
                'Downloaded Files:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: filteredFiles.map((file) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        openPdfViewer(context, file);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          file.split('/').last,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
      ],
    );
  }


void _sortFiles(String option) {
  if (option == 'Date') {
    _showDateRangePicker();
  } else {
    setState(() {
      // Implement sorting logic based on the selected option
      if (option == 'Latest to Oldest') {
        // Sort files by date in descending order
        downloadedFiles.sort((a, b) => File(b).lastModifiedSync().compareTo(File(a).lastModifiedSync()));
      } else if (option == 'Oldest to Latest') {
        // Sort files by date in ascending order
        downloadedFiles.sort((a, b) => File(a).lastModifiedSync().compareTo(File(b).lastModifiedSync()));
      } else if (option == 'Name A-Z') {
        // Sort files by name in ascending order
        downloadedFiles.sort((a, b) => a.compareTo(b));
      } else if (option == 'Name Z-A') {
        // Sort files by name in descending order
        downloadedFiles.sort((a, b) => b.compareTo(a));
      }
      // Update filtered files accordingly
      _filterFiles(_searchController.text);
    });
  }
}
Future<void> _showDateRangePicker() async {
  DateTimeRange? pickedRange = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2010),
    lastDate: DateTime.now(),
  );

  if (pickedRange != null) {
    setState(() {
      // Filter files based on the selected date range
      filteredFiles = downloadedFiles.where((filePath) {
        File file = File(filePath);
        DateTime lastModified = file.lastModifiedSync();
        return pickedRange.start.isBefore(lastModified) && pickedRange.end.isAfter(lastModified);
      }).toList();
    });
  }
}


  void _filterFiles(String query) {
    setState(() {
      filteredFiles = downloadedFiles
          .where((file) => file.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
Future<void> openPdfViewer(BuildContext context, String filePath) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PDFView(
        filePath: filePath,
        // Implement additional options if needed
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageSnap: true,
        onViewCreated: (PDFViewController controller) {
          // You can use the controller to interact with the PDFView
        },
        // onPageChanged: (int page, int total) {
        //   // Handle page changes if needed
        // },
      ),
    ),
  );
}

String getFolderName(String path) {
  List<String> parts = path.split('/');
  if (parts.length > 1) {
    String folder = parts[parts.length - 2]; // Get the second-to-last part of the path
    print('Folder name extracted: $folder');
    return folder;
  }
  // Default category if no matching folder is found
  print('No folder name found in path: $path');
  return 'Other';
}
