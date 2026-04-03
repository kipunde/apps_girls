import 'package:flutter/material.dart';
import 'DocumentViewerPage.dart';
import '../Models/CourseModule.dart';

class DocumentListPage extends StatelessWidget {
  final List<CourseModule> documents;

  const DocumentListPage({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Documents"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              title: Text(doc.title),
              subtitle: Text(doc.documentPath ?? ""),
              trailing: ElevatedButton(
                onPressed: () {
                  if (doc.documentPath != null && doc.documentPath!.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentViewerPage(url: doc.documentPath!),
                      ),
                    );
                  }
                },
                child: const Text("View"),
              ),
            ),
          );
        },
      ),
    );
  }
}