import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../comm/app_database.dart';
import '../comm/mib3_controller.dart';
import 'cal.dart';
import 'hal_add.dart';

class Mhal extends StatefulWidget {
  const Mhal({super.key});

  @override
  State<Mhal> createState() => _MhalState();
}

class _MhalState extends State<Mhal> {
  final controller = Get.find<Mib3Controller>();
  late List<Map<String, dynamic>> rows;
  String _title =
      "to do ${DateFormat('MM-dd').format(DateTime.now())} ${get_date_yo(DateTime.now().toString())}";
  String _wan_flag = "진행";
  String _date_flag = "";
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
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showCalendarDialog(context);
              if (picked == null) {
                _date_flag = "";
              } else {
                _date_flag = picked.toString();
              }
              setState(() {});
            },
          ),
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
            child: StreamBuilder<List<Mib3Data>>(
              stream: controller.watchTodo(
                wanFlag: _wan_flag,
                sortByDate: _sort_flag,
                dateLimit: _date_flag,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = snapshot.data!;

                if (list.isEmpty) {
                  return const Center(child: Text('할일 없음'));
                }

                return ListView.builder(
                  controller: _controller,
                  padding: const EdgeInsets.all(10),
                  itemCount: list.length,
                  itemBuilder: (_, index) {
                    final item = list[index];
                    final content = controller.decode(item);

                    return Card(
                      elevation: 7,
                      child: ListTile(
                        dense: true,
                        title: Text(
                          "  ${content['s_date']}(${get_date_yo(content['s_date'])})\n"
                              "${content['content1']}",
                          maxLines: controller.setting_line_size,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontSize: controller.setting_font_size + 0.0,
                          ),
                        ),
                        trailing: Text(
                          "${get_date_term2(content['s_date']) * -1 + 1}일 남음",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blueAccent,
                          ),
                        ),
                        onTap: () async {
                          controller.temp_data = {
                            "id": item.id,
                            "wan": item.wan,
                            "s_date": content['s_date'],
                            "content1": content['content1'],
                            "content2": content['content2'],
                          };

                          await showDialog(
                            context: context,
                            builder: (_) => const MhalAdd(),
                          );
                        },
                        onLongPress: () async {
                          final sData = {
                            "view_font_size":
                            controller.setting_view_font_size.toInt(),
                            "content1": content['content1'],
                          };

                          await Get.toNamed('/r/memo_view', arguments: sData);
                        },
                      ),
                    );
                  },
                );
              },
            ),
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
              return const MhalAdd();
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
