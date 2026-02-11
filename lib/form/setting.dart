import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

import '../comm/app_database.dart';
import '../comm/mib3_controller.dart';
import '../main.dart';

class Msetting extends StatefulWidget {
  const Msetting({Key? key}) : super(key: key);

  @override
  State<Msetting> createState() => _MsettingState();
}

class _MsettingState extends State<Msetting> {
  final textContent1 = TextEditingController();
  final textContent2 = TextEditingController();
  final textContent3 = TextEditingController();

  final controller = Get.find<Mib3Controller>();

  List<String> items_font = ['OpenSans-Medium', 'D2Coding-Ver1.3.2-20180524', 'SeoulHangangM', '경기천년제목_Light'];
  TextStyle? _selectedFontTextStyle;

  @override
  void initState() {
    // _selectedFontTextStyle.
    textContent1.text = controller.setting_font_size.toString();
    textContent2.text = controller.setting_view_font_size.toString();
    textContent3.text = controller.setting_line_size.toString();

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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  const Text('font', style: TextStyle(fontSize: 12)),
                  const SizedBox(
                    width: 10,
                  ),
                  DropdownButton<String>(
                    value: controller.setting_font,
                    items: items_font.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      controller.setting_font = newValue!;
                      setState(() {
                        _selectedFontTextStyle = TextStyle(fontFamily: newValue);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(width:MediaQuery.of(context).size.width, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    width: 90.0,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.fromLTRB(20.0, 1.0, 20.0, 11.0),
                        labelText: 'size',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      controller: textContent1,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 90.0,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.fromLTRB(20.0, 1.0, 20.0, 11.0),
                        labelText: 'v size',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      controller: textContent2,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 90.0,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.fromLTRB(20.0, 1.0, 20.0, 11.0),
                        labelText: 'l size',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      controller: textContent3,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final googleSignIn = GoogleSignIn();

                      await googleSignIn.signOut();      // 구글 로그아웃
                      await FirebaseAuth.instance.signOut();
                      SystemNavigator.pop();
                    },
                    child: const Text('login out', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final themeCtrl = Get.find<ThemeController>();
                      themeCtrl.setFont(controller.setting_font); // ⭐⭐⭐ 이 줄이 핵심

                      controller.updateSetting(
                          'font',
                        controller.setting_font
                      );
                      await controller.updateSetting(
                          'font_size',
                          textContent1.text
                      );

                      await controller.updateSetting(
                          'view_font_size',
                          textContent2.text
                      );

                      await controller.updateSetting(
                          'line_size',
                          textContent3.text
                      );

                      Navigator.of(context).pop();
                    },
                    child: const Text('save', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
            ])));
  }
}
