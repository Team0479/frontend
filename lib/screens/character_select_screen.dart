import 'package:flutter/material.dart';
import 'package:inner_shadow_widget/inner_shadow_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  int? _selectedIndex;
  final TextEditingController _nicknameController = TextEditingController();

  final List<Map<String, String>> _characters = [
    {"name": "blue", "asset": "assets/images/character_blue.png"},
    {"name": "yellow", "asset": "assets/images/character_yellow.png"},
    {"name": "red", "asset": "assets/images/character_red.png"},
    {"name": "purple", "asset": "assets/images/character_purple.png"},
    {"name": "green", "asset": "assets/images/character_green.png"},
  ];

  // 캐릭터 위치 정보 (중심 기준)
  final List<Map<String, double>> _characterPositions = [
    {"left": 51 - 31, "top": 20.0},   // 파랑
    {"left": 145 - 31, "top": 20.0},  // 노랑
    {"left": 245 - 31, "top": 20.0},  // 빨강
    {"left": 95 - 31, "top": 108.0},  // 보라
    {"left": 201 - 31, "top": 108.0}, // 초록
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // 텍스트 + 배경
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/text_bg.png',
                      width: 328,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '마이 캐릭터를 선택해주세요!',
                        style: TextStyle(
                          fontFamily: 'Galmuri14',
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 캐릭터 선택 영역
                Container(
                  width: 348,
                  height: 205,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/character_bg.png'),
                      fit: BoxFit.cover,
                    ),
                    color: const Color(0xFFE5EEFA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFE8E9EB), width: 1),
                  ),
                  child: Stack(
                    children: List.generate(5, (index) {
                      final isSelected = _selectedIndex == index;
                      final double widthDiff = (160 - 120) / 2;
                      final double heightDiff = (111 - 83) / 2;
                      final double left = _characterPositions[index]["left"]! - (isSelected ? widthDiff : 0);
                      final double top = _characterPositions[index]["top"]! - (isSelected ? heightDiff : 0);
                      return Positioned(
                        left: left,
                        top: top,
                        child: _buildCharacter(index),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                // 닉네임 입력
                Container(
                  width: 348,
                  height: 48,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: _nicknameController,
                    style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '닉네임을 입력하세요',
                      hintStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 14, color: Color(0xFF898989)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.65),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
                // 확인 버튼
                SizedBox(
                  width: 348,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final nickname = _nicknameController.text.trim();
                      final selectedIdx = _selectedIndex;
                      if (nickname.isEmpty || selectedIdx == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('캐릭터와 닉네임을 모두 선택해 주세요.')),
                        );
                        return;
                      }
                      final profileImage = _characters[selectedIdx]['asset'];
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('my_character_asset', profileImage!);
                      final jwt = prefs.getString('jwt_token');
                      if (jwt == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인 해주세요.')),
                        );
                        return;
                      }
                      final response = await http.post(
                        Uri.parse('http://3.37.103.25:8080/api/users/profile/setup'),
                        headers: {
                          'Authorization': 'Bearer $jwt',
                          'Content-Type': 'application/json',
                        },
                        body: json.encode({
                          'nickname': nickname,
                          'profileImage': profileImage,
                        }),
                      );
                      if (response.statusCode == 200) {
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                          );
                        }
                      } else {
                        String msg = '프로필 설정에 실패했습니다.';
                        try {
                          final data = json.decode(response.body);
                          if (data['message'] != null) msg = data['message'];
                        } catch (_) {}
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4363EA),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500, fontSize: 16),
                      elevation: 0,
                    ),
                    child: const Text('확인'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacter(int index) {
    final isSelected = _selectedIndex == index;
    final double width = isSelected ? 160 : 120;
    final double height = isSelected ? 111 : 83;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          _characters[index]['asset']!,
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
