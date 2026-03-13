import 'dart:io';
import 'package:flutter/material.dart';

import '../Models/Course.dart';
import '../Services/ApiService.dart';
import '../Services/AuthService.dart';
import 'DrawerWidget.dart';
import 'SignInScreen.dart';
import 'CourseDetailPage.dart';

class MyCoursesPage extends StatefulWidget {
  static String tag = "MyCoursesPage";

  @override
  MyCoursesPageState createState() => MyCoursesPageState();
}

class MyCoursesPageState extends State<MyCoursesPage> {
  final ApiService apiService = ApiService();
  final AuthService authService = AuthService();

  Future<List<Course>>? _coursesFuture;
  int? userId;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  /// CHECK IF USER IS LOGGED IN
  Future<void> _checkUserSession() async {
    final user = await authService.getUserAccessDetails();

    if (user == null) {
      // NOT LOGGED IN → GO TO LOGIN
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SignInScreen()),
      );
    } else {
      // STORE USER ID
      userId = int.tryParse(user.id ?? '0');
      _loadCourses();
    }
  }

  /// LOAD USER COURSES
  void _loadCourses() {
    if (userId != null) {
      setState(() {
        _coursesFuture = apiService.getUserCourses(userId!);
      });
    }
  }

  /// REFRESH HANDLER
  Future<void> _refreshCourses() async {
    _loadCourses();
    await _coursesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: DrawerWidget(),
        appBar: AppBar(
          backgroundColor: const Color(0xffe91e63),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => exit(0),
          ),
          title: const Text(
            "WomenBiz 360",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ],
        ),
        body: _coursesFuture == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshCourses,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TOP BANNER
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage("images/banner.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          "My Courses",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Here are the courses you are enrolled in. Tap a course to start learning.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),

                        /// COURSES
                        FutureBuilder<List<Course>>(
                          future: _coursesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Text(
                                "Error: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text(
                                  "You are not enrolled in any courses yet.",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }

                            final courses = snapshot.data!;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: courses.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.8,
                              ),
                              itemBuilder: (context, index) =>
                                  courseCard(courses[index]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  /// COURSE CARD
  Widget courseCard(Course course) {
    String shortDescription = course.description.length > 25
        ? course.description.substring(0, 25) + "..."
        : course.description;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff3dede),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          course.thumbnail.isNotEmpty
              ? Image.network(
                  course.thumbnail,
                  height: 70,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.school, size: 50, color: Colors.blue),
          const SizedBox(height: 10),
          Text(
            course.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            shortDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseDetailPage(course: course),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Start Your Course"),
            ),
          ),
        ],
      ),
    );
  }
}