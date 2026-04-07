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

    // --- Ensure full URL for Google Docs Viewer ---
    String fullUrl = widget.url;

    // If the URL doesn't start with http, prepend your server base path
    if (!fullUrl.startsWith('http')) {
      fullUrl = "https://prasperascons.com/app/api/uploads/modules/$fullUrl";
    }

    final viewerUrl =
        "https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(fullUrl)}";

    print("document is $fullUrl");

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