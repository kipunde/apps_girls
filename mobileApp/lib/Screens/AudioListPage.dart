import 'package:flutter/material.dart';
import '../Models/CourseModule.dart';
import 'AudioPlayerPage.dart';

class AudioListPage extends StatelessWidget {
  final List<CourseModule> audios;

  const AudioListPage({super.key, required this.audios});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audios"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: ListView.builder(
        itemCount: audios.length,
        itemBuilder: (context, index) {
          final audio = audios[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              title: Text(audio.title),
              trailing: ElevatedButton(
                onPressed: () {
                  if (audio.audioLink != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AudioPlayerPage(url: audio.audioLink!),
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