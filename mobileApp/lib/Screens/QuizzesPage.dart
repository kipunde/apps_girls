import 'package:flutter/material.dart';

class QuizzesPage extends StatefulWidget {
  final int moduleId;
  final String moduleTitle;
  final List<Map<String, dynamic>> questions;

  const QuizzesPage({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
    required this.questions,
  });

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  // Stores user-selected answers: index = question index, value = selected option
  Map<int, String> selectedAnswers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleTitle),
        backgroundColor: const Color(0xffe91e63),
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
          child: const Text("Submit Answers"),
          onPressed: () {
            if (selectedAnswers.length != widget.questions.length) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please answer all questions")),
              );
              return;
            }

            // Prepare submission payload
            final submission = widget.questions.asMap().entries.map((e) {
              final idx = e.key;
              final question = e.value;
              return {
                'question': question['question'],
                'selected_answer': selectedAnswers[idx],
                'correct_answer': question['correct_answer'],
                'score': question['score'],
              };
            }).toList();

            // TODO: send 'submission' to your API
            print("Submitted answers: $submission");

            // Feedback
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Answers submitted!")),
            );
          },
        ),
      ),
    );
  }
}