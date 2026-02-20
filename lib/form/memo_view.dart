import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MmemoView extends StatefulWidget {
  const MmemoView({super.key});

  @override
  State<MmemoView> createState() => _MmemoViewState();
}

class _MmemoViewState extends State<MmemoView> {
  late final Map<String, dynamic> pData;
  final FlutterTts tts = FlutterTts();
  bool isLooping = false;

  @override
  void initState() {
    super.initState();
    pData = Map<String, dynamic>.from(Get.arguments);
    initTts(pData["content1"]);
  }

  Future<void> initTts(String text) async {
    await tts.setLanguage("ko-KR");
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.05);
    await tts.setVolume(1.0);

    if (Platform.isMacOS) {
      final voices = await tts.getVoices;
      final koVoice = voices.firstWhere(
            (v) =>
        v['locale'] == 'ko-KR' &&
            v['name'].toString().toLowerCase().contains('yuna'),
        orElse: () => null,
      );

      if (koVoice != null) {
        await tts.setVoice({
          "name": koVoice['name'],
          "locale": koVoice['locale'],
        });
      }
    }

    if (Platform.isAndroid) {
      await tts.setEngine("com.google.android.tts");
    }

    // 🔁 반복 재생
    tts.setCompletionHandler(() {
      if (isLooping) {
        tts.speak(text);
      }
    });
  }

  Future<void> startTts(String text) async {
    isLooping = true;
    await tts.stop();
    await tts.speak(text);
  }

  Future<void> stopTts() async {
    isLooping = false;
    await tts.stop();
  }

  @override
  void dispose() {
    stopTts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "view",
          style: TextStyle(fontSize: 17),
        ),
        toolbarHeight: 37,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => startTts(pData["content1"]),
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: stopTts,
          ),
          IconButton(
            icon: const Icon(Icons.file_copy),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: pData["content1"]),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onPanEnd: (details) {
          stopTts();
          Get.back(result: details.velocity.pixelsPerSecond.dx);
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Card(
            elevation: 7,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Text(
                        pData["content1"],
                        style: TextStyle(
                          fontSize:
                          (pData["view_font_size"] as int).toDouble(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}