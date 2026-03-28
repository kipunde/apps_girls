import 'package:flutter/material.dart';
import '../Services/ApiService.dart';
import 'DrawerWidget.dart';

class QuizResultPage extends StatefulWidget {
  final int userId;
  final int moduleId;
  final int quizId;

  const QuizResultPage({
    super.key,
    required this.userId,
    required this.moduleId,
    required this.quizId,
  });

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  final ApiService apiService = ApiService();

  bool isLoading = true;
  List<dynamic> results = [];
  int totalScore = 0;
  int maxScore = 0;
  String status = "";

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final data = await apiService.getQuizResult(
        userId: widget.userId,
        moduleId: widget.moduleId,
        quizId: widget.quizId,
      );

      print("Result API: $data");

      setState(() {
        results = data['details'] ?? [];
        totalScore = data['total_score'] ?? 0;
        maxScore = data['max_score'] ?? 0;
        status = data['status'] ?? "FAIL";
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        title: const Text("Quiz Result"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("User ID: ${widget.userId}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  Text(
                    "Module: ${widget.moduleId} | Quiz: ${widget.quizId}",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Score: $totalScore / $maxScore",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "Result: $status ${status == "PASS" ? "✅" : "❌"}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: status == "PASS" ? Colors.green : Colors.red,
                    ),
                  ),

                  const Divider(),

                  /// QUESTIONS LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final q = results[index];

                        return Card(
                          color: q['is_correct']
                              ? Colors.green[50]
                              : Colors.red[50],
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(q['question'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Your: ${q['user_answer']}"),
                                Text("Correct: ${q['correct_answer']}"),
                              ],
                            ),
                            trailing: Icon(
                              q['is_correct']
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: q['is_correct']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}