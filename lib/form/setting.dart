import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../comm/mib3_controller.dart';

class Msetting extends StatefulWidget {
  const Msetting({super.key});

  @override
  State<Msetting> createState() => _MsettingState();
}

class _MsettingState extends State<Msetting> {
  final textContent1 = TextEditingController();
  final textContent2 = TextEditingController();
  final textContent3 = TextEditingController();

  final controller = Get.find<Mib3Controller>();
  final themeCtrl = Get.find<ThemeController>();

  final itemsFont = [
    'OpenSans-Medium',
    'D2Coding-Ver1.3.2-20180524',
    'SeoulNamsabB',
    'SeoulHangangB',
    '경기천년제목_Light',
    '경기천년제목_Medium',
  ];

  final themeItems = const [
    {'label': '시스템', 'mode': ThemeMode.system},
    {'label': '라이트', 'mode': ThemeMode.light},
    {'label': '다크', 'mode': ThemeMode.dark},
  ];

  late ThemeMode _selectedTheme;
  late String _selectedFont;

  @override
  void initState() {
    super.initState();

    textContent1.text = controller.setting_font_size.toString();
    textContent2.text = controller.setting_view_font_size.toString();
    textContent3.text = controller.setting_line_size.toString();

    _selectedTheme = themeCtrl.themeMode.value;
    _selectedFont = controller.setting_font;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(5),
      contentPadding: const EdgeInsets.all(5),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// 🔹 THEME (미리보기만)
            Row(
              children: [
                const SizedBox(width: 20),
                const Text('theme', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 10),
                DropdownButton<ThemeMode>(
                  value: _selectedTheme,
                  items: themeItems.map((item) {
                    return DropdownMenuItem<ThemeMode>(
                      value: item['mode'] as ThemeMode,
                      child: Text(item['label'] as String),
                    );
                  }).toList(),
                  onChanged: (mode) {
                    if (mode == null) return;
                    setState(() => _selectedTheme = mode);
                    themeCtrl.setThemeMode(mode); // ✅ 미리보기
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// 🔹 FONT (미리보기만)
            Row(
              children: [
                const SizedBox(width: 20),
                const Text('font', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedFont,
                  items: itemsFont.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(f),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedFont = v);
                    themeCtrl.setFont(v); // ✅ 미리보기
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 SIZE
            Row(
              children: [
                const SizedBox(width: 20),
                _numField(textContent1, 'size'),
                const SizedBox(width: 10),
                _numField(textContent2, 'v size'),
                const SizedBox(width: 10),
                _numField(textContent3, 'l size'),
              ],
            ),

            const SizedBox(height: 30),

            /// 🔹 BUTTONS
            Row(
              children: [
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    await GoogleSignIn().signOut();
                    await FirebaseAuth.instance.signOut();
                    SystemNavigator.pop();
                  },
                  child: const Text('logout', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    // ✅ 여기서만 저장
                    await controller.updateSetting(
                        'theme', _selectedTheme.name);
                    await controller.updateSetting(
                        'font', _selectedFont);
                    await controller.updateSetting(
                        'font_size', textContent1.text);
                    await controller.updateSetting(
                        'view_font_size', textContent2.text);
                    await controller.updateSetting(
                        'line_size', textContent3.text);

                    Navigator.pop(context);
                  },
                  child: const Text('save', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController c, String label) {
    return SizedBox(
      width: 75,
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}