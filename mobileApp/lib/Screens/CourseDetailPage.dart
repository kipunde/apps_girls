import 'package:flutter/material.dart';
import '../Models/Course.dart';
import '../Models/CourseModule.dart';
import '../Services/ApiService.dart';
import 'QuizzesPage.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage>
    with SingleTickerProviderStateMixin {
  List<CourseModule> modules = [];
  bool isLoading = true;
  late TabController _tabController;
  CourseModule? selectedModule;

  int userId = 0; // store current user ID here

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchModules();
  }

  Future<void> fetchModules() async {
    try {
      final apiService = ApiService();
      final user = await apiService.authService.getUserAccessDetails();
      userId = int.tryParse(user?.id ?? '0') ?? 0;

      final response = await apiService.getCourseModules(widget.course.id, userId);

      setState(() {
        modules = response;
        isLoading = false;
        if (modules.isNotEmpty) selectedModule = modules.first;
      });
    } catch (e) {
      print("Error fetching modules: $e");
      setState(() => isLoading = false);
    }
  }

  Color getTypeColor(String type) {
    switch (type) {
      case 'PDF':
        return Colors.blue;
      case 'MP3':
        return Colors.green;
      case 'MP4':
        return Colors.pink;
      case 'PPT':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  Widget moduleCard(String type, CourseModule module, String action,
      {bool isQuiz = false}) {
    final isSelected = selectedModule == module;

    return GestureDetector(
      onTap: () {
        if (module.isUnlocked || isQuiz) {
          setState(() => selectedModule = module);

          if (isQuiz && module.hasQuiz) {
            // Navigate to Quiz page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizzesPage(
                  moduleId: module.moduleId,
                  quizId:module.quizId,
                  moduleTitle: module.title,
                  questions: List<Map<String, dynamic>>.from(module.questions ?? []),
                  userId: userId, // ✅ pass userId
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Finish previous module first")),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [Colors.pinkAccent, Colors.pink]
                : [
                    getTypeColor(type).withOpacity(0.8),
                    getTypeColor(type),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isQuiz ? "QUIZ" : type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              module.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: module.isUnlocked || isQuiz ? Colors.white : Colors.white38,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            if (!isQuiz)
              Text(
                action,
                style: TextStyle(
                  color: module.isUnlocked ? Colors.white70 : Colors.white30,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(String type) {
    if (modules.isEmpty) {
      return const Center(
        child: Text(
          "No Module Content Available",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    List<CourseModule> filteredModules;

    if (type == 'Quiz') {
      filteredModules = modules.where((m) => m.hasQuiz).toList();
    } else {
      filteredModules = modules.where((module) {
        switch (type) {
          case 'Document':
            return module.documentPath != null && module.documentPath!.isNotEmpty;
          case 'Audio':
            return module.audioLink != null && module.audioLink!.isNotEmpty;
          case 'Video':
            return module.videoLink != null && module.videoLink!.isNotEmpty;
          default:
            return false;
        }
      }).toList();
    }

    if (filteredModules.isEmpty) {
      return Center(child: Text("No $type Available"));
    }

    int crossAxis = filteredModules.length == 1 ? 1 : 2;

    return RefreshIndicator(
      onRefresh: fetchModules,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredModules.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxis,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final module = filteredModules[index];

              String action = type == 'Video'
                  ? 'Watch'
                  : type == 'Audio'
                      ? 'Listen'
                      : 'View';

              String moduleType = type == 'Document'
                  ? 'PDF'
                  : type == 'Audio'
                      ? 'MP3'
                      : 'MP4';

              return moduleCard(moduleType, module, action, isQuiz: type == 'Quiz');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedModule?.title ?? "Course",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xffe91e63),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Document'),
            Tab(text: 'Audio'),
            Tab(text: 'Video'),
            Tab(text: 'Quiz'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => isLoading = true);
              fetchModules();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildTabContent('Document'),
                buildTabContent('Audio'),
                buildTabContent('Video'),
                buildTabContent('Quiz'),
              ],
            ),
    );
  }
}