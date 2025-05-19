import 'package:flutter/material.dart';

class InventoryMissionScreen extends StatelessWidget {
  const InventoryMissionScreen({super.key});

  Widget _buildMissionItem(String title, String progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            progress,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('미션 목록'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildMissionItem('캘린더에 일정 등록하기', '0 / 3'),
              const Divider(),
              _buildMissionItem('관람 기록 등록하기', '0 / 3'),
              const Divider(),
              _buildMissionItem('광장에 후기 쓰기', '0 / 3'),
              const Divider(),
              _buildMissionItem('다른 플레이어 후기에 댓글 남기기', '0 / 5'),
              const Divider(),
              _buildMissionItem('다른 플레이어 후기에 좋아요 누르기', '0 / 5'),
            ],
          ),
        ),
      ),
    );
  }
}
