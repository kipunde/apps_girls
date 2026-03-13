import 'package:flutter/material.dart';
import '../Screens/DrawerWidget.dart';
import 'CommonHeader.dart';

class PageLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBack;

  const PageLayout({
    super.key,
    required this.title,
    required this.body,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: DrawerWidget(),
        appBar: CommonHeader(title: title, showBack: showBack),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Top Banner
              Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage("images/banner.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Page content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}