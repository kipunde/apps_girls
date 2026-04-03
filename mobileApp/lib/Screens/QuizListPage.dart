import 'package:flutter/material.dart';
import '../Models/CourseModule.dart';
import 'QuizzesPage.dart';

class QuizListPage extends StatelessWidget {
  final List<CourseModule> quizzes;
  final int userId;

  const QuizListPage({super.key, required this.quizzes, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quizzes"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              title: Text(quiz.title),
              trailing: ElevatedButton(
                onPressed: () {
                  if (quiz.hasQuiz) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizzesPage(
                          moduleId: quiz.moduleId,
                          quizId: quiz.quizId,
                          moduleTitle: quiz.title,
                          questions:
                              List<Map<String, dynamic>>.from(quiz.questions ?? []),
                          userId: userId,
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Start"),
              ),
            ),
          );
        },
      ),
    );
  }
}