import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../comm/app_database.dart';
import '../comm/mib3_controller.dart';
import '../main.dart';
import 'cal.dart';

class MilgiAdd extends StatefulWidget {
  const MilgiAdd({Key? key}) : super(key: key);

  @override
  State<MilgiAdd> createState() => _MilgiAddState();
}

class _MilgiAddState extends State<MilgiAdd> {
  final textContent1 = TextEditingController();
  final textContent2 = TextEditingController();
  final textDate = TextEditingController();

  final controller = Get.find<Mib3Controller>();

  @override
  void initState() {
    textContent1.text = controller.temp_data['content1'];
    textContent2.text = controller.temp_data['content2'];
    textDate.text = controller.temp_data['s_date'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        insetPadding: const EdgeInsets.all(5),
        contentPadding: const EdgeInsets.all(5),
        content: SingleChildScrollView(
            child: Column(children: [
              Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(children: [
                    SizedBox(width:MediaQuery.of(context).size.width, height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      SizedBox(
                        width: 170.0,
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            labelText: 'date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          controller: textDate,
                          readOnly: true,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            DateTime initial = DateTime(int.parse(textDate.text.substring(0, 4)),int.parse(textDate.text.substring(5, 7)), int.parse(textDate.text.substring(8, 10))); // 원하는 날짜
                            final picked = await showCalendarDialog(context, initialDate: initial);
                            if (picked != null) {
                              textDate.text = picked.toString().substring(0, 10);
                            }
                          }),
                      const SizedBox(
                        width: 10,
                      ),
                    ]),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        labelText: "content1",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      style: const TextStyle(
                        height: 1.2,
                        fontSize: 14,
                      ),
                      controller: textContent1,
                      minLines: 8,
                      maxLines: 10,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        labelText: "content2",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      style: const TextStyle(
                        height: 1.2,
                        fontSize: 14,
                      ),
                      controller: textContent2,
                      minLines: 2,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                                            if (controller.temp_data["id"] != "new") {
                                              controller.updateItem(
                                                  controller.temp_data["id"],
                                                  '할일',
                                                  controller.temp_data['wan'] ==
                                                      "진행" ? "완료" : "진행",
                                                  jsonEncode({
                                                    's_date': textDate.text,
                                                    'content1': textContent1
                                                        .text,
                                                    'content2': textContent2
                                                        .text,
                                                    'input_date': DateFormat(
                                                        'yyyy-MM-dd HH:mm:ss')
                                                        .format(DateTime.now())
                                                  }
                                                  )
                                              );
                                              checkClose = true;
                                            } else {
                                              show_toast("no data", context);
                                            }
                                            Navigator.of(context).pop();
                                          }
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (checkClose) {
                                Navigator.of(context).pop();
                              }
                            }),
                        const SizedBox(
                          width: 20,
                        ),
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
                                              controller.removeItem(controller.temp_data["id"]);
                                              checkClose = true;
                                            } else {
                                              show_toast("no data", context);
                                            }

                                            Navigator.of(context).pop();
                                          }
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (checkClose) {
                                Navigator.of(context).pop();
                              }
                            }),
                        const SizedBox(width: 20),
                        IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () async {
                              if (controller.temp_data["id"].toString() == "new") {
                                await controller.addItem(
                                    '일기',
                                    controller.temp_data['wan'],
                                    jsonEncode({
                                      's_date': textDate.text,
                                      'content1': textContent1.text, 'content2': textContent2.text,
                                      'input_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}
                                    )
                                );
                                Navigator.of(context).pop();
                              } else {
                                await controller.updateItem(
                                    controller.temp_data["id"],
                                    '일기',
                                    controller.temp_data['wan'],
                                    jsonEncode({
                                      's_date': textDate.text,
                                      'content1': textContent1.text, 'content2': textContent2.text,
                                      'input_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}
                                    )
                                );
                                Navigator.of(context).pop();
                              }
                            }
                        ),
                      ],
                    )
                  ])),
            ])));
  }
}
