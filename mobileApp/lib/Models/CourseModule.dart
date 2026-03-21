class CourseModule {
  final int id;
  final String courseName;
  final String title;
  final String shortDetail;
  final String? documentPath;
  final String? audioLink;
  final String? videoLink;

  CourseModule({
    required this.id,
    required this.courseName,
    required this.title,
    required this.shortDetail,
    this.documentPath,
    this.audioLink,
    this.videoLink,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'],
      courseName: json['course_name'],
      title: json['title'],
      shortDetail: json['short_detail'] ?? '',
      documentPath: json['document_path'],
      audioLink: json['audio_link'],
      videoLink: json['video_link'],
    );
  }
}