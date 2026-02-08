import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../comm/app_database.dart';
import '../comm/mib3_controller.dart';
import '../main.dart';

class MprogressSubAdd extends StatefulWidget {
  const MprogressSubAdd({Key? key}) : super(key: key);

  @override
  State<MprogressSubAdd> createState() => _MprogressSubAddState();
}

class _MprogressSubAddState extends State<MprogressSubAdd> {
  final textContent1 = TextEditingController();
  final textContent2 = TextEditingController();
  final textDate = TextEditingController();

  final controller = Get.find<Mib3Controller>();

  @override
  void initState() {
    textContent1.text = controller.sub_temp_data['content1'];
    textContent2.text = controller.sub_temp_data['content2'];
    textDate.text = controller.sub_temp_data['sdate'];

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 170.0,
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(
                              20.0,
                              10.0,
                              20.0,
                              10.0,
                            ),
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
                      const SizedBox(width: 5),
                      IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2015),
                            lastDate: DateTime(2101),
                            initialDatePickerMode: DatePickerMode.day,
                          );
                          if (picked != null) {
                            textDate.text = picked.toString().substring(0, 10);
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                                      if (controller.sub_temp_data["id"] !=
                                          "new") {
                                        controller.removeSub(
                                          controller.sub_temp_data["id"],
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
                          if (controller.sub_temp_data["id"].toString() ==
                              "new") {
                            await controller.addSub(
                              controller.temp_data['id'],
                              textDate.text,
                              jsonEncode({
                                's_date': textDate.text,
                                'content1': textContent1.text,
                                'content2': textContent2.text,
                                'input_date': DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(DateTime.now()),
                              }),
                            );
                            Navigator.of(context).pop();
                          } else {
                            await controller.updateSub(
                              controller.sub_temp_data["id"],
                              textDate.text,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
