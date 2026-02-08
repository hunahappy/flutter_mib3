import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid || Platform.isIOS) {
      // Android / iOS 기본 초기화
      _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    } else {
      // macOS 전용 초기화: 반드시 macOS OAuth clientId 사용
      _googleSignIn = GoogleSignIn(
        clientId:
        '693527971975-to1pkv2dlfvbtb1buqtcjg9rs7j685r0.apps.googleusercontent.com', // <- macOS clientId
        scopes: ['email', 'profile'],
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        // macOS
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Google 로그인 성공')),
        );
      }
    } catch (e) {
      debugPrint('❌ Google 로그인 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 로그인 실패: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _googleSignIn.signOut(); // macOS, Android/iOS 공통
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 로그아웃 성공')),
        );
      }
    } catch (e) {
      debugPrint('❌ 로그아웃 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 2 / 3,
          height: 56,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.account_circle),
            label: const Text('Google 로그인'),
            onPressed: _signInWithGoogle,
          ),
        ),
      ),
    );
  }
}