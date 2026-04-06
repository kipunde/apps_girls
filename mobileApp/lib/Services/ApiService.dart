import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/Course.dart';
import '../Models/CourseModule.dart';
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
      print("Course list $coursesData");

      return coursesData.map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Error fetching courses: $e");
    }
  }

  /// ENROLL COURSE
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

  /// GET USER COURSES
  Future<List<Course>> getUserCourses(int userId) async {
    print("Fetching courses for user id: $userId");

    try {
      final response = await http.post(
        Uri.parse('${baseAPIPath}user_course.php'),
        body: {
          'user_id': userId.toString(),
        },
      );

      print("Status code: ${response.statusCode}");
      print("API response: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
            "Failed to load user courses: HTTP ${response.statusCode}");
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['code'] != 200) {
        throw Exception("API Error: ${jsonResponse['message']}");
      }

      final List data = jsonResponse['courses'] ?? [];

      return data.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching courses: $e");
      rethrow;
    }
  }

 Future<List<CourseModule>> getCourseModules(int courseId, int userId) async {
  print("Fetching modules for course id: $courseId, user id: $userId");

  try {
    final response = await http.post(
      Uri.parse('${baseAPIPath}get_course_modules.php'),
      body: {
        'course_id': courseId.toString(),
        'user_id': userId.toString(),
      },
    );

    print("Status code: ${response.statusCode}");
    print("API response data: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load modules: HTTP ${response.statusCode}");
    }

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (jsonResponse['code'] != 200) {
      throw Exception("API Error: ${jsonResponse['message']}");
    }

    final List data = jsonResponse['modules'] ?? [];
    return data.map((json) => CourseModule.fromJson(json)).toList();
  } catch (e) {
    print("Error fetching modules: $e");
    rethrow;
  }
}


//submit result 

/// SUBMIT QUIZ RESULTS
Future<bool> submitQuizResults({
  required int moduleId,
  required int quizId,
  required int userId,
  required List<Map<String, dynamic>> answers,
}) async {
  print("Submitting quiz for module: $moduleId, quiz id: $quizId, user: $userId, submitted anser: $answers ");

  try {
    final response = await http.post(
      Uri.parse('${baseAPIPath}quiz_answers_api.php'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "module_id": moduleId,
        "quiz_id":quizId,
        "user_id": userId,
        "answers": answers,
      }),
    );

    print("Status code: ${response.statusCode}");
    print("API response: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to submit quiz (${response.statusCode})");
    }

    final data = jsonDecode(response.body);

    return data['code'] == 200;
  } catch (e) {
    print("Submit quiz error: $e");
    return false;
  }
}
// user result 

Future<Map<String, dynamic>> getQuizResult({
  required int userId
}) async {
  final response = await http.post(
    Uri.parse('${baseAPIPath}mark_quiz.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_id": userId
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to fetch quiz result (${response.statusCode})");
  }

  final data = jsonDecode(response.body);
  print("result is $data");
  if (data['code'] != 200) {
    throw Exception("API error: ${data['message']}");
  }

  // ✅ FIX HERE
  return data; 
}


/// GET DOCUMENTS BY MODULE ID
Future<List<CourseModule>> getDocumentsByModule(int moduleId) async {
  print("Fetching documents for module id: $moduleId");

  try {
    final response = await http.post(
      Uri.parse('${baseAPIPath}get_module_documents.php'), // your PHP endpoint
      body: {
        'module_id': moduleId.toString(),
      },
    );

    print("Status code: ${response.statusCode}");
    print("API response data: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load documents: HTTP ${response.statusCode}");
    }

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (jsonResponse['code'] != 200) {
      throw Exception("API Error: ${jsonResponse['message']}");
    }

    final List data = jsonResponse['modules'] ?? [];

    // Map each JSON document to CourseModule
    return data.map((json) => CourseModule.fromJson(json)).toList();
  } catch (e) {
    print("Error fetching documents: $e");
    rethrow;
  }
}

/// GET audio BY MODULE ID
Future<List<CourseModule>> getAudiosByModule(int moduleId) async {
  print("Fetching audio for module id: $moduleId");

  try {
    final response = await http.post(
      Uri.parse('${baseAPIPath}get_module_audio.php'), // your PHP endpoint
      body: {
        'module_id': moduleId.toString(),
      },
    );

    print("Status code: ${response.statusCode}");
    print("API response data: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load audio: HTTP ${response.statusCode}");
    }

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (jsonResponse['code'] != 200) {
      throw Exception("API Error: ${jsonResponse['message']}");
    }

    final List data = jsonResponse['modules'] ?? [];

    // Map each JSON audio to CourseModule
    return data.map((json) => CourseModule.fromJson(json)).toList();
  } catch (e) {
    print("Error fetching audio: $e");
    rethrow;
  }
}

/// GET video BY MODULE ID
Future<List<CourseModule>> getVideosByModule(int moduleId) async {
  print("Fetching video for module id: $moduleId");

  try {
    final response = await http.post(
      Uri.parse('${baseAPIPath}get_module_video.php'), // your PHP endpoint
      body: {
        'module_id': moduleId.toString(),
      },
    );

    print("Status code: ${response.statusCode}");
    print("API response data: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load video: HTTP ${response.statusCode}");
    }

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (jsonResponse['code'] != 200) {
      throw Exception("API Error: ${jsonResponse['message']}");
    }

    final List data = jsonResponse['modules'] ?? [];

    // Map each JSON audio to CourseModule
    return data.map((json) => CourseModule.fromJson(json)).toList();
  } catch (e) {
    print("Error fetching video: $e");
    rethrow;
  }
}

// get list of quiz by module

 Future<List<CourseModule>> getQuizzesByModule(int moduleId) async {
  print("Fetching modules for module id: $moduleId");

  try {
    final response = await http.post(
      Uri.parse('${baseAPIPath}get_quize_byModule.php'),
      body: {
        'module_id': moduleId.toString(),
      },
    );

    print("Status code: ${response.statusCode}");
    print("API response data: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load modules: HTTP ${response.statusCode}");
    }

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (jsonResponse['code'] != 200) {
      throw Exception("API Error: ${jsonResponse['message']}");
    }

    final List data = jsonResponse['modules'] ?? [];
    return data.map((json) => CourseModule.fromJson(json)).toList();
  } catch (e) {
    print("Error fetching modules: $e");
    rethrow;
  }
}



} 