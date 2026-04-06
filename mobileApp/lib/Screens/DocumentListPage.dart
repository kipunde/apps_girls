import 'package:flutter/material.dart';
import '../Models/CourseModule.dart';
import '../Services/ApiService.dart';
import 'DocumentViewerPage.dart';

class DocumentListPage extends StatefulWidget {
  final int moduleId;

  const DocumentListPage({super.key, required this.moduleId});

  @override
  State<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends State<DocumentListPage> {
  List<CourseModule> documents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    setState(() => isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.getDocumentsByModule(widget.moduleId);
      print("Data zipo $response");
      setState(() {
        documents = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching documents: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Documents"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : documents.isEmpty
              ? const Center(
                  child: Text("No documents available for this module"),
                )
              : ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];

                    // Ensure title and documentPath are not empty
                    final title = doc.title.isNotEmpty ? doc.title : "Untitled Document";
                    final path = doc.documentPath ?? "";

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(path),
                        trailing: ElevatedButton(
                          onPressed: path.isNotEmpty
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DocumentViewerPage(url: path),
                                    ),
                                  );
                                }
                              : null,
                          child: const Text("View"),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}