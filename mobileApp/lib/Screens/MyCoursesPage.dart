import 'package:flutter/material.dart';
import '../Widgets/PageLayout.dart';
import '../Models/Course.dart';
import '../Services/ApiService.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  final ApiService apiService = ApiService();
  late Future<List<Course>> _myCourses;

  @override
  void initState() {
    super.initState();
    _myCourses = apiService.getCourses(); // API call for user's enrolled courses
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: "My Courses",
      body: FutureBuilder<List<Course>>(
        future: _myCourses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          final courses = snapshot.data ?? [];
          if (courses.isEmpty) return const Text("You have no enrolled courses.");
          return Column(
            children: courses.map((course) => Text(course.title)).toList(),
          );
        },
      ),
    );
  }
}