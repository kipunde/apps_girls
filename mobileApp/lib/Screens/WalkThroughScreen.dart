import 'package:esrs_eqa_app/Services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../Services/AuthService.dart';
import '../utils/AppColors.dart';
import 'HomeScreen.dart';
import 'SignInScreen.dart';

class WalkThroughScreen extends StatefulWidget {
  @override
  State<WalkThroughScreen> createState() => _WalkThroughScreenState();
}

class _WalkThroughScreenState extends State<WalkThroughScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;
  final authService = AuthService(); // ✅ AuthService instance

  final List<Map<String, String>> pages = [
    {
      "title": "Welcome to Online Learning",
      "subtitle":
          "Access courses, learn new skills, and study anytime from anywhere.",
      "image": "images/welcome.png",
    },
    {
      "title": "Learn From Experts",
      "subtitle": "Study high quality lessons from experienced trainers.",
      "image": "images/book.png",
    },
    {
      "title": "Grow Your Skills",
      "subtitle": "Improve your career and gain valuable knowledge.",
      "image": "images/ajira.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // ✅ check if already logged in
  }

  // ----------------- CHECK LOGIN -----------------
  void _checkLoginStatus() async {
    final token = await authService.getToken();
    if (token != null && token.isNotEmpty) {
      // User is already logged in → go to HomeScreen
      HomeScreen().launch(context, isNewTask: true);
    }
    // else stay on walkthrough
  }

  void nextPage() {
    if (currentIndex < pages.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      SignInScreen().launch(context, isNewTask: true); // Go to login after walkthrough
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (_, index) {
              final page = pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      page["image"]!,
                      height: 260,
                    ),
                    40.height,
                    Text(
                      page["title"]!,
                      style: boldTextStyle(size: 26),
                      textAlign: TextAlign.center,
                    ),
                    16.height,
                    Text(
                      page["subtitle"]!,
                      style: secondaryTextStyle(size: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          /// Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                SignInScreen().launch(context, isNewTask: true);
              },
              child: Text(
                "Skip",
                style: boldTextStyle(color: const Color(0xffe91e63)),
              ),
            ),
          ),

          /// Page Indicator
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: currentIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? const Color(0xffe91e63)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          /// Next / Get Started Button
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: AppButton(
              color: const Color(0xffe91e63),
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              height: 50,
              text: currentIndex == pages.length - 1 ? "Get Started" : "Next",
              textStyle: boldTextStyle(color: white),
              onTap: nextPage,
            ),
          ),
        ],
      ),
    );
  }
}