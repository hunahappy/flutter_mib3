import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mib3/login_screen.dart';
import 'package:mib3/mib_screen.dart';
import 'app_theme.dart';
import 'comm/app_database.dart';
import 'comm/mib3_controller.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';


import 'package:flutter/material.dart';

import 'package:mib3/comm/db_helper.dart';
import 'package:mib3/form/memo_add.dart';

import 'form/hal_add.dart';
import 'form/memo_view.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  final dbHelper = DBHelper();
  final db = await dbHelper.database;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final user = FirebaseAuth.instance.currentUser;

  if (user != null && user.isAnonymous) {
    await FirebaseAuth.instance.signOut();
  }

  //////////////////////////////////////////////////////////////////////////////
  final dba = AppDatabase();
  final controller = Get.put(Mib3Controller(dba));
  List<Map<String, dynamic>> rows = await db.rawQuery('select * from setting');

  for (var s in rows) {
    switch (s['id']) {
      case 'font':
        controller.setting_font = s['content'].toString();
        break;
      case 'font_size':
        controller.setting_font_size = int.tryParse(s['content'].toString()) ?? 0;
        break;
      case 'view_font_size':
        controller.setting_view_font_size = int.tryParse(s['content'].toString()) ?? 0;
        break;
      case 'line_size':
        controller.setting_line_size = int.tryParse(s['content'].toString()) ?? 0;
        break;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'mib3 Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      locale: const Locale('ko', 'KR'),
      fallbackLocale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: StreamBuilder<User?>( 
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const MibScreen();
            // return const LoginScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),

      getPages: [
        GetPage(name: '/r/memo_add', page: () => const MmemoAdd()),
        GetPage(name: '/r/memo_view', page: () => const MmemoView()),
        GetPage(name: '/r/hal_add', page: () => const MhalAdd()),
      ],
    );
  }
}
