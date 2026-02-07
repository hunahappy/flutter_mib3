import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../main.dart';

class MmemoView extends StatelessWidget {
  const MmemoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic p_data = Get.arguments;

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "view",
            style: TextStyle(fontSize: 17),
          ),
          toolbarHeight: 37,
          actions: [
            IconButton(
                icon: const Icon(Icons.file_copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: p_data["content1"]));
                }),
          ]),
      body: GestureDetector(
        onPanEnd: (details){
          Get.back(result: details.velocity.pixelsPerSecond.dx);
        },
        child: Card(
            elevation: 7,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          child: Text(p_data["content1"],
                              style: TextStyle(
                                  fontSize: p_data["view_font_size"] + 0.0)),
                        ))),
              ],
            )),
      ),
    );
  }
}
