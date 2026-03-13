import 'package:flutter/material.dart';
import '../Widgets/PageLayout.dart';

class LiveClassPage extends StatelessWidget {
  const LiveClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: "Live Classes",
      body: Column(
        children: const [
          SizedBox(height: 10),
          Text(
            "Live classes will appear here",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}