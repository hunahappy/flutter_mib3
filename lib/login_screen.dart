
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Future<void> _signInWithGoogle() async {
    // ... (기존 코드는 변경하지 않습니다)
    try {
      final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Failed. Error: $e')),
        );
      }
    }
  }

  // --- 로그아웃 함수 추가 ---
  Future<void> _signOut() async {
    try {
      await GoogleSignIn().signOut(); // Google 계정에서 로그아웃
      await FirebaseAuth.instance.signOut(); // Firebase에서 로그아웃
      print("로그아웃 성공!");
    } catch (e) {
      print("로그아웃 중 오류 발생: $e");
    }
  }
  // --- 로그아웃 함수 추가 끝 ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  height: 150,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.account_circle),
                    label: const Text('Google'),
                    onPressed: _signInWithGoogle,
                  ),
                ),
              ],
            ),                       // --- 로그아웃 버튼 추가 끝 ---
          ],
        ),
      ),
    );
  }
}
