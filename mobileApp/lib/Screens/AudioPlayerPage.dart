import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerPage extends StatefulWidget {
  final String url;

  const AudioPlayerPage({super.key, required this.url});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  bool audioAvailable = true;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setAudioSource();

    // Listen to audio duration
    player.onDurationChanged.listen((d) {
      setState(() => duration = d);
      if (d == Duration.zero) {
        setState(() => audioAvailable = false);
      }
    });

    // Listen to audio position
    player.onPositionChanged.listen((p) {
      setState(() => position = p);
    });

    // Listen for completion
    player.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  Future<void> _setAudioSource() async {
    try {
      String fullUrl = widget.url;
      if (!fullUrl.startsWith('http')) {
        fullUrl =
            "https://prasperascons.com/app/api/uploads/modules/$fullUrl";
      }
      await player.setSourceUrl(fullUrl);
      setState(() => audioAvailable = true);
    } catch (e) {
      debugPrint("Error loading audio: $e");
      setState(() => audioAvailable = false);
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void togglePlay() async {
    if (!audioAvailable) return;
    try {
      if (isPlaying) {
        await player.pause();
      } else {
        await player.resume();
      }
      setState(() => isPlaying = !isPlaying);
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void seekAudio(Duration newPosition) {
    if (!audioAvailable) return;
    player.seek(newPosition);
  }

  String formatTime(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Player"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: audioAvailable
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 100,
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                      color: Colors.pink,
                    ),
                    onPressed: togglePlay,
                  ),
                  const SizedBox(height: 30),
                  Slider(
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    value: position.inSeconds
                        .toDouble()
                        .clamp(0, duration.inSeconds.toDouble()),
                    onChanged: (value) {
                      seekAudio(Duration(seconds: value.toInt()));
                    },
                    activeColor: Colors.pink,
                    inactiveColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
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
                  "Audio not available",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
      ),
    );
  }
}