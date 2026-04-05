import 'package:flutter/material.dart';
import '../Models/Course.dart';
import '../Models/CourseModule.dart';
import '../Services/ApiService.dart';
import 'DocumentListPage.dart';
import 'AudioListPage.dart';
import 'VideoListPage.dart';
import 'QuizListPage.dart';

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
  int userId = 0;

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

      final response =
          await apiService.getCourseModules(widget.course.id, userId);

      setState(() {
        modules = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching modules: $e");
      setState(() => isLoading = false);
    }
  }

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
        return Colors.purple;
    }
  }

  // ✅ Navigate to LIST pages
  void openModule(String type) {
    switch (type) {
      case 'Document':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentListPage(
              documents: modules
                  .where((m) => m.documentPath?.isNotEmpty ?? false)
                  .toList(),
            ),
          ),
        );
        break;

      case 'Audio':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AudioListPage(
              audios: modules
                  .where((m) => m.audioLink?.isNotEmpty ?? false)
                  .toList(),
            ),
          ),
        );
        break;

      case 'Video':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoListPage(
              videos: modules
                  .where((m) => m.videoLink?.isNotEmpty ?? false)
                  .toList(),
            ),
          ),
        );
        break;

      case 'Quiz':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizListPage(
              quizzes: modules.where((m) => m.hasQuiz).toList(),
              userId: userId,
            ),
          ),
        );
        break;
    }
  }

  // ✅ SHOW MODULE TITLES
  Widget moduleCard(String type, CourseModule module) {
    return GestureDetector(
      onTap: () => openModule(type),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              getTypeColor(type).withOpacity(0.8),
              getTypeColor(type),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              module.title, // ✅ MODULE TITLE
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type, // optional
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(String type) {
    List<CourseModule> filteredModules;

    switch (type) {
      case 'Document':
        filteredModules = modules
            .where((m) => m.documentPath?.isNotEmpty ?? false)
            .toList();
        break;

      case 'Audio':
        filteredModules = modules
            .where((m) => m.audioLink?.isNotEmpty ?? false)
            .toList();
        break;

      case 'Video':
        filteredModules = modules
            .where((m) => m.videoLink?.isNotEmpty ?? false)
            .toList();
        break;

      case 'Quiz':
        filteredModules = modules.where((m) => m.hasQuiz).toList();
        break;

      default:
        filteredModules = [];
    }

    if (filteredModules.isEmpty) {
      return Center(child: Text("No $type Available"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredModules.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        return moduleCard(type, filteredModules[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title ?? "Course"),
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
            icon: const Icon(Icons.refresh),
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