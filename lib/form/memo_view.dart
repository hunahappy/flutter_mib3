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
  bool isLooping = false;

  /// 🔁 반복 버튼에서만 사용하는 문단 반복 횟수
  int paragraphRepeatCount = 3;

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

  // ==========================================================
  // 🗣 사람처럼 말하기 (줄 단위 + 호흡)
  // ==========================================================
  Future<void> speakLikeHuman(String paragraph) async {
    final lines = paragraph.split('\n');

    for (final raw in lines) {
      if (!isSpeaking) return;

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

      // 문장 길이에 따른 자연스러운 쉬기
      final pause = 200 + line.length * 25;
      await Future.delayed(
        Duration(milliseconds: pause.clamp(300, 1400)),
      );
    }
  }

  /// ▶️ 한 번만 재생 (❌ 문단 반복 없음)
  Future<void> playOnce(String text) async {
    await stopTts();
    isSpeaking = true;
    isLooping = false;

    final paragraphs = _splitParagraphs(text);

    for (final paragraph in paragraphs) {
      if (!isSpeaking) break;

      await speakLikeHuman(paragraph);

      // 문단 사이 휴식
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    isSpeaking = false;
  }

  /// 🔁 반복 재생 (⭕ 문단별 반복)
  Future<void> playLoop(String text) async {
    await stopTts();
    isSpeaking = true;
    isLooping = true;

    final paragraphs = _splitParagraphs(text);

    while (isSpeaking && isLooping) {
      for (final paragraph in paragraphs) {
        if (!isSpeaking) return;

        for (int i = 0; i < paragraphRepeatCount; i++) {
          if (!isSpeaking) return;

          await speakLikeHuman(paragraph);

          if (i < paragraphRepeatCount - 1) {
            await Future.delayed(const Duration(milliseconds: 800));
          }
        }

        await Future.delayed(const Duration(milliseconds: 1200));
      }

      await Future.delayed(const Duration(milliseconds: 1500));
    }
  }

  List<String> _splitParagraphs(String text) {
    return text
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  /// ⏹ 정지
  Future<void> stopTts() async {
    isSpeaking = false;
    isLooping = false;
    await tts.stop();
  }

  @override
  void dispose() {
    stopTts();
    super.dispose();
  }

  // ==========================================================
  // 🖥 UI (텍스트 화면 꽉 차게)
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("view", style: TextStyle(fontSize: 17)),
        toolbarHeight: 37,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: "한 번 재생",
            onPressed: () => playOnce(pData["content1"]),
          ),
          IconButton(
            icon: const Icon(Icons.repeat),
            tooltip: "반복 재생",
            onPressed: () => playLoop(pData["content1"]),
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: "정지",
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
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                pData["content1"],
                style: TextStyle(
                  fontSize:
                  (pData["view_font_size"] as int).toDouble(),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}