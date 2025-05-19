import 'package:flutter/material.dart';
import 'inventory_mission_screen.dart';
import 'inventory_title_screen.dart';

class InventoryMainScreen extends StatelessWidget {
  const InventoryMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '인벤토리',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('닉네임 : -------'),
              const Text('아이디 : -------'),
              const Text('마이 레벨 : ???'),
              const Text('마이 포인트 : ------ 차감 ???개'),
              const SizedBox(height: 30),
              ListTile(
                title: const Text('미션 목록'),
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
              ListTile(
                title: const Text('마이 배치 / 칭호'),
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
              ListTile(
                title: const Text('설정'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 설정 화면으로 이동
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
