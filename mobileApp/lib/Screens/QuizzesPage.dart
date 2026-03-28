import 'package:flutter/material.dart';
import '../Services/ApiService.dart';

class QuizzesPage extends StatefulWidget {
  final int moduleId;
  final int quizId;
  final String moduleTitle;
  final List<Map<String, dynamic>> questions;
  final int userId; // Pass userId from login

  const QuizzesPage({
    super.key,
    required this.moduleId,
    required this.quizId,
    required this.moduleTitle,
    required this.questions,
    required this.userId,
  });

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  final ApiService apiService = ApiService();
  final Map<int, String> selectedAnswers = {};
  bool isSubmitting = false;

  // Submit quiz answers
  Future<void> submitQuiz() async {
    if (selectedAnswers.length != widget.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final submission = widget.questions.asMap().entries.map((e) {
      final idx = e.key;
      return {
        'question_id': idx+1,
        'selected_answer': selectedAnswers[idx]!,
      };
    }).toList();

    try {
      bool success = await apiService.submitQuizResults(
        moduleId: widget.moduleId,
        quizId:widget.quizId,
        userId: widget.userId, // use userId passed from login
        answers: submission,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? "Quiz submitted successfully" : "Failed to submit quiz",
          ),
        ),
      );

      if (success) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz for ${widget.moduleTitle}"),
        backgroundColor: const Color(0xffe91e63),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: widget.questions.length,
          itemBuilder: (context, index) {
            final q = widget.questions[index];
            final options = List<String>.from(q['options']);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${index + 1}. ${q['question']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...options.map((option) => RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: selectedAnswers[index],
                          onChanged: (val) {
                            setState(() {
                              selectedAnswers[index] = val!;
                            });
                          },
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffe91e63),
          ),
          onPressed: isSubmitting ? null : submitQuiz,
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : const Text("Submit Answers"),
        ),
      ),
    );
  }
}