import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import '../comm/mib3_controller.dart';
import 'package:mib3/comm/app_database.dart';
import 'package:mib3/comm/mib3_controller.dart';

import 'package:flutter/material.dart';

import 'memo_add.dart';

class Mmemo extends StatefulWidget {
  const Mmemo({super.key});

  @override
  State<Mmemo> createState() => _MmemoState();
}

class _MmemoState extends State<Mmemo> {
  final db = AppDatabase();
  String _title = "memo";
  String _jong_flag = '1';
  var _wan_flag = '진행';
  bool _sort_flag = true;
  final textSearch = TextEditingController();
  final ScrollController _controller = ScrollController();
  int cnt_scroll = 0;

  late final Mib3Controller controller;

  @override
  void initState() {
    controller = Get.put(Mib3Controller(db));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Stack(
          children: [
            // 기존 AppBar 그라데이션 (그대로 유지)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFC3A0),
                    Color(0xFFFFAFBD),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // ✅ 상태바 영역만 어둡게
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQueryData.fromView(
                WidgetsBinding.instance.platformDispatcher.views.first,
              ).padding.top,
              child: Container(
                color: Colors.black.withOpacity(0.2), // ← 여기서 농도 조절
              ),
            ),
          ],
        ),
        toolbarHeight: 37,
        title: Text(_title, style: const TextStyle(fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_double_arrow_down),
            onPressed: () async {
              var jp = _controller.position.maxScrollExtent / 10;
              cnt_scroll++;
              if (cnt_scroll * jp > _controller.position.maxScrollExtent) {
                cnt_scroll = 0;
              }

              _controller.animateTo(
                cnt_scroll * jp,
                duration: const Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.content_paste_off),
            onPressed: () {
              setState(() {
                textSearch.text = "";
                _wan_flag = _wan_flag == "진행" ? "완료" : "진행";
                _title = _wan_flag == "진행" ? "memo" : "memo (finish)";
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
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
            icon: const Icon(Icons.arrow_downward),
            onPressed: () {
              _sort_flag = !_sort_flag;
              setState(() {});
            },
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              var filtered = controller.items
                  .where(
                    (item) =>
                        item.tb == "메모" &&
                        item.wan == _wan_flag &&
                        jsonDecode(item.content)['jong'].toString() == _jong_flag,
                  )
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
                filtered.sort((a, b) => b.id.compareTo(a.id));
              } else {
                filtered.sort((a, b) => jsonDecode(a.content)['content1'].compareTo(jsonDecode(b.content)['content1']));
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
                          jsonDecode(item.content)['content1'],
                          maxLines: controller.setting_line_size.toInt(),
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontSize:
                                controller.setting_font_size.toInt() + 0.0,
                          ),
                        ),
                      ),
                      trailing: Text(
                        (index + 1).toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blueAccent,
                        ),
                      ),
                      onTap: () async {
                        controller.temp_data = <String, dynamic>{
                          "id": item.id,
                          "wan": item.wan,
                          "jong": jsonDecode(item.content)['jong'].toString(),
                          "content1": jsonDecode(item.content)['content1'],
                          "content2": jsonDecode(item.content)['content2'],
                        };
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const MmemoAdd();
                          },
                        );
                      },
                      onLongPress: () async {
                        final s_data = <String, dynamic>{
                          "view_font_size": controller.setting_view_font_size
                              .toInt(),
                          "content1": jsonDecode(item.content)['content1'],
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          controller.temp_data = <String, dynamic>{
            "id": "new",
            "wan": "진행",
            "jong": "1",
            "content1": "",
            "content2": "",
          };
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MmemoAdd();
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        height: 50,
        // color: Colors.blue[300],
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Row(
          children: [
            const SizedBox(width: 3),
            IconButton(
              icon: const Icon(Icons.looks_one),
              color: _jong_flag == '1' ? Colors.blue : Colors.grey,
              onPressed: () {
                _controller.jumpTo(0);
                setState(() {
                  _jong_flag = '1';
                });
              },
            ),
            const SizedBox(width: 3),
            IconButton(
              icon: const Icon(Icons.extension),
              color: _jong_flag == '2' ? Colors.blue : Colors.grey,
              onPressed: () {
                _controller.jumpTo(0);
                setState(() {
                  _jong_flag = '2';
                });
              },
            ),
            const SizedBox(width: 3),
            IconButton(
              icon: const Icon(Icons.savings),
              color: _jong_flag == '3' ? Colors.blue : Colors.grey,
              onPressed: () {
                _controller.jumpTo(0);
                setState(() {
                  _jong_flag = '3';
                });
              },
            ),
            const SizedBox(width: 3),
            IconButton(
              icon: const Icon(Icons.local_florist),
              color: _jong_flag == '4' ? Colors.blue : Colors.grey,
              onPressed: () {
                _controller.jumpTo(0);
                setState(() {
                  _jong_flag = '4';
                });
              },
            ),
            const SizedBox(width: 3),
            IconButton(
              icon: const Icon(Icons.switch_access_shortcut),
              color: _jong_flag == '5' ? Colors.blue : Colors.grey,
              onPressed: () {
                _controller.jumpTo(0);
                setState(() {
                  _jong_flag = '5';
                });
                // DBHelper db = DBHelper();
                // db.selectRows('delete from mhibj where tb = ?', ['memo']);
              },
            ),
            IconButton(
              icon: const Icon(Icons.diversity_1),
              color: _jong_flag == '6' ? Colors.blue : Colors.grey,
              onPressed: () {
                _controller.jumpTo(0);
                setState(() {
                  _jong_flag = '6';
                });
                // DBHelper db = DBHelper();
                // db.selectRows('delete from mhibj where tb = ?', ['memo']);
              },
            ),
          ],
        ),
      ),
    );
  }
}
