import 'dart:async';
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

  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    pData = Map<String, dynamic>.from(Get.arguments);
    initTts();
  }

  Future<void> initTts() async {
    await tts.setLanguage("ko-KR");
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.05);
    await tts.setVolume(1.0);

    if (Platform.isMacOS) {
      final voices = await tts.getVoices;
      final koVoice = voices.cast<Map>().firstWhere(
            (v) =>
        v['locale'] == 'ko-KR' &&
            v['name'].toString().toLowerCase().contains('yuna'),
        orElse: () => {},
      );

      if (koVoice.isNotEmpty) {
        await tts.setVoice({
          "name": koVoice['name'],
          "locale": koVoice['locale'],
        });
      }
    }

    if (Platform.isAndroid) {
      await tts.setEngine("com.google.android.tts");
    }
  }

  /// 🗣 사람처럼 말하기
  Future<void> speakLikeHuman(String text) async {
    isSpeaking = true;

    final lines = text.split('\n');

    for (final raw in lines) {
      if (!isSpeaking) break;

      final line = raw.trim();
      if (line.isEmpty) continue;

      final completer = Completer<void>();

      tts.setCompletionHandler(() {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      await tts.speak(line);
      await completer.future;

      // 문장 길이에 따른 사람 호흡
      final pause = 200 + line.length * 25;
      await Future.delayed(
        Duration(milliseconds: pause.clamp(300, 1400)),
      );
    }
  }

  Future<void> startTts(String text) async {
    await stopTts(); // 중복 방지
    isSpeaking = true;
    speakLikeHuman(text);
  }

  Future<void> stopTts() async {
    isSpeaking = false;
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