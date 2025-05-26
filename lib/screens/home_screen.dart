import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('홈', style: Theme.of(context).appBarTheme.titleTextStyle),
          bottom: const TabBar(
            tabs: [
              Tab(text: '베스트 플레이어'),
              Tab(text: '인기 플레이'),
              Tab(text: '베스트 리뷰'),
              Tab(text: '오늘의 플레이'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ChartTab(tabName: '베스트 플레이어'),
            ChartTab(tabName: '인기 플레이'),
            ChartTab(tabName: '베스트 리뷰'),
            ChartTab(tabName: '오늘의 플레이'),
          ],
        ),
      ),
    );
  }
}

class ChartTab extends StatelessWidget {
  final String tabName;
  const ChartTab({super.key, required this.tabName});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 배경 이미지
        Positioned.fill(
          child: Image.asset(
            'assets/images/podium.jpeg', // 이미지 경로
            fit: BoxFit.cover,
          ),
        ),
        // 차트 내용 (예시)
        Center(
          child: Text(
            '$tabName 차트',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black, // 배경에 따라 색상 조정
            ),
          ),
        ),
      ],
    );
  }
} 