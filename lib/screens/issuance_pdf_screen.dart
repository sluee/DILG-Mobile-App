import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class IssuancePDFScreen extends StatefulWidget {
  final String title; // Title of the issuance

  IssuancePDFScreen({required this.title});

  @override
  _IssuancePDFScreenState createState() => _IssuancePDFScreenState();
}

class _IssuancePDFScreenState extends State<IssuancePDFScreen> {
  String? _pdfPath;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    final appDir = await getExternalStorageDirectory();
    print('Root directory path: ${appDir?.path}');
    if (appDir == null) {
      print('Error: Failed to get the root directory path');
      return;
    }

    final rootDirectory = Directory(appDir.path);
    final pdfPath = await _findPDF(rootDirectory, widget.title);
    setState(() {
      _pdfPath = pdfPath;
    });
  }

  Future<String?> _findPDF(Directory directory, String title) async {
    List<FileSystemEntity> entities = directory.listSync();

    for (var entity in entities) {
      if (entity is Directory) {
        final pdfPath = await _findPDF(entity, title);
        if (pdfPath != null) {
          return pdfPath;
        }
      } else if (entity is File &&
          entity.path.toLowerCase().endsWith('.pdf') &&
          entity.path.contains(title)) {
        return entity.path;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _pdfPath != null
          ? Center(
              child: PDFView(
                filePath: _pdfPath!,
                fitPolicy: FitPolicy.WIDTH,
              ),
            )
          : Center(
              child: Text(
                'PDF Not Found',
                style: TextStyle(fontSize: 24),
              ),
            ),
    );
  }
}