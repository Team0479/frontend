import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'inventory_mission_screen.dart';
import 'inventory_title_screen.dart';
import 'my_review_screen.dart';
import '../../theme/colors.dart';

class InventoryMainScreen extends StatefulWidget {
  const InventoryMainScreen({super.key});

  @override
  State<InventoryMainScreen> createState() => _InventoryMainScreenState();
}

class _InventoryMainScreenState extends State<InventoryMainScreen> {
  String? profileImage;
  String? nickname;
  int? level;
  bool isLoading = true;
  String? jwtToken;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    final localAsset = prefs.getString('my_character_asset');
    setState(() {
      jwtToken = jwt;
    });
    if (jwt == null) return;
    final response = await http.get(
      Uri.parse('http://3.37.103.25:8080/api/users/me/profile'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        profileImage = data['profileImage'];
        nickname = data['nickname'];
        level = data['level'];
        isLoading = false;
        // profileImage가 asset 경로가 아니면 로컬 값 사용
        if (profileImage == null || !(profileImage!.startsWith('assets/'))) {
          if (localAsset != null) profileImage = localAsset;
        }
      });
    } else {
      setState(() {
        isLoading = false;
        if (localAsset != null) profileImage = localAsset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지', style: Theme.of(context).appBarTheme.titleTextStyle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // 프로필 이미지와 정보 카드 (Stack)
            Stack(
              clipBehavior: Clip.none,
              children: [
                
                // 정보 카드
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 50),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.blue, width: 1),
                    ),
                    elevation: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            nickname ?? '닉네임',
                            style: const TextStyle(
                              fontFamily: 'Spoqa Han Sans Neo',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('마이 레벨 : Lv. ${level ?? "??"}',
                            style: const TextStyle(
                              fontFamily: 'Spoqa Han Sans Neo',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                // 프로필 이미지 (카드 위에 겹치게)
                Positioned(
                  top: -10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Always show profile_bg.png as background
                          Image.asset('assets/images/profile_bg.png', width: 140, height: 140, fit: BoxFit.cover),
                          // If logged in (jwtToken != null) and profileImage != null and not profile_bg, show character image smaller
                          if (jwtToken != null && profileImage != null && profileImage != 'assets/images/profile_bg.png')
                            Positioned(
                              top: 22, // Centered inside the bg
                              left: 22,
                              right: 22,
                              bottom: 22,
                              child: profileImage!.startsWith('assets/')
                                ? Image.asset(profileImage!, width: 56, height: 56, fit: BoxFit.contain)
                                : Image.network(profileImage!, width: 56, height: 56, fit: BoxFit.contain),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // 미션 목록
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.blue, width: 1),
              ),
              elevation: 0.0,
              child: ListTile(
                title: Text('미션 목록', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InventoryMissionScreen(),
                    ),
                  );
                },
              ),
            ),
            // 마이 칭호
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.blue, width: 1),
              ),
              elevation: 0.0,
              child: ListTile(
                title: Text('마이 칭호', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InventoryTitleScreen(),
                    ),
                  );
                },
              ),
            ),
            // 마이 리뷰
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.blue, width: 1),
              ),
              elevation: 0.0,
              child: ListTile(
                title: Text('마이 리뷰', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyReviewScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
