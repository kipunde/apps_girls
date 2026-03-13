import 'package:flutter/material.dart';
import '../Widgets/PageLayout.dart';

class MyModulesPage extends StatelessWidget {
  const MyModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: "My Modules",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 10),
          Text("Your modules will appear here", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}