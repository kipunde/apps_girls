import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocumentViewerPage extends StatefulWidget {
  final String url;

  const DocumentViewerPage({super.key, required this.url});

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    // Encode URL and load Google Docs Viewer for most document types (pdf, docx, xlsx, txt)
    final viewerUrl =
        "https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.url)}";

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Viewer"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}