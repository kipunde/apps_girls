import 'package:flutter/material.dart';
import '../Models/CourseModule.dart';
import 'DocumentListPage.dart';
import 'AudioListPage.dart';
import 'VideoListPage.dart';
import 'QuizListPage.dart';

class AllContentPage extends StatelessWidget {
  final List<CourseModule> modules;
  final int userId;

  const AllContentPage({
    super.key,
    required this.modules,
    required this.userId,
  });

  Color getTypeColor(String type) {
    switch (type) {
      case 'Document':
        return Colors.blue;
      case 'Audio':
        return Colors.green;
      case 'Video':
        return Colors.pink;
      case 'Quiz':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String getType(CourseModule m) {
    if (m.documentPath != null && m.documentPath!.isNotEmpty) return 'Document';
    if (m.audioLink != null && m.audioLink!.isNotEmpty) return 'Audio';
    if (m.videoLink != null && m.videoLink!.isNotEmpty) return 'Video';
    if (m.hasQuiz) return 'Quiz';
    return 'Unknown';
  }

  void openTypeList(BuildContext context, String type) {
    switch (type) {
      case 'Document':
        final docs = modules.where((m) => m.documentPath != null && m.documentPath!.isNotEmpty).toList();
        if (docs.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DocumentListPage(documents: docs),
            ),
          );
        }
        break;

      case 'Audio':
        final audios = modules.where((m) => m.audioLink != null && m.audioLink!.isNotEmpty).toList();
        if (audios.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AudioListPage(audios: audios),
            ),
          );
        }
        break;

      case 'Video':
        final videos = modules.where((m) => m.videoLink != null && m.videoLink!.isNotEmpty).toList();
        if (videos.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoListPage(videos: videos),
            ),
          );
        }
        break;

      case 'Quiz':
        final quizzes = modules.where((m) => m.hasQuiz).toList();
        if (quizzes.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizListPage(quizzes: quizzes, userId: userId),
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get unique types available in this course
    final types = <String>{};
    for (var m in modules) {
      final t = getType(m);
      if (t != 'Unknown') types.add(t);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Course Content"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: ListView.builder(
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types.elementAt(index);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getTypeColor(type),
                child: Text(type[0]),
              ),
              title: Text(type),
              trailing: ElevatedButton(
                onPressed: () => openTypeList(context, type),
                child: const Text("View"),
              ),
            ),
          );
        },
      ),
    );
  }
}