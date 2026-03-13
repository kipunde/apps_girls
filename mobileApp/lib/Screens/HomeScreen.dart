import 'dart:io';
import 'package:flutter/material.dart';

import '../Models/Course.dart';
import '../Services/ApiService.dart';
import '../Services/AuthService.dart';
import 'DrawerWidget.dart';
import 'SignInScreen.dart';
import 'CourseDetailPage.dart';

class HomeScreen extends StatefulWidget {
  static String tag = "HomeScreen";

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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

  /// LOAD COURSES FROM API
  void _loadCourses() {
    setState(() {
      _coursesFuture = apiService.getCourses();
    });
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
                          "Explore Our Courses",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Gain essential business, finance, and digital marketing skills through expert courses tailored for women entrepreneurs.",
                          style: TextStyle(color: Colors.grey[700]),
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
                              return const Text("No courses available.");
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
              onPressed: () async {
                if (course.isEnrolled) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseDetailPage(course: course),
                    ),
                  );
                } else {
                  if (userId == null) return; // safeguard
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Enroll in ${course.title}?"),
                      content: const Text(
                          "Do you want to enroll in this course to access full content and modules?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            bool enrolled = await apiService.enrollCourse(
                                course.id, userId!);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(enrolled
                                      ? "Enrolled successfully!"
                                      : "Enrollment failed")),
                            );
                            if (enrolled) {
                            _loadCourses(); // reload page data
                            }
                          },
                          child: const Text("Enroll"),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: course.isEnrolled ? Colors.green : Colors.orange,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              ),
              ),
              child: Text(course.isEnrolled
                  ? "Start Your Course"
                  : "Enroll This Course"),
            ),
          ),
        ],
      ),
    );
  }
}