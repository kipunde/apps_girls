import 'package:flutter/material.dart';
import '../Widgets/PageLayout.dart';

class MaterialsPage extends StatelessWidget {
  const MaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: "Materials",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 10),
          Text("Course materials will be listed here.", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}