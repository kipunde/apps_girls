import 'package:flutter/material.dart';
import '../Models/CourseModule.dart';
import 'VideoPlayerPage.dart';

class VideoListPage extends StatelessWidget {
  final List<CourseModule> videos;

  const VideoListPage({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Videos"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              title: Text(video.title),
              trailing: ElevatedButton(
                onPressed: () {
                  if (video.videoLink != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(url: video.videoLink!),
                      ),
                    );
                  }
                },
                child: const Text("Play"),
              ),
            ),
          );
        },
      ),
    );
  }
}