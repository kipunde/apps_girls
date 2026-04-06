import 'package:flutter/material.dart';
import '../Models/CourseModule.dart';
import '../Services/ApiService.dart';
import 'AudioPlayerPage.dart';

class AudioListPage extends StatefulWidget {
  final int moduleId;

  const AudioListPage({super.key, required this.moduleId});

  @override
  State<AudioListPage> createState() => _AudioListPageState();
}

class _AudioListPageState extends State<AudioListPage> {
  List<CourseModule> audios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAudios();
  }

  Future<void> fetchAudios() async {
    setState(() => isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.getAudiosByModule(widget.moduleId);

      // Debug print the raw API response
      print("Audio data: $response");

      setState(() {
        audios = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching audios: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audios"),
        backgroundColor: const Color(0xffe91e63),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : audios.isEmpty
              ? const Center(
                  child: Text("No audios available for this module"),
                )
              : ListView.builder(
                  itemCount: audios.length,
                  itemBuilder: (context, index) {
                    final audio = audios[index];

                    // Use null-safe defaults
                    final title = audio.title.isNotEmpty ? audio.title : "Untitled Audio";
                    final link = audio.audioLink ?? "kuku";

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
                                      builder: (_) => AudioPlayerPage(url: link),
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