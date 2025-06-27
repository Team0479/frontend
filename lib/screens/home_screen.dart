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
              title: Text('홈', style: Theme.of(context).appBarTheme.titleTextStyle),
              backgroundColor: Colors.white,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: AnimatedBuilder(
                  animation: tabController,
                  builder: (context, _) {
                    int selected = tabController.index;
                    final tabTitles = [
                      '베스트 플레이어',
                      '인기 플레이',
                      '베스트 리뷰',
                      '오늘의 플레이',
                    ];
                    return Container(
                      color: Colors.transparent,
                      height: 48,
                      child: Row(
                        children: List.generate(4, (i) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => tabController.animateTo(i),
                              child: Container(
                                color: selected == i ? Colors.white : AppColors.blue,
                                alignment: Alignment.center,
                                child: Text(
                                  tabTitles[i],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Spoqa Han Sans Neo',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
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
      final categories = [
        '뮤지컬', '콘서트', '스포츠', '전시/행사', '클래식/무용', '아동/가족', '연극', '레저/캠핑'
      ];
      final posters = [
        'assets/images/poster1.png',
        'assets/images/poster2.png',
        'assets/images/poster3.png',
        'assets/images/poster4.png',
      ];
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 연파랑색 카테고리 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(3, 3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: categories.map((cat) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cat,
                    style: const TextStyle(
                      fontFamily: 'Spoqa Han Sans Neo',
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              itemCount: 10,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 18,
                childAspectRatio: 0.45,
              ),
              itemBuilder: (context, idx) {
                final poster = posters[idx % posters.length];
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 0.7,
                            child: Image.asset(
                              poster,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                idx == 0
                                    ? 'assets/images/ranking_blue.png'
                                    : 'assets/images/ranking_gray.png',
                                width: 28,
                                height: 28,
                              ),
                              Text(
                                '${idx + 1}',
                                style: const TextStyle(
                                  fontFamily: 'Spoqa Han Sans Neo',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '공연 제목 : ~~~~~~~~~~',
                            style: TextStyle(
                              fontFamily: 'Spoqa Han Sans Neo',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '공연 장소 : ~~~~~~~~',
                            style: TextStyle(
                              fontFamily: 'Spoqa Han Sans Neo',
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '공연 기간 : ~~~~~~~~',
                            style: TextStyle(
                              fontFamily: 'Spoqa Han Sans Neo',
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '예매율 : ~',
                            style: TextStyle(
                              fontFamily: 'Spoqa Han Sans Neo',
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '공연 설명 : ~~~~~~~~',
                            style: TextStyle(
                              fontFamily: 'Spoqa Han Sans Neo',
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    } else if (tabName == '베스트 리뷰') {
      final reviews = List.generate(10, (i) => i + 1);
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: reviews.length,
          separatorBuilder: (context, idx) => const SizedBox(height: 20),
          itemBuilder: (context, idx) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 번호 배지 (이미지+숫자)
                Container(
                  width: 25,
                  height: 25,
                  margin: const EdgeInsets.only(right: 12, top: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        idx == 0
                            ? 'assets/images/ranking_blue.png'
                            : 'assets/images/ranking_gray.png',
                        width: 25,
                        height: 25,
                      ),
                      Text(
                        '${idx + 1}',
                        style: const TextStyle(
                          fontFamily: 'Spoqa Han Sans Neo',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // 리뷰 카드
                Container(
                  width: 325,
                  height: 122,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightBlue, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(3, 3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '리뷰 제목',
                        style: TextStyle(
                          fontFamily: 'Spoqa Han Sans Neo',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              'assets/images/poster1.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('내용 미리보기',
                                  style: TextStyle(
                                    fontFamily: 'Spoqa Han Sans Neo',
                                    fontWeight: FontWeight.w300,
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 1),
                                Text('~~~~~~~~~~~~~~~~~~~\n~~~~~~~~~~~~~~~~~~~~~',
                                  style: TextStyle(
                                    fontFamily: 'Spoqa Han Sans Neo',
                                    fontWeight: FontWeight.w300,
                                    fontSize: 8,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text('조회수 ?회 | 좋아요 ??개 | 댓글 ??개',
                        style: TextStyle(
                          fontFamily: 'Spoqa Han Sans Neo',
                          fontWeight: FontWeight.w300,
                          fontSize: 8,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else if (tabName == '오늘의 플레이') {
      final cards = List.generate(4, (i) => i + 1);
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            // 안내 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: const Text(
                '[유저 닉네임] 플레이어의\n메인 장르는 [장르명]입니다.\n맞춤 플레이를 추천해 드릴게요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Galmuri14',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 18),
            // 공연 추천 카드
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: GridView.builder(
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.48,
                  ),
                  itemBuilder: (context, idx) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          //borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 0.7,
                            child: Image.asset(
                              'assets/images/poster1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '공연 제목 : ~~~~~~~~~~',
                          style: const TextStyle(
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '공연 장소 : ~~~~~~~~',
                          style: const TextStyle(
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '공연 기간 : ~~~~~~~~',
                          style: const TextStyle(
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '예매율 : ~',
                          style: const TextStyle(
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '공연 설명 : ~~~~~~~~',
                          style: const TextStyle(
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    );
                  },
                ),
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
              // 번호 배지 (이미지+숫자)
              Container(
                width: 25,
                height: 25,
                margin: const EdgeInsets.only(right: 12, top: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      index == 0
                          ? 'assets/images/ranking_blue.png'
                          : 'assets/images/ranking_gray.png',
                      width: 25,
                      height: 25,
                    ),
                    Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'Spoqa Han Sans Neo',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // 리뷰 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('리뷰 제목', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/poster1.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('내용 미리보기',
                                  style: TextStyle(
                                    fontFamily: 'Spoqa Han Sans Neo',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('~~~~~~~~~~~~~~~~~~~\n~~~~~~~~~~~~~~~~~~~~~\n~~~~~~~~~~~~~~~~~~~',
                                  style: TextStyle(
                                    fontFamily: 'Spoqa Han Sans Neo',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('조회수 ?회 | 좋아요 ??개 | 댓글 ??개',
                      style: TextStyle(
                        fontFamily: 'Spoqa Han Sans Neo',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
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