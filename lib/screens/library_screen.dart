import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'downloadedfile_screen.dart';
import 'dart:io'; // Import 'dart:io' for File and Directory
import 'package:path_provider/path_provider.dart'; // Import 'package:path_provider/path_provider.dart' for getApplicationDocumentsDirectory


class LibraryScreen extends StatefulWidget {
   final Function(String, String) onFileOpened;

  LibraryScreen ({required this.onFileOpened});
  

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
              'No downloaded issuance/s',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (filteredFiles.isNotEmpty)
          Column(
            children: [  
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
                        openPdfViewer(context, file, widget.onFileOpened);
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
  setState(() {
    // Implement sorting logic based on the selected option
    if (option == 'Date') {
      // Sort files by date
      downloadedFiles.sort((a, b) => File(a).lastModifiedSync().compareTo(File(b).lastModifiedSync()));
    } else if (option == 'Name') {
      // Sort files by name
      downloadedFiles.sort((a, b) => a.compareTo(b));
    }
    // Update filtered files accordingly
    _filterFiles(_searchController.text);
  });
}

  void _filterFiles(String query) {
    setState(() {
      filteredFiles = downloadedFiles
          .where((file) => file.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}

Future<void> openPdfViewer(BuildContext context, String filePath,
    Function(String, String) onFileOpened) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageSnap: true,
        onViewCreated: (PDFViewController controller) {},
      ),
    ),
  );

  String fileName = filePath.split('/').last;
  onFileOpened(fileName, filePath);
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
