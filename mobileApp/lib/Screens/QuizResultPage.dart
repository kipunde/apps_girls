import 'package:flutter/material.dart';
import '../Services/ApiService.dart';
import 'DrawerWidget.dart';

class QuizResultPage extends StatefulWidget {
  final int userId;

  const QuizResultPage({
    super.key,
    required this.userId,
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
  double percentage = 0;

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final data = await apiService.getQuizResult(
        userId: widget.userId,
      );

      setState(() {
        results = data['details'] ?? [];
        totalScore = data['total_score'] ?? 0;
        maxScore = data['max_score'] ?? 0;
        status = data['status'] ?? "FAIL";
        percentage = maxScore > 0 ? (totalScore / maxScore) * 100 : 0;
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
                  /// HEADER INFO
                  Text(
                    "Quiz Results",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  /// SCORE
                  Text(
                    "Score: $totalScore / $maxScore",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "Percentage: ${percentage.toStringAsFixed(1)}%",
                    style: const TextStyle(fontSize: 14),
                  ),

                  Text(
                    "Result: $status ${status == "PASS" ? "✅" : ""}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: status == "PASS" ? Colors.green : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// PROGRESS BAR
                  LinearProgressIndicator(
                    value: maxScore > 0 ? totalScore / maxScore : 0,
                    backgroundColor: Colors.grey[300],
                    color: status == "PASS" ? Colors.green : Colors.red,
                  ),

                  const Divider(height: 20, thickness: 2),

                  /// QUESTIONS LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final q = results[index];
                        bool correct = q['is_correct'] == true;

                        return Card(
                          color: correct
                              ? Colors.green[50]
                              : Colors.red[50],
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            /// QUESTION NUMBER BADGE
                            leading: CircleAvatar(
                              backgroundColor:
                                  correct ? Colors.green : Colors.red,
                              child: Text(
                                "${q['question_id'] ?? index + 1}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),

                            /// QUESTION TEXT
                            title: Text(
                              q['question'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            /// ANSWERS
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Your: ${q['user_answer'] ?? '-'}"),
                                Text("Correct: ${q['correct_answer'] ?? '-'}"),
                              ],
                            ),

                            /// ICON
                            trailing: Icon(
                              correct
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: correct ? Colors.green : Colors.red,
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