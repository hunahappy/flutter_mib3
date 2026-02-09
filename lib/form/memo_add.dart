import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../comm/app_database.dart';
import '../comm/mib3_controller.dart';
import 'package:intl/intl.dart';

class MmemoAdd extends StatefulWidget {
  const MmemoAdd({super.key});

  @override
  State<MmemoAdd> createState() => _MmemoAddState();
}

class _MmemoAddState extends State<MmemoAdd> {
  final textContent1 = TextEditingController();
  final textContent2 = TextEditingController();

  final controller = Get.find<Mib3Controller>();

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
          child: Column(children: [
            SizedBox(width:MediaQuery.of(context).size.width, height: 10),
        Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              Row(
                children: [
                  const SizedBox(
                    width: 3,
                  ),
                  IconButton(
                      icon: const Icon(Icons.looks_one),
                      color: int.parse(controller.temp_data['jong'].toString()) == 1 ? Colors.blue : Colors.grey,
                      onPressed: () {
                        setState(() {
                          controller.temp_data['jong'] = '1';
                        });
                      }),
                  const SizedBox(
                    width: 3,
                  ),
                  IconButton(
                      icon: const Icon(Icons.extension),
                      color: int.parse(controller.temp_data['jong'].toString()) == 2 ? Colors.blue : Colors.grey,
                      onPressed: () {
                        setState(() {
                          controller.temp_data['jong'] = '2';
                        });
                      }),
                  const SizedBox(
                    width: 3,
                  ),
                  IconButton(
                      icon: const Icon(Icons.savings),
                      color: int.parse(controller.temp_data['jong'].toString()) == 3 ? Colors.blue : Colors.grey,
                      onPressed: () {
                        setState(() {
                          controller.temp_data['jong'] = '3';
                        });
                      }),
                  const SizedBox(
                    width: 3,
                  ),
                  IconButton(
                      icon: const Icon(Icons.local_florist),
                      color: int.parse(controller.temp_data['jong'].toString()) == 4 ? Colors.blue : Colors.grey,
                      onPressed: () {
                        setState(() {
                          controller.temp_data['jong'] = '4';
                        });
                      }),
                  const SizedBox(
                    width: 3,
                  ),
                  IconButton(
                      icon: const Icon(Icons.switch_access_shortcut),
                      color: int.parse(controller.temp_data['jong'].toString()) == 5 ? Colors.blue : Colors.grey,
                      onPressed: () {
                        setState(() {
                          controller.temp_data['jong'] = '5';
                        });
                      }),
                  const SizedBox(
                    width: 3,
                  ),
                  IconButton(
                      icon: const Icon(Icons.diversity_1),
                      color: int.parse(controller.temp_data['jong'].toString()) == 6 ? Colors.blue : Colors.grey,
                      onPressed: () {
                        setState(() {
                          controller.temp_data['jong'] = '6';
                        });
                      }),
                  const SizedBox(
                    width: 3,
                  ),
                ],
              ),
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
                minLines: 10,
                maxLines: 15,
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
                              title: Text('finish?'),
                              content: Text("completing it?"),
                              actions: <Widget>[
                                IconButton(
                                    icon: const Icon(Icons.content_paste_off),
                                    onPressed: () {
                                      if (controller.temp_data["id"] != "new") {
                                        controller.updateItem(
                                            controller.temp_data["id"],
                                            '메모',
                                            controller.temp_data['wan'] == "진행"
                                                ? "완료"
                                                : "진행",
                                            jsonEncode({
                                              'jong': controller
                                                  .temp_data['jong'],
                                              'content1': textContent1.text,
                                              'content2': textContent2.text,
                                              'input_date': DateFormat(
                                                  'yyyy-MM-dd HH:mm:ss').format(
                                                  DateTime.now())
                                            }
                                            )
                                        );
                                        checkClose = true;
                                      } else {
                                        show_toast("no data", context);
                                      }
                                      Navigator.of(context).pop();
                                    }),
                              ],
                            );
                          },
                        );
                        if (checkClose) {
                          Navigator.of(context).pop();
                        }
                      }
                  ),
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
                              title: Text('delete?'),
                              content: Text("deleting it?"),
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
                                    }),
                              ],
                            );
                          },
                        );
                        if (checkClose) {
                          Navigator.of(context).pop();
                        }
                      }
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () async {
                        if (controller.temp_data["id"].toString() == "new") {
                          await controller.addItem(
                              '메모',
                              controller.temp_data['wan'],
                              jsonEncode({ 'jong': controller.temp_data['jong'],
                                'content1': textContent1.text, 'content2': textContent2.text,
                                'input_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}
                              )
                          );
                          Navigator.of(context).pop();
                        } else {
                          await controller.updateItem(
                              controller.temp_data["id"],
                              '메모',
                              controller.temp_data['wan'],
                              jsonEncode({ 'jong': controller.temp_data['jong'],
                                'content1': textContent1.text, 'content2': textContent2.text,
                                'input_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}
                              )
                          );
                          Navigator.of(context).pop();
                        }
                      }
                  ),
                ],
              ),
            ])),
      ])),
    );
  }
}
