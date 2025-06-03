import 'package:flutter/material.dart';
import '../theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text('홈', style: const TextStyle(
                fontFamily: 'DungGeunMo',
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )),
              backgroundColor: AppColors.navBarBackground,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: AnimatedBuilder(
                  animation: tabController,
                  builder: (context, _) {
                    int selected = tabController.index;
                    final tabTitles = [
                      '베스트\n플레이어',
                      '인기\n플레이',
                      '베스트\n리뷰',
                      '오늘의\n플레이',
                    ];
                    return Container(
                      color: const Color(0xFFDEE6F1),
                      height: 48,
                      child: Row(
                        children: List.generate(4, (i) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => tabController.animateTo(i),
                              child: Container(
                                color: selected == i ? AppColors.tabSelected : const Color(0xFFDEE6F1),
                                alignment: Alignment.center,
                                child: Text(
                                  tabTitles[i],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'DungGeunMo',
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
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
          );
        },
      ),
    );
  }
}

class ChartTab extends StatelessWidget {
  final String tabName;
  const ChartTab({super.key, required this.tabName});

  @override
  Widget build(BuildContext context) {
    if (tabName == '인기 플레이') {
      // 피그마 스타일의 인기 플레이 탭
      final categories = [
        '뮤지컬', '콘서트', '스포츠', '전시/행사', '클래식/무용', '아동/가족', '연극', '레저/캠핑'
      ];
      final cards = List.generate(10, (i) => i + 1);
      return Container(
        color: AppColors.lightBlue,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 버튼 (가운데 정렬)
            Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) => Chip(
                  label: Text(cat, style: const TextStyle(fontFamily: 'DungGeunMo', fontSize: 11)),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // 2x2 공연 카드 (10개, 스크롤 가능)
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
                // 스크롤 가능하게 physics 기본값 사용
                children: cards.map((num) => _PlayCard(index: num)).toList(),
              ),
            ),
          ],
        ),
      );
    } else if (tabName == '베스트 리뷰') {
      // 피그마 스타일의 베스트 리뷰 탭
      final reviews = List.generate(4, (i) => i + 1);
      return Container(
        color: AppColors.lightBlue,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: ListView.separated(
          itemCount: reviews.length,
          separatorBuilder: (context, idx) => const SizedBox(height: 16),
          itemBuilder: (context, idx) => _ReviewCard(index: reviews[idx]),
        ),
      );
    } else if (tabName == '오늘의 플레이') {
      // 피그마 스타일의 오늘의 플레이 탭
      final cards = List.generate(4, (i) => i + 1);
      return Container(
        color: AppColors.lightBlue,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '[유저 닉네임] 플레이어의\n메인 장르는 [장르명]입니다.\n맞춤 플레이를 추천해 드릴게요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 0.7,
                children: cards.map((num) => _TodayPlayCard(index: num)).toList(),
              ),
            ),
          ],
        ),
      );
    } else {
      // 기존 스타일 (배경 이미지)
      return Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/podium3.png', // 이미지 경로
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    }
  }
}

class _PlayCard extends StatelessWidget {
  final int index;
  const _PlayCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 번호와 이미지
          Stack(
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Icon(Icons.image, size: 60, color: Colors.white70),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Text('$index', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('공연 제목 : ~~~~~~~~~~', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('공연 장소 : ~~~~~~~~', style: TextStyle(fontSize: 12)),
                Text('공연 기간 : ~~~~~~~~', style: TextStyle(fontSize: 12)),
                Text('예매율 : ~', style: TextStyle(fontSize: 12)),
                Text('공연 설명 : ~~~~~~~~', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int index;
  const _ReviewCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.lightBlue,
                child: Text('$index', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              const SizedBox(width: 12),
              // 리뷰 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('리뷰 제목', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 썸네일
                        Container(
                          width: 70,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 내용 미리보기
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Align(
                                alignment: Alignment.topRight,
                                child: Text('내용 미리보기', style: TextStyle(fontSize: 12, color: Colors.black54)),
                              ),
                              SizedBox(height: 2),
                              Text('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',
                                style: TextStyle(fontSize: 12, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 하단 통계
          const Text('조회수 2개 | 좋아요 2개 | 댓글 2개',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _TodayPlayCard extends StatelessWidget {
  final int index;
  const _TodayPlayCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('공연 제목 : ~~~~~~~~~~', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const Text('공연 장소 : ~~~~~~~~', style: TextStyle(fontSize: 12)),
        const Text('공연 기간 : ~~~~~~~~', style: TextStyle(fontSize: 12)),
        const Text('예매율 : ~', style: TextStyle(fontSize: 12)),
        const Text('공연 설명 : ~~~~~~~~', style: TextStyle(fontSize: 12)),
      ],
    );
  }
} 