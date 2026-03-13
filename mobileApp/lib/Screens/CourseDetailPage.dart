import 'package:flutter/material.dart';
import '../Models/Course.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            course.thumbnail.isNotEmpty
                ? Image.network(course.thumbnail)
                : const Icon(Icons.school, size: 100),
            const SizedBox(height: 16),
            Text(course.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(course.description),
          ],
        ),
      ),
    );
  }
}