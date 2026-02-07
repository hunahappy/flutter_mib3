import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../comm/getx_controller.dart';


class MprogressSubAdd extends StatelessWidget {
  final textSubContent1 = TextEditingController();
  final textSubContent2 = TextEditingController();
  final textDate = TextEditingController();
  String doc_id = '';
  String master_doc_id = '';
  static const table_name = "progress";


  MprogressSubAdd(String p_doc_id, String p_master_doc_id, String p_dateText, String p_content1, String p_content2, {super.key}){
    if (p_master_doc_id == "update"){
      textDate.text = p_dateText;
      textSubContent1.text = p_content1;
      textSubContent2.text = p_content2;
    }else{
      textDate.text = p_dateText;
    }
    doc_id = p_doc_id;
    master_doc_id = p_master_doc_id;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(10),
      content: SizedBox(
          width: 500.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  width: 170.0,
                  child: TextFormField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      labelText: tr('date'),
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
                      final DateTime? picked = await showDatePicker(
                        context: context,
// locale: const Locale("ko", "KO"),
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2015),
                        lastDate: DateTime(2101),
                        initialDatePickerMode: DatePickerMode.day,
                      );
                      if (picked != null) {
                        textDate.text = picked.toString().substring(0, 10);
                      }
                    }),
                const SizedBox(
                  width: 10,
                ),
              ]),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  labelText: tr('content1'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                style: const TextStyle(
                  height: 1.2,
                  fontSize: 14,
                ),
                controller: textSubContent1,
                minLines: 3,
                maxLines: 4,
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  labelText: tr('content2'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                style: const TextStyle(
                  height: 1.2,
                  fontSize: 14,
                ),
                controller: textSubContent2,
                minLines: 3,
                maxLines: 4,
              ),
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
                              title: Text(tr('delete?')),
                              content: Text(tr("deleting it?")),
                              actions: <Widget>[
                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      if (doc_id != "new") {
                                        delete_data_sub(doc_id);
                                        checkClose = true;
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
                      }),
                  const SizedBox(width: 20),
                  IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () async {
                        if (master_doc_id == "update"){
                          final data = <String, dynamic>{
                            "progress_date":textDate.text,
                            "content1": textSubContent1.text,
                            "content2": textSubContent2.text,
                            "input_date": DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                          };

                          update_data_sub(doc_id, table_name, data);
                          Navigator.of(context).pop();
                        }
                        else {
                          final data = <String, dynamic>{
                            "progress_date":textDate.text,
                            "content1": textSubContent1.text,
                            "content2": textSubContent2.text,
                            "input_date": DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                          };

                          var new_doc_id = DateFormat('yyyy-MM-dd_HH-mm-ss-SS').format(DateTime.now());

                          insert_data_sub(new_doc_id, doc_id, table_name, data);
                          Navigator.of(context).pop();
                        }
                      }),
                ],
              ),
            ],
          )),
    );
  }
}
