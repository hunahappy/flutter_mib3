import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mib3/form/progress_sub_add.dart';

import '../comm/app_database.dart';
import '../comm/mib3_controller.dart';
import '../main.dart';

class MprogressAdd extends StatefulWidget {
  const MprogressAdd({super.key});

  @override
  State<MprogressAdd> createState() => _MprogressAddState();
}

class _MprogressAddState extends State<MprogressAdd> {
  late List<Map<String, dynamic>> rows;

  final textContent1 = TextEditingController();
  final textContent2 = TextEditingController();

  final controller = Get.find<Mib3Controller>();

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    textContent1.text = controller.temp_data['content1'];
    textContent2.text = controller.temp_data['content2'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(5),
      contentPadding: const EdgeInsets.all(5),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(
                        20.0,
                        10.0,
                        20.0,
                        10.0,
                      ),
                      labelText: "content1",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    style: const TextStyle(height: 1.2, fontSize: 14),
                    controller: textContent1,
                    minLines: 5,
                    maxLines: 8,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(
                        20.0,
                        10.0,
                        20.0,
                        10.0,
                      ),
                      labelText: "content2",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    style: const TextStyle(height: 1.2, fontSize: 14),
                    controller: textContent2,
                    minLines: 2,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          controller.sub_temp_data = <String, dynamic>{
                            "id": "new",
                            "sdate": DateFormat(
                              'yyyy-MM-dd',
                            ).format(DateTime.now()),
                            "content1": "",
                            "content2": "",
                          };
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const MprogressSubAdd();
                            },
                          );
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.content_paste_off),
                        onPressed: () async {
                          bool checkClose = false;
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('finish?'),
                                content: const Text("completing it?"),
                                actions: <Widget>[
                                  IconButton(
                                    icon: const Icon(Icons.content_paste_off),
                                    onPressed: () {
                                      controller.updateItem(
                                        controller.temp_data["id"],
                                        '진행',
                                        controller.temp_data['wan'] == "진행"
                                            ? "완료"
                                            : "진행",
                                        jsonEncode({
                                          'content1': textContent1.text,
                                          'content2': textContent2.text,
                                          'input_date': DateFormat(
                                            'yyyy-MM-dd HH:mm:ss',
                                          ).format(DateTime.now()),
                                        }),
                                      );
                                      checkClose = true;
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          if (checkClose) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          bool checkClose = false;
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('delete?'),
                                content: const Text("deleting it?"),
                                actions: <Widget>[
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      if (controller.temp_data["id"] != "new") {
                                        controller.removeItem(
                                          controller.temp_data["id"],
                                        );
                                        controller.removeByMasterSub(
                                          controller.temp_data["id"],
                                        );
                                        checkClose = true;
                                      } else {
                                        show_toast("no data", context);
                                      }

                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          if (checkClose) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          if (controller.temp_data["id"].toString() == "new") {
                            await controller.addItem(
                              '진행',
                              controller.temp_data['wan'],
                              jsonEncode({
                                'content1': textContent1.text,
                                'content2': textContent2.text,
                                'input_date': DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(DateTime.now()),
                              }),
                            );
                            Navigator.of(context).pop();
                          } else {
                            await controller.updateItem(
                              controller.temp_data["id"],
                              '진행',
                              controller.temp_data['wan'],
                              jsonEncode({
                                'content1': textContent1.text,
                                'content2': textContent2.text,
                                'input_date': DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(DateTime.now()),
                              }),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 400,
                    child: Obx(() {
                      var filtered = controller.subs
                          .where(
                            (item) =>
                                item.masterId.toString() ==
                                controller.temp_data["id"].toString(),
                          )
                          .toList();

                      filtered.sort((a, b) => b.sdate.compareTo(a.sdate));

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
                                  jsonDecode(item.content)["content1"],
                                  maxLines: controller.setting_line_size,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontSize:
                                        controller.setting_font_size + 0.0,
                                  ),
                                ),
                              ),
                              trailing: Text(
                                index < filtered.length - 1
                                    ? filtered[index].sdate.toString().length > 9
                                          ? "${filtered[index].sdate.toString().substring(5, 10)} ${get_date_yo(filtered[index].sdate.toString())}\n${get_term_day(filtered[index].sdate, filtered[index + 1].sdate)}${"일 지남"}"
                                          : ""
                                    : filtered[index].sdate.toString().length > 9
                                    ? "${filtered[index].sdate.toString().substring(5, 10)} ${get_date_yo(filtered[index].sdate.toString())}\n최초"
                                    : "",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              onTap: () async {
                                controller.sub_temp_data = <String, dynamic>{
                                  "id": item.id,
                                  "masterid": item.masterId,
                                  "sdate": item.sdate,
                                  "content1": jsonDecode(
                                    item.content,
                                  )['content1'],
                                  "content2": jsonDecode(
                                    item.content,
                                  )['content2'],
                                };
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const MprogressSubAdd();
                                  },
                                );
                              },
                              onLongPress: () async {
                                final s_data = <String, dynamic>{
                                  "view_font_size": controller
                                      .setting_view_font_size
                                      .toInt(),
                                  "content1": jsonDecode(
                                    item.content,
                                  )['content1'],
                                };

                                await Get.toNamed(
                                  '/r/memo_view',
                                  arguments: s_data,
                                );
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
            ),
          ],
        ),
      ),
    );
  }
}
