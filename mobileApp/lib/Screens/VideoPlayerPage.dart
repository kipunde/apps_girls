import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String url;

  const VideoPlayerPage({super.key, required this.url});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController controller;
  bool isInitialized = false;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool videoAvailable = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      String fullUrl = widget.url;
      if (!fullUrl.startsWith('http')) {
        fullUrl =
            "https://prasperascons.com/app/api/uploads/modules/$fullUrl";
      }

      controller = VideoPlayerController.network(fullUrl);
      await controller.initialize();

      // If the duration is zero, file might be invalid
      if (controller.value.duration == Duration.zero) {
        setState(() => videoAvailable = false);
        return;
      }

      duration = controller.value.duration;
      setState(() {
        isInitialized = true;
        isPlaying = true;
        videoAvailable = true;
      });

      controller.addListener(() {
        setState(() {
          position = controller.value.position;
          isPlaying = controller.value.isPlaying;
        });
      });

      controller.play();
    } catch (e) {
      debugPrint("Error loading video: $e");
      setState(() {
        isInitialized = false;
        videoAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void togglePlay() {
    if (!isInitialized) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
  }

  void seekVideo(Duration newPosition) {
    if (isInitialized) {
      controller.seekTo(newPosition);
    }
  }

  String formatTime(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final videoHeight = screenWidth * 9 / 16; // 16:9 aspect ratio

    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: videoAvailable
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: videoHeight,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isInitialized
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: VideoPlayer(controller),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    iconSize: 60,
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                      color: Colors.pink,
                    ),
                    onPressed: togglePlay,
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    value: position.inSeconds
                        .toDouble()
                        .clamp(0, duration.inSeconds.toDouble()),
                    onChanged: (value) {
                      seekVideo(Duration(seconds: value.toInt()));
                    },
                    activeColor: Colors.pink,
                    inactiveColor: Colors.grey.shade300,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(position)),
                      Text(formatTime(duration)),
                    ],
                  ),
                ],
              )
            : const Center(
                child: Text(
                  "Video not available",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
      ),
    );
  }
}