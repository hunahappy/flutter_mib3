
import 'package:flutter/material.dart';

import 'form/hal.dart';
import 'form/memo.dart';
import 'form/progress.dart';

class MibScreen extends StatelessWidget {
  const MibScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: const <Widget>[
        Mmemo(),
        Mhal(),
        Mprogress()
      ],
    );
  }
}
