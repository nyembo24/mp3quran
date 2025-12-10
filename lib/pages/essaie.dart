import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Audio Linux - Audioplayers")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => player.play(AssetSource("mp3/001.mp3")),
              child: Text("Lire"),
            ),
            ElevatedButton(
              onPressed: () => player.pause(),
              child: Text("Pause"),
            ),
            ElevatedButton(
              onPressed: () => player.stop(),
              child: Text("Stop"),
            ),
          ],
        ),
      ),
    );
  }
}
