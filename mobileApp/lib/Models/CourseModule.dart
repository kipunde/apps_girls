import 'dart:convert';

class CourseModule {
  final int id;
  final moduleId;
  final quizId;
  final String courseName;
  final String title;
  final String shortDetail;
  final String? documentPath;
  final String? audioLink;
  final String? videoLink;
  final String moduleStatus;
  final String assignedAt; 
  final bool hasQuiz;
  final String? quizName;
  final List<Map<String, dynamic>>? questions;

  CourseModule({
    required this.id,
    required this.quizId,
    required this.moduleId,
    required this.courseName,
    required this.title,
    required this.shortDetail,
    this.documentPath,
    this.audioLink,
    this.videoLink,
    required this.moduleStatus,
    required this.assignedAt,
    this.hasQuiz = false,
    this.quizName,
    this.questions,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
  List<Map<String, dynamic>>? parsedQuestions;

  // Parse questions if available
  if (json['questions'] != null) {
    try {
      parsedQuestions = List<Map<String, dynamic>>.from(
        (jsonDecode(json['questions']) as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      parsedQuestions = null; // fallback if JSON parsing fails
      print("Error parsing questions: $e");
    }
  }

  int parsedQuizId = json['quiz_id'] != null
      ? int.tryParse(json['quiz_id'].toString()) ?? 0
      : 0;

  return CourseModule(
    id: json['module_id'] ?? json['id'] ?? 0,
    moduleId: json['module_id'] ?? 0,
    quizId: parsedQuizId,
    courseName: json['course_name'] ?? '',
    title: json['module_title'] ?? '',
    shortDetail: json['short_detail'] ?? '',
    documentPath: json['document_path'],
    audioLink: json['audio_link'],
    videoLink: json['video_link'],
    moduleStatus: json['module_status'] ?? 'disabled',
    assignedAt: json['assigned_at'] ?? '',
    hasQuiz: parsedQuizId > 0,          // ✅ compute from quiz_id
    quizName: json['quize_name'],
    questions: parsedQuestions,
  );
}
  // Convenience getter
  bool get isUnlocked => moduleStatus == 'enabled';
}