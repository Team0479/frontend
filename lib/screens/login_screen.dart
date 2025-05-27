import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'dart:async';
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
  
  // TODO: Replace these with actual values from your team member
  final String _clientId = '3f53ffa96a908a795ee96ed27c164a14';
  final String _redirectUri = 'https://4655-1-229-162-20.ngrok-free.app/callback';
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinkListener() async {
    try {
      // 앱이 실행 중일 때 딥링크 처리
      _linkSubscription = uriLinkStream.listen((Uri? uri) {
        _handleDeepLink(uri?.toString());
      }, onError: (err) {
        print('Failed to receive deep link: $err');
      });

      // 앱이 종료된 상태에서 딥링크로 실행된 경우 처리
      final initialLink = await getInitialUri();
      if (initialLink != null) {
        _handleDeepLink(initialLink.toString());
      }
    } catch (e) {
      print('Failed to initialize deep link listener: $e');
    }
  }

  void _handleDeepLink(String? link) async {
    if (link == null) return;
    final uri = Uri.parse(link);
    if (uri.scheme == 'myplay' && uri.host == 'callback') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        print('받은 JWT 토큰: $token');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    }
  }

  Future<void> _handleKakaoLogin() async {
  final kakaoAuthUrl =
      'https://kauth.kakao.com/oauth/authorize?response_type=code'
      '&client_id=$_clientId'
      '&redirect_uri=$_redirectUri';

  final Uri kakaoUri = Uri.parse(kakaoAuthUrl);

  if (await canLaunchUrl(kakaoUri)) {
    await launchUrl(
      kakaoUri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카카오 로그인을 실행할 수 없습니다.')),
      );
    }
  }
}


  Future<void> _handleCallback(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$_redirectUri?code=$code'),
      );
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', response.body);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인에 실패했습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 연결에 실패했습니다.')),
        );
      }
    }
  }

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
                  onPressed: _handleKakaoLogin,
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