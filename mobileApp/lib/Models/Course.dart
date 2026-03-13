class Course {
  final int id;
  final String title;
  final String description;
  final String thumbnail;
  final String status;
  final bool isEnrolled; // NEW FIELD

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.status,
    this.isEnrolled = false, // default false
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      status: json['status'] ?? '',
      isEnrolled: json['user_id'] != null && json['user_id'].toString().isNotEmpty,
    );
  }
}