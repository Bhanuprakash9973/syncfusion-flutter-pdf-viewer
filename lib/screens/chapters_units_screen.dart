import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ChapterUnitsScreen extends StatefulWidget {
  final String subject;

  ChapterUnitsScreen({required this.subject});

  @override
  _ChapterUnitsScreenState createState() => _ChapterUnitsScreenState();
}

class _ChapterUnitsScreenState extends State<ChapterUnitsScreen> {
  List<Map<String, dynamic>>? chapterUnits;
  List<int>? _documentBytes;
  Set<String> downloadedFiles = {};

  @override
  void initState() {
    super.initState();
    fetchChapterUnits(widget.subject);
  }

  Future<void> fetchChapterUnits(String subject) async {
    final response = await http.get(Uri.parse(
        'https://www.eschool2go.org/api/v1/project/ba7ea038-2e2d-4472-a7c2-5e4dad7744e3?path=$subject'));

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      responseData.sort((a, b) => a['title'].compareTo(b['title']));

      setState(() {
        chapterUnits = List<Map<String, dynamic>>.from(responseData);
      });
    } else {
      throw Exception('Failed to load chapter units');
    }
  }

  // Method to download PDF bytes
  Future<void> getPdfBytesFromWeb(String url, String title) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading PDF...'),
        duration: Duration(seconds: 2), // Adjust duration as needed
      ),
    );

    _documentBytes = await http.readBytes(Uri.parse(url));
    downloadedFiles.add(title);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF Downloaded'),
        duration: Duration(seconds: 2), // Adjust duration as needed
      ),
    );
    setState(() {});
  }

  // Method to view PDF using Syncfusion PDF viewer
  void viewPdf() {
    if (_documentBytes != null) {
      Uint8List uint8List = Uint8List.fromList(_documentBytes!);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SfPdfViewer.memory(
            uint8List,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter Units - ${widget.subject}'),
      ),
      body: chapterUnits == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(5),
              itemCount: chapterUnits?.length ?? 0,
              itemBuilder: (context, index) {
                final title = chapterUnits![index]['title'] ?? 'No title';
                final isDownloaded = downloadedFiles.contains(title);
                final url = chapterUnits![index]['download_url'];
                return ListTile(
                  splashColor: Colors.blue.shade300,
                  minVerticalPadding: 25,
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        if (!isDownloaded) {
                          getPdfBytesFromWeb(url, title);
                        } else {
                          viewPdf();
                        }
                      },
                      icon: isDownloaded
                          ? const Icon(
                              Icons.cloud_done,
                              color: Colors.green,
                            )
                          : const Icon(
                              Icons.download,
                              color: Colors.red,
                            )),
                  onTap: () {
                    if (isDownloaded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening Chapter $title'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      viewPdf();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Chapter is not downloaded.'),
                            duration: Duration(seconds: 2)),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
