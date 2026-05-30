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

  Future<void> _checkUserSession() async {
    final user = await authService.getUserAccessDetails();

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SignInScreen()),
      );
    } else {
      userId = int.tryParse(user.id ?? '0');
      _loadCourses();
    }
  }

  void _loadCourses() {
    setState(() {
      _coursesFuture = _fetchCoursesForUser();
    });
  }

  Future<List<Course>> _fetchCoursesForUser() async {
    if (userId == null) return [];

    final apiResponse = await apiService.getCourses();
    final loggedUserId = userId ?? 0;

    final Map<int, Course> uniqueCourses = {};

    for (var course in apiResponse) {
      final isEnrolledForUser =
          course.isEnrolled && (loggedUserId == course.userId);

      if (!uniqueCourses.containsKey(course.id)) {
        uniqueCourses[course.id] = Course(
          id: course.id,
          title: course.title,
          description: course.description,
          thumbnail: course.thumbnail,
          status: course.status,
          isEnrolled: isEnrolledForUser,
          userId: course.userId,
        );
      } else {
        final existing = uniqueCourses[course.id]!;
        uniqueCourses[course.id] = Course(
          id: existing.id,
          title: existing.title,
          description: existing.description,
          thumbnail: existing.thumbnail,
          status: existing.status,
          isEnrolled: existing.isEnrolled || isEnrolledForUser,
          userId: existing.userId ?? course.userId,
        );
      }
    }

    return uniqueCourses.values.toList();
  }

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
          style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white, // Use Colors.white instead of white
          ),
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 🔥 BANNER
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

                        const SizedBox(height: 20),

                        /// TITLE
                        const Text(
                          "Explore Our Courses",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// DESCRIPTION
                        Text(
                          "Gain essential business, finance, and digital marketing skills through expert courses tailored for women entrepreneurs.",
                          style: TextStyle(color: Colors.grey[700]),
                        ),

                        const SizedBox(height: 20),

                        /// GRID
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

                            if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Text("No courses available.");
                            }

                            final courses = snapshot.data!;

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                double width = constraints.maxWidth;

                                int crossAxisCount =
                                    width < 600 ? 2 : 3;

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: courses.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio:
                                        width < 400 ? 0.60 : 0.68,
                                  ),
                                  itemBuilder: (context, index) =>
                                      courseCard(courses[index]),
                                );
                              },
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

  /// ================= COURSE CARD =================
 Widget courseCard(Course course) {
  String shortDescription = course.description.length > 40
      ? course.description.substring(0, 40) + "..."
      : course.description;

  return LayoutBuilder(
    builder: (context, constraints) {
      double w = constraints.maxWidth;

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xfff3dede),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// 🔥 SMALL IMAGE WITH WHITE BACKGROUND
            Column(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: course.thumbnail != null &&
                              course.thumbnail!.isNotEmpty
                          ? Image.network(
                              course.thumbnail!,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return Image.asset(
                                  "images/banner.png",
                                  fit: BoxFit.contain,
                                );
                              },
                            )
                          : Image.asset(
                              "images/banner.png",
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                /// TITLE
                Text(
                  course.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (w * 0.075).clamp(13.0, 17.0),
                  ),
                ),

                const SizedBox(height: 4),

                /// DESCRIPTION
                Text(
                  shortDescription,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: (w * 0.055).clamp(11.0, 14.0),
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              height: w < 140 ? 32 : 36,
              child: ElevatedButton(
                onPressed: () async {
                  if (course.isEnrolled) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CourseDetailPage(course: course),
                      ),
                    );
                  } else {
                    if (userId == null) return;

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Enroll in ${course.title}?"),
                        content: const Text(
                            "Do you want to enroll in this course?"),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              bool enrolled = await apiService
                                  .enrollCourse(
                                      course.id, userId!);

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(enrolled
                                      ? "Enrolled successfully!"
                                      : "Enrollment failed."),
                                ),
                              );

                              if (enrolled) _loadCourses();
                            },
                            child: const Text("Enroll"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffe91e63),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                child: FittedBox(
                  child: Text(
                    course.isEnrolled
                        ? "View Course"
                        : "Enroll",
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
}