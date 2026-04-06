import 'package:flutter/material.dart';
import '../Models/CourseModule.dart';
import '../Services/ApiService.dart';
import 'VideoPlayerPage.dart';

class VideoListPage extends StatefulWidget {
  final int moduleId;

  const VideoListPage({super.key, required this.moduleId});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<CourseModule> videos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    setState(() => isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.getVideosByModule(widget.moduleId);

      print("Video data: $response");

      setState(() {
        videos = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching videos: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Videos"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : videos.isEmpty
              ? const Center(
                  child: Text("No videos available for this module"),
                )
              : ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];

                    // Safe values
                    final title =
                        video.title.isNotEmpty ? video.title : "Untitled Video";
                    final link = video.videoLink ?? "";

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(link),
                        trailing: ElevatedButton(
                          onPressed: link.isNotEmpty
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          VideoPlayerPage(url: link),
                                    ),
                                  );
                                }
                              : null,
                          child: const Text("Play"),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}