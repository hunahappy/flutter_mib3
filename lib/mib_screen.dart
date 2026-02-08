import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'form/hal.dart';
import 'form/ilgi.dart';
import 'form/memo.dart';
import 'form/progress.dart';

class MibScreen extends StatefulWidget {
  const MibScreen({super.key});

  @override
  _MibScreenState createState() => _MibScreenState();
}

class _MibScreenState extends State<MibScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const _DesktopScrollBehavior(),
      child: PageView(
        controller: _pageController,
        children: const [
          Mmemo(),
          Mhal(),
          Mprogress(),
          Milgi(),
        ],
      ),
    );
  }
}

/// 데스크톱에서 드래그 지원 ScrollBehavior
class _DesktopScrollBehavior extends ScrollBehavior {
  const _DesktopScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.mouse, // 마우스
    PointerDeviceKind.touch, // 터치패드
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
  };
}