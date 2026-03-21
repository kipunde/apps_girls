import 'package:flutter/material.dart';
import '../Widgets/PageLayout.dart';

class QuizzesPage extends StatelessWidget {
  const QuizzesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: "Help & Support",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 10),
          Text(
            "FAQ:\n1. How do I enroll in a course?\n2. How do I access materials?\n3. Contact support if you have other questions.",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}