import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

import '../Models/Course.dart';
import '../Models/CourseModule.dart';
import '../Services/ApiService.dart';

import 'QuizzesPage.dart';
import 'AllContentPage.dart';

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
        if (modules.isNotEmpty) selectedModule = modules.first;
      });
    } catch (e) {
      debugPrint("Error fetching modules: $e");
      setState(() => isLoading = false);
    }
  }

  Color getTypeColor(String type) {
    switch (type) {
      case 'PDF':
      case 'Document':
        return Colors.blue;
      case 'MP3':
      case 'Audio':
        return Colors.green;
      case 'MP4':
      case 'Video':
        return Colors.pink;
      case 'PPT':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  void openModule(CourseModule module, String type) {
    if (!module.isUnlocked && type != 'Quiz') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Finish previous module first")),
      );
      return;
    }

    switch (type) {
      case 'Quiz':
        if (module.hasQuiz) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizzesPage(
                moduleId: module.moduleId,
                quizId: module.quizId,
                moduleTitle: module.title,
                questions: List<Map<String, dynamic>>.from(module.questions ?? []),
                userId: userId,
              ),
            ),
          );
        }
        break;

      case 'Document':
        if (module.documentPath?.isNotEmpty ?? false) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DocumentViewerPage(url: module.documentPath!),
            ),
          );
        }
        break;

      case 'Audio':
        if (module.audioLink?.isNotEmpty ?? false) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AudioPlayerPage(url: module.audioLink!),
            ),
          );
        }
        break;

      case 'Video':
        if (module.videoLink?.isNotEmpty ?? false) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerPage(url: module.videoLink!),
            ),
          );
        }
        break;
    }
  }

  Widget moduleCard(String type, CourseModule module) {
    final isSelected = selectedModule == module;

    return GestureDetector(
      onTap: () {
        setState(() => selectedModule = module);
        openModule(module, type);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [Colors.pinkAccent, Colors.pink]
                : [getTypeColor(type).withOpacity(0.8), getTypeColor(type)],
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
                type,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              module.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: module.isUnlocked ? Colors.white : Colors.white38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(String type) {
    List<CourseModule> filteredModules;

    if (type == 'Quiz') {
      filteredModules = modules.where((m) => m.hasQuiz).toList();
    } else {
      filteredModules = modules.where((m) {
        switch (type) {
          case 'Document':
            return m.documentPath?.isNotEmpty ?? false;
          case 'Audio':
            return m.audioLink?.isNotEmpty ?? false;
          case 'Video':
            return m.videoLink?.isNotEmpty ?? false;
          default:
            return false;
        }
      }).toList();
    }

    if (filteredModules.isEmpty) {
      return Center(child: Text("No $type Available"));
    }

    return RefreshIndicator(
      onRefresh: fetchModules,
      child: GridView.builder(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedModule?.title ?? "Course"),
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
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllContentPage(modules: modules, userId: userId),
                ),
              );
            },
          ),
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

// --------------------- AUDIO PLAYER ---------------------
class AudioPlayerPage extends StatefulWidget {
  final String url;
  const AudioPlayerPage({super.key, required this.url});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    player.setSourceUrl(widget.url);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void togglePlay() async {
    if (isPlaying) {
      await player.pause();
    } else {
      await player.resume();
    }
    setState(() => isPlaying = !isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Player"), backgroundColor: const Color(0xffe91e63)),
      body: Center(
        child: IconButton(
          iconSize: 80,
          icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.pink),
          onPressed: togglePlay,
        ),
      ),
    );
  }
}

// --------------------- VIDEO PLAYER ---------------------
class VideoPlayerPage extends StatefulWidget {
  final String url;
  const VideoPlayerPage({super.key, required this.url});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) => setState(() {}))
      ..play();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void togglePlay() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player"), backgroundColor: const Color(0xffe91e63)),
      body: controller.value.isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
                IconButton(
                  iconSize: 70,
                  icon: Icon(
                    controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.pink,
                  ),
                  onPressed: togglePlay,
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

// --------------------- DOCUMENT VIEWER ---------------------
class DocumentViewerPage extends StatelessWidget {
  final String url;
  const DocumentViewerPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    // For PDF, show PDF viewer; for others, open link externally
    if (url.endsWith(".pdf")) {
      return Scaffold(
        appBar: AppBar(title: const Text("PDF Viewer"), backgroundColor: const Color(0xffe91e63)),
        body: SfPdfViewer.network(url),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text("Document Viewer"), backgroundColor: const Color(0xffe91e63)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Cannot preview this document type.\nPlease open it in another app.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }
  }
}