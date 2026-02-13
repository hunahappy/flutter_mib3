import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../comm/mib3_controller.dart';
import 'ilgi_add.dart';

class Milgi extends StatefulWidget {
  const Milgi({super.key});

  @override
  State<Milgi> createState() => _MilgiState();
}

class _MilgiState extends State<Milgi> {
  final controller = Get.find<Mib3Controller>();
  final textSearch = TextEditingController();

  late List<Map<String, dynamic>> rows;
  String _title =
      "diary";
  String _wan_flag = "진행";
  bool _sort_flag = true;

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        extendBodyBehindAppBar: false, // ← 이 줄 추가
        appBar: AppBar(
          // ✅ 다크일 때는 검은색
            backgroundColor: isDark ? Colors.black : null,

            // ✅ 라이트/시스템일 때만 그라데이션
            flexibleSpace: isDark
                ? null
                : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFC3A0), Color(0xFFFFAFBD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).padding.top,
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
              ],
            ),
        toolbarHeight: 37,
        title: Text(_title, style: const TextStyle(fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: SizedBox(
                      width: 500.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            autofocus: true,
                            controller: textSearch,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  setState(() {});
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.content_paste_off),
            onPressed: () {
              setState(() {
                _wan_flag = _wan_flag == "진행" ? "완료" : "진행";
                _title = _wan_flag == "진행" ? "diary" : "diary (finish)";
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            onPressed: () {
              _sort_flag = !_sort_flag;
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              var filtered = controller.items
                  .where((item) => item.tb == "일기" && item.wan == _wan_flag)
                  .toList();

              if (textSearch.text.isNotEmpty) {
                filtered = filtered
                    .where(
                      (item) => jsonDecode(item.content)['content1']
                      .toString()
                      .toLowerCase()
                      .contains(textSearch.text.toLowerCase()),
                )
                    .toList();
              }

              if (_sort_flag) {
                filtered.sort(
                      (a, b) => jsonDecode(
                    b.content,
                  )['s_date'].compareTo(jsonDecode(a.content)['s_date']),
                );
              } else {
                filtered.sort(
                      (a, b) => jsonDecode(
                    a.content,
                  )['content1'].compareTo(jsonDecode(b.content)['content1']),
                );
              }

              return ListView.builder(
                controller: _controller,
                padding: const EdgeInsets.all(10),
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final item = filtered[index];
                  return Card(
                    elevation: 7,
                    child: ListTile(
                      dense: true,
                      title: Transform.translate(
                        offset: const Offset(0, 0),
                        child: Text(
                          "  ${jsonDecode(item.content)["s_date"].toString()}(${get_date_yo(jsonDecode(item.content)["s_date"])})\n${jsonDecode(item.content)["content1"]}",
                          maxLines: controller.setting_line_size,
                          overflow: TextOverflow.fade,
                          style:
                          TextStyle(fontSize: controller.setting_font_size + 0.0),
                        ),
                      ),
                      onTap: () async {
                        controller.temp_data = <String, dynamic>{
                          "id": item.id,
                          "wan": item.wan,
                          "s_date": jsonDecode(item.content)['s_date'],
                          "content1": jsonDecode(item.content)['content1'],
                          "content2": jsonDecode(item.content)['content2'],
                        };
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const MilgiAdd();
                          },
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          controller.temp_data = <String, dynamic>{
            "id": "new",
            "wan": "진행",
            "s_date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
            "content1": "",
            "content2": "",
          };
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MilgiAdd();
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
