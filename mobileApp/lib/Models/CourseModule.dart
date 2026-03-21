class CourseModule {
  final int id;
  final String courseName;
  final String title;
  final String shortDetail;
  final String? documentPath;
  final String? audioLink;
  final String? videoLink;
  final String moduleStatus;      // 'enabled' or 'disabled'
  final String assignedAt;        // assigned datetime as string

  CourseModule({
    required this.id,
    required this.courseName,
    required this.title,
    required this.shortDetail,
    this.documentPath,
    this.audioLink,
    this.videoLink,
    required this.moduleStatus,
    required this.assignedAt,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
  return CourseModule(
    id: json['module_id'] ?? 0,           // fallback to 0 if null
    courseName: json['course_name'] ?? '',
    title: json['module_title'] ?? '',    // fallback if null
    shortDetail: json['short_detail'] ?? '',
    documentPath: json['document_path'],
    audioLink: json['audio_link'],
    videoLink: json['video_link'],
    moduleStatus: json['module_status'] ?? 'disabled',
    assignedAt: json['assigned_at'] ?? '',
  );
}

  // Convenience getter
  bool get isUnlocked => moduleStatus == 'enabled';
}