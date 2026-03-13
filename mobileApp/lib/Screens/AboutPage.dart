import 'package:flutter/material.dart';
import '../Widgets/PageLayout.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: "About Us",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 10),
          Text(
            "WomenBiz 360 is a platform that empowers women through business and digital skills training.",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}