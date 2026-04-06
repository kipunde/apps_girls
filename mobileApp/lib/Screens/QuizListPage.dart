import 'package:flutter/material.dart';
import '../Models/CourseModule.dart';
import '../Services/ApiService.dart';
import 'QuizzesPage.dart';

class QuizListPage extends StatefulWidget {
  final int moduleId;
  final int userId;

  const QuizListPage({super.key, required this.moduleId, required this.userId});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  List<CourseModule> quizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    setState(() => isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.getQuizzesByModule(widget.moduleId);

      // Debug: print each quiz title
      for (var q in response) {
        print("Quiz: ${q.title}, quizId: ${q.quizId}, hasQuiz: ${q.hasQuiz}");
      }

      setState(() {
        quizzes = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching quizzes: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quizzes"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizzes.isEmpty
              ? const Center(
                  child: Text("No quizzes available for this module"),
                )
              : ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];

                    // Null-safe defaults
                    final title = quiz.title.isNotEmpty ? quiz.title : "Untitled Quiz";

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text(title),
                        trailing: ElevatedButton(
                          onPressed: quiz.hasQuiz
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuizzesPage(
                                        moduleId: quiz.moduleId,
                                        quizId: quiz.quizId,
                                        moduleTitle: quiz.title,
                                        questions: List<Map<String, dynamic>>.from(
                                            quiz.questions ?? []),
                                        userId: widget.userId,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Text(quiz.hasQuiz ? "Start" : "Locked"),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}