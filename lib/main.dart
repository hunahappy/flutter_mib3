import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_size/window_size.dart';

import 'firebase_options.dart';
import 'login_screen.dart';
import 'mib_screen.dart';

import 'comm/app_database.dart';
import 'comm/mib3_controller.dart';

import 'form/memo_add.dart';
import 'form/memo_view.dart';
import 'form/hal_add.dart';
import 'form/ilgi_add.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    setWindowTitle('mib3');
    setWindowMinSize(const Size(800, 600));
    setWindowMaxSize(Size.infinite);
    setWindowFrame(const Rect.fromLTWH(100, 100, 768, 1024));
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final user = FirebaseAuth.instance.currentUser;
  if (user != null && user.isAnonymous) {
    await FirebaseAuth.instance.signOut();
  }

  /// ✅ 컨트롤러 등록 (순서 중요)
  Get.put(ThemeController(), permanent: true);
  final db = AppDatabase();
  Get.put(Mib3Controller(db), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    /// ⭐ 여기 핵심
    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'mib3 Demo',

      /// 🔥 테마는 컨트롤러 값을 직접 사용
      themeMode: themeCtrl.themeMode.value,
      theme: themeCtrl.lightTheme,
      darkTheme: themeCtrl.darkTheme,

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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.hasData
              ? MibScreen()
              : const LoginScreen();
        },
      ),

      getPages: [
        GetPage(name: '/r/memo_add', page: () => const MmemoAdd()),
        GetPage(name: '/r/memo_view', page: () => const MmemoView()),
        GetPage(name: '/r/hal_add', page: () => const MhalAdd()),
        GetPage(name: '/r/ilgi_add', page: () => const MilgiAdd()),
      ],
    ));
  }
}