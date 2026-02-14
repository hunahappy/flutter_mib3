import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mib3/form/progress_add.dart';

import '../comm/mib3_controller.dart';
import 'cal.dart';

class Mprogress extends StatefulWidget {
  const Mprogress({super.key});

  @override
  State<Mprogress> createState() => _MprogressState();
}

class _MprogressState extends State<Mprogress> {
  final controller = Get.find<Mib3Controller>();
  late List<Map<String, dynamic>> rows;
  String _title = "progress";
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
            icon: const Icon(Icons.content_paste_off),
            onPressed: () {
              setState(() {
                _wan_flag = _wan_flag == "진행" ? "완료" : "진행";
                _title = _wan_flag == "진행" ? "to do" : "to do (finish)";
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
              final cache = <dynamic, Map<String, dynamic>>{};
              Map<String, dynamic> getDecodedContent(dynamic item) {
                return cache.putIfAbsent(item, () => jsonDecode(item.content));
              }

              var filtered = controller.items_jin
                  .where((item) => item.memo.tb == "진행" && item.memo.wan == _wan_flag)
                  .toList();

              if (_sort_flag) {
                filtered.sort(
                      (a, b) => getDecodedContent(a.memo)['content1'].compareTo(getDecodedContent(b.memo)['content1']),
                );
              } else {
                filtered.sort(
                      (a, b) => getDecodedContent(a.memo)['content1'].compareTo(getDecodedContent(b.memo)['content1']),
                );
              }

              return ListView.builder(
                controller: _controller,
                padding: const EdgeInsets.all(10),
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final item = filtered[index];
                  final content = getDecodedContent(item.memo);
                  return Card(
                    elevation: 7,
                    clipBehavior: Clip.antiAlias, // 중요
                    child: ListTile(
                      dense: true,
                      title: Transform.translate(
                        offset: const Offset(0, 0),
                        child: Text(content["content1"],
                          maxLines: controller.setting_line_size,
                          overflow: TextOverflow.fade,
                          style:
                          TextStyle(fontSize: controller.setting_font_size + 0.0),
                        ),
                      ),
                      trailing: Text(
                        "${get_date_term2(item.lastSubDate==null?"":item.lastSubDate.toString())}일 지남",
                        style: const TextStyle(
                            fontSize: 10, color: Colors.blueAccent),
                      ),

                      onTap: () async {
                        controller.temp_data = <String, dynamic>{
                          "id": item.memo.id,
                          "wan": item.memo.wan,
                          "content1": content['content1'],
                          "content2": content['content2'],
                        };
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const MprogressAdd();
                          },
                        );
                      },
                      onLongPress: () async {
                        var filtered = controller.subs
                            .where((it) => it.masterId.toString() == item.memo.id,).toList();

                        filtered.sort((a, b) => a.sdate.compareTo(b.sdate));

                        String data_sub = "";
                        for (var element in filtered) {
                          var row = getDecodedContent(element);
                          data_sub = "$data_sub ${element.sdate}(${get_date_yo(element.sdate)})\n" + row["content1"] + "\n" + row["content2"]+ "\n\n";
                        }

                        final s_data = <String, dynamic>{
                          "view_font_size": controller.setting_view_font_size
                              .toInt(),
                          "content1": content['content1']+"\n\n"+data_sub,
                        };

                        await Get.toNamed('/r/memo_view', arguments: s_data);
                        setState(() {});
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
            "content1": "",
            "content2": "",
          };
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MprogressAdd();
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
