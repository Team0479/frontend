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
  final String _redirectUri = 'https://278d-218-235-241-56.ngrok-free.app/callback';
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

  Widget _buildKakaoLoginButton() {
    return Center(
      child: GestureDetector(
        onTap: _handleKakaoLogin,
        child: Container(
          width: 348,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFAE655),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Image.asset(
                'assets/images/kakao_icon.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '카카오로 계속하기',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Spoqa Han Sans Neo',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 40), // 오른쪽 여백
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 로고 자리 (비워둠)
                    const SizedBox(height: 304),
                    // 아이디 입력
                    SizedBox(
                      width: 348,
                      height: 48,
                      child: TextField(
                        controller: _idController,
                        style: const TextStyle(
                          fontFamily: 'Spoqa Han Sans Neo',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: '아이디',
                          hintStyle: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
                          filled: true,
                          fillColor: Color.fromRGBO(255, 255, 255, 0.65),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 비밀번호 입력
                    SizedBox(
                      width: 348,
                      height: 48,
                      child: TextField(
                        controller: _pwController,
                        obscureText: true,
                        style: const TextStyle(
                          fontFamily: 'Spoqa Han Sans Neo',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: '비밀번호',
                          hintStyle: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
                          filled: true,
                          fillColor: Color.fromRGBO(255, 255, 255, 0.65),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 로그인 버튼
                    SizedBox(
                      width: 348,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: 로그인 로직
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4363EA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500, fontSize: 14),
                          elevation: 0,
                        ),
                        child: const Text('로그인'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 카카오 로그인 버튼
                    _buildKakaoLoginButton(),
                    const SizedBox(height: 12),
                    // 회원가입 버튼
                    SizedBox(
                      width: 348,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: 회원가입 화면 이동
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4D4D4),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500, fontSize: 14),
                          elevation: 0,
                        ),
                        child: const Text('회원가입'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // 개발용 홈 이동 버튼 (화면 어디서나 접근 가능)
          Positioned(
            right: 16,
            bottom: 32,
            child: Opacity(
              opacity: 0.7,
              child: FloatingActionButton.small(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                child: const Icon(Icons.home),
                tooltip: '개발용 홈 이동',
              ),
            ),
          ),
        ],
      ),
    );
  }
} 