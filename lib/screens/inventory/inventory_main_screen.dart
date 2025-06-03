import 'package:flutter/material.dart';
import 'inventory_mission_screen.dart';
import 'inventory_title_screen.dart';
import 'my_review_screen.dart';
import '../../theme/colors.dart';

class InventoryMainScreen extends StatelessWidget {
  const InventoryMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지', style: Theme.of(context).appBarTheme.titleTextStyle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.navBarBackground,
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
                  margin: const EdgeInsets.only(top: 50), // 프로필 이미지 반지름만큼 아래로
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20), // 위에 여백 넉넉히
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('닉네임 : ~~~~~~'),
                          SizedBox(height: 4),
                          Text('아이디 : ~~~~~~'),
                          SizedBox(height: 4),
                          Text('마이 레벨 : ???'),
                          SizedBox(height: 4),
                          Text('마이 랭킹 : ~~~~~ 차트 ???위'),
                        ],
                      ),
                    ),
                  ),
                ),
                // 프로필 이미지 (카드 위에 겹치게)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
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
              ),
              elevation: 0.5,
              child: ListTile(
                title: Text('미션 목록', style: TextStyle(fontFamily: 'DungGeunMo')),
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
              ),
              elevation: 0.5,
              child: ListTile(
                title: Text('마이 칭호', style: TextStyle(fontFamily: 'DungGeunMo')),
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
              ),
              elevation: 0.5,
              child: ListTile(
                title: Text('마이 리뷰', style: TextStyle(fontFamily: 'DungGeunMo')),
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
