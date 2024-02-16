import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class LibraryScreen extends StatefulWidget {
  final Function(String, String) onFileOpened;

  LibraryScreen({required this.onFileOpened});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> downloadedFiles = [];
  List<String> filteredFiles = [];
  bool isSearching = false;
  String _selectedSortOption = 'Date';
  List<String> _sortOptions = ['Date', 'Name'];

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
    await loadDownloadedFiles(rootDirectory);

    setState(() {
      filteredFiles.addAll(downloadedFiles);
    });
  }

  Future<void> loadDownloadedFiles(Directory directory) async {
    List<FileSystemEntity> entities = directory.listSync();

    for (var entity in entities) {
      if (entity is Directory) {
        await loadDownloadedFiles(entity);
      } else if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
        downloadedFiles.add(entity.path);
      }
    }

    downloadedFiles.sort();
  }

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
                  width:
                      isSearching ? MediaQuery.of(context).size.width - 96 : 48,
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
              SizedBox(width: 10),
              DropdownButton<String>(
                value: _selectedSortOption,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSortOption = newValue!;
                    _sortFiles(newValue);
                  });
                },
                items:
                    _sortOptions.map<DropdownMenuItem<String>>((String value) {
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
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredFiles.length,
                itemBuilder: (BuildContext context, int index) {
                  final String file = filteredFiles[index];
                  return Dismissible(
                    key: Key(file),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.0),
                      color: Colors.red,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteConfirmationDialog(context, file);
                    },
                    onDismissed: (direction) {},
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  file.split('/').last,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Container(
                            height: 0.5, // Adjust thickness here
                            color: Colors.black,
                          ),
                        ],
                      ),
                      onTap: () {
                        openPdfViewer(context, file, widget.onFileOpened);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  void _sortFiles(String option) {
    setState(() {
      if (option == 'Date') {
        downloadedFiles.sort((a, b) =>
            File(a).lastModifiedSync().compareTo(File(b).lastModifiedSync()));
      } else if (option == 'Name') {
        downloadedFiles.sort((a, b) => a.compareTo(b));
      }
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

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String filePath) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this file?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when cancelled
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteFile(filePath); // Delete the file when confirmed
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _deleteFile(String filePath) {
    try {
      File file = File(filePath);
      file.deleteSync();
      downloadedFiles.remove(filePath);
      filteredFiles.remove(filePath);

      // Show a confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("The file has been successfully deleted."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the success dialog
                  Navigator.of(context)
                      .pop(); // Dismiss the confirmation dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );

      setState(() {});
    } catch (e) {
      print("Failed to delete file: $e");
      // Show an error dialog if deletion fails
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to delete the file."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
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
    String folder = parts[parts.length - 2];
    print('Folder name extracted: $folder');
    return folder;
  }
  print('No folder name found in path: $path');
  return 'Other';
}