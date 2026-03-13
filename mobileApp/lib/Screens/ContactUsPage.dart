import 'package:flutter/material.dart';
import '../Widgets/PageLayout.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: "Contact Us",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 10),
          Text(
            "You can reach us at:\nEmail: support@womenbiz360.com\nPhone: +255 123 456 789",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}