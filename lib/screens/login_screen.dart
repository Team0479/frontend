import 'package:flutter/material.dart';
import '../main.dart';
import '../../theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.lightBlue,
              AppColors.lightPink,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'MyPlay',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: '아이디',
                    labelStyle: const TextStyle(fontFamily: 'DungGeunMo', fontSize: 16),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: const TextStyle(fontFamily: 'DungGeunMo', fontSize: 16),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 로그인 로직
                  },
                  child: Text('로그인', style: const TextStyle(fontFamily: 'DungGeunMo', fontSize: 18)),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    // TODO: 회원가입 화면 이동
                  },
                  child: Text('회원가입', style: const TextStyle(fontFamily: 'DungGeunMo', fontSize: 18)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 카카오 로그인 연동
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500), // 카카오 컬러
                    foregroundColor: Colors.black,
                  ),
                  child: Text('카카오로 로그인', style: const TextStyle(fontFamily: 'DungGeunMo', fontSize: 18)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // 개발용: 메인으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('메인으로 이동하기 (개발용)', style: const TextStyle(fontFamily: 'DungGeunMo', fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 