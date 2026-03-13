import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/Course.dart';
import 'AuthService.dart';
import 'ServiceConstant.dart';

class ApiService {
  final AuthService authService = AuthService();

  /// GET COURSES (SESSION BASED LOGIN)
  Future<List<Course>> getCourses() async {
    try {
      // Check if user is logged in
      final user = await authService.getUserAccessDetails();

      if (user == null) {
        throw Exception("User not logged in");
      }

      final response = await http.get(
        Uri.parse('${baseAPIPath}get_courses.php'),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 401) {
         print("Error: ${response.statusCode} - ${response.body}");
        throw Exception("Session expired. Please login again.");
      }

      if (response.statusCode != 200) {
        throw Exception("Failed to load courses (${response.statusCode})");
      }

      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      final List coursesData = jsonData['courses'] ?? [];

      return coursesData.map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Error fetching courses: $e");
    }
  }

  // Example method to enroll course
  Future<bool> enrollCourse(int courseId, int userId) async {
  print("Course and user are: $courseId , $userId");

  try {
    final response = await http.post(
      Uri.parse('${baseAPIPath}enroll_course.php'),
      body: {
        'user_id': userId.toString(),
        'course_id': courseId.toString(),
      },
    );

    print("Status code: ${response.statusCode}");
    print("API response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['code'] == 200;
    }

    return false;
  } catch (e) {
    print("Enroll error: $e");
    return false;
  }
}
  
  }