import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

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

class ChartTab extends StatefulWidget {
  final String tabName;
  const ChartTab({super.key, required this.tabName});

  @override
  State<ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  List<dynamic> _items = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'musicals';
  final Map<String, String> _categoryMap = {
    '뮤지컬': 'musicals',
    '콘서트': 'concerts',
    '스포츠': 'sports',
    '전시/행사': 'exhibitions',
    '클래식/무용': 'classics_dances',
    '아동/가족': 'kids_family',
    '연극': 'plays',
    '레저/캠핑': 'leisure_camping',
  };
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _fetchNickname();
    _fetchData();
  }

  Future<void> _fetchNickname() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
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
        _nickname = data['nickname'];
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; _error = null; });
    String? url;
    Map<String, String>? headers;
    
    if (widget.tabName == '베스트 플레이어') {
      url = 'http://3.37.103.25:8080/api/plaza/reviews';
    } else if (widget.tabName == '오늘의 플레이') {
      url = 'http://3.37.103.25:8080/api/today-plays/user/1';
    } else if (widget.tabName == '인기 플레이') {
      url = 'http://3.37.103.25:8080/api/popular-plays/$_selectedCategory';
    } else if (widget.tabName == '베스트 리뷰') {
      url = 'http://3.37.103.25:8080/api/best-reviews';
    }
    
    if (url == null) {
      setState(() { _isLoading = false; _items = []; });
      return;
    }
    
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> processedData = [];
        if (widget.tabName == '베스트 플레이어') {
          if (data is List) {
            Map<String, Map<String, dynamic>> userStats = {};
            Map<String, int> userFirstReviewId = {};
            
            for (var review in data) {
              String userId = review['userId']?.toString() ?? '';
              String userNickname = review['userNickname'] ?? '익명';
              int reviewId = review['reviewId'] ?? review['id'];
              
              if (!userStats.containsKey(userId)) {
                userStats[userId] = {
                  'userId': userId,
                  'userNickname': userNickname,
                  'profileImage': null, // 초기값
                  'reviewCount': 0,
                  'totalLikes': 0,
                  'totalRating': 0,
                  'ratingCount': 0,
                };
                userFirstReviewId[userId] = reviewId; // 첫 번째 리뷰 ID 저장
              }
              userStats[userId]!['reviewCount'] = (userStats[userId]!['reviewCount'] ?? 0) + 1;
              userStats[userId]!['totalLikes'] = (userStats[userId]!['totalLikes'] ?? 0) + (review['likeCount'] ?? 0);
              if (review['rating'] != null) {
                userStats[userId]!['totalRating'] = (userStats[userId]!['totalRating'] ?? 0) + (review['rating'] ?? 0);
                userStats[userId]!['ratingCount'] = (userStats[userId]!['ratingCount'] ?? 0) + 1;
              }
            }
            processedData = userStats.values.toList();
            processedData.sort((a, b) {
              int aScore = (a['reviewCount'] ?? 0) * 10 + (a['totalLikes'] ?? 0);
              int bScore = (b['reviewCount'] ?? 0) * 10 + (b['totalLikes'] ?? 0);
              return bScore.compareTo(aScore);
            });
            
            // 상위 3명의 프로필 이미지 조회 (리뷰 상세 API 사용)
            for (int i = 0; i < processedData.length && i < 3; i++) {
              final user = processedData[i];
              final userId = user['userId'];
              final reviewId = userFirstReviewId[userId];
              
              if (userId != null && reviewId != null) {
                try {
                  final reviewDetailResponse = await http.get(
                    Uri.parse('http://3.37.103.25:8080/api/reviews/$reviewId'),
                    headers: {
                      'Content-Type': 'application/json',
                    },
                  );
                  if (reviewDetailResponse.statusCode == 200) {
                    final reviewDetail = json.decode(reviewDetailResponse.body);
                    processedData[i]['profileImage'] = reviewDetail['userProfileImage'];
                    debugPrint('유저 $userId 리뷰 $reviewId 상세 조회 성공: ${reviewDetail['userProfileImage']}');
                  } else {
                    debugPrint('유저 $userId 리뷰 $reviewId 상세 조회 실패: ${reviewDetailResponse.statusCode}');
                    // 실패 시 기본 캐릭터 이미지 사용
                    processedData[i]['profileImage'] = 'assets/images/character_blue.png';
                  }
                } catch (e) {
                  debugPrint('유저 $userId 리뷰 $reviewId 상세 조회 에러: $e');
                  // 에러 시 기본 캐릭터 이미지 사용
                  processedData[i]['profileImage'] = 'assets/images/character_blue.png';
                }
              }
            }
          }
        } else {
          processedData = data is List ? data : [];
        }
        if (widget.tabName == '오늘의 플레이') {
          debugPrint('오늘의 플레이 데이터: ' + processedData.toString());
        }
        if (widget.tabName == '인기 플레이') {
          debugPrint('인기플레이(${_selectedCategory}) 데이터: ' + processedData.toString());
        }
        setState(() {
          _items = processedData;
          _isLoading = false;
        });
        
        // 베스트 플레이어 탭에서 1,2,3위 유저 정보 로그 출력
        if (widget.tabName == '베스트 플레이어' && processedData.isNotEmpty) {
          debugPrint('=== 베스트 플레이어 1,2,3위 유저 정보 ===');
          for (int i = 0; i < processedData.length && i < 3; i++) {
            final user = processedData[i];
            debugPrint('${i + 1}위 - 닉네임: ${user['userNickname']}, 프로필이미지: ${user['profileImage']}');
          }
          debugPrint('=====================================');
        }
      } else {
        setState(() {
          _error = '조회 실패: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '에러 발생: $e';
        _isLoading = false;
      });
    }
  }

  String _getMainGenre(List<dynamic> reviews) {
    if (reviews.isEmpty) {
      final random = Random();
      return ['뮤지컬', '콘서트'][random.nextInt(2)];
    }
    final genreCount = <String, int>{};
    for (final review in reviews) {
      final genre = review['category'] ?? '';
      if (genre.isNotEmpty) {
        genreCount[genre] = (genreCount[genre] ?? 0) + 1;
      }
    }
    if (genreCount.isEmpty) {
      final random = Random();
      return ['뮤지컬', '콘서트'][random.nextInt(2)];
    }
    return genreCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    final tabName = widget.tabName;
    if (tabName == '인기 플레이') {
      final categories = [
        '뮤지컬', '콘서트', '스포츠', '전시/행사', '클래식/무용', '아동/가족', '연극', '레저/캠핑'
      ];
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
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
                children: categories.map((cat) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = _categoryMap[cat]!;
                    });
                    _fetchData();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedCategory == _categoryMap[cat] ? Colors.white : AppColors.blue,
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
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                  : _items.isEmpty
                    ? const Center(child: Text('데이터가 없습니다.', style: TextStyle(color: Colors.grey)))
                    : GridView.builder(
                        itemCount: _items.length,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 18,
                          childAspectRatio: 0.55,
                        ),
                        itemBuilder: (context, idx) {
                          final perf = _items[idx];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: AspectRatio(
                                      aspectRatio: 0.7,
                                      child: (perf['imageUrl'] != null && perf['imageUrl'].toString().isNotEmpty)
                                        ? Image.network(
                                            perf['imageUrl'],
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset('assets/images/poster1.png', fit: BoxFit.contain);
                                            },
                                          )
                                        : Image.asset('assets/images/poster1.png', fit: BoxFit.contain),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    perf['title'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'Spoqa Han Sans Neo',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    perf['venue'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'Spoqa Han Sans Neo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${perf['startDate'] ?? ''} ~ ${perf['endDate'] ?? ''}',
                                    style: const TextStyle(
                                      fontFamily: 'Spoqa Han Sans Neo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
            ),
          ],
        ),
      );
    } else if (tabName == '베스트 리뷰') {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
            : _items.isEmpty
              ? const Center(child: Text('데이터가 없습니다.', style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _items.length,
                  separatorBuilder: (context, idx) => const SizedBox(height: 20),
                  itemBuilder: (context, idx) {
                    final review = _items[idx];
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
                        Expanded(
                          child: Container(
                            height: 122,
                            margin: const EdgeInsets.only(right: 8.0),
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
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['performanceTitle'] ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'Spoqa Han Sans Neo',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: (() {
                                        final imgUrl = review['performanceImageUrl'] ?? review['posterUrl'] ?? review['reviewImageUrl'];
                                        if (imgUrl != null && imgUrl.toString().isNotEmpty) {
                                          return Image.network(
                                            imgUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset('assets/images/poster1.png', width: 60, height: 60, fit: BoxFit.cover);
                                            },
                                          );
                                        } else {
                                          return Image.asset('assets/images/poster1.png', width: 60, height: 60, fit: BoxFit.cover);
                                        }
                                      })(),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review['content'] ?? '',
                                            style: const TextStyle(
                                              fontFamily: 'Spoqa Han Sans Neo',
                                              fontWeight: FontWeight.w300,
                                              fontSize: 10,
                                              color: Colors.black,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            '평점: ${review['rating'] ?? '-'} | 좋아요: ${review['likeCount'] ?? '-'}',
                                            style: const TextStyle(
                                              fontFamily: 'Spoqa Han Sans Neo',
                                              fontWeight: FontWeight.w300,
                                              fontSize: 8,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 1),
                                Text('작성자: ${review['userNickname'] ?? ''} | 작성일: ${review['createdAt']?.toString().substring(0, 10) ?? ''}',
                                  style: const TextStyle(
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
                        ),
                      ],
                    );
                  },
                ),
      );
    } else if (tabName == '오늘의 플레이') {
      final mainGenre = _getMainGenre(_items);
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
            : _items.isEmpty
              ? const Center(child: Text('데이터가 없습니다.', style: TextStyle(color: Colors.grey)))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset('assets/images/recommend_bg.png', fit: BoxFit.cover),
                            Center(
                              child: Text(
                                (_nickname ?? '플레이어') + ' 플레이어의 메인 장르는 ' + mainGenre + '입니다.\n맞춤 플레이를 추천해 드릴게요!',
                                style: const TextStyle(
                                  fontFamily: 'Galmuri14',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 18,
                          childAspectRatio: 0.55,
                        ),
                        itemBuilder: (context, idx) {
                          final perf = _items[idx];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AspectRatio(
                                  aspectRatio: 0.7,
                                  child: (() {
                                    final imgUrl = perf['imageUrl'] ?? perf['posterUrl'] ?? perf['performanceImageUrl'];
                                    if (imgUrl != null && imgUrl.toString().isNotEmpty) {
                                      return Image.network(
                                        imgUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset('assets/images/poster1.png', fit: BoxFit.contain);
                                        },
                                      );
                                    } else {
                                      return Image.asset('assets/images/poster1.png', fit: BoxFit.contain);
                                    }
                                  })(),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    perf['title'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'Spoqa Han Sans Neo',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    perf['venue'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'Spoqa Han Sans Neo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${perf['startDate'] ?? ''} ~ ${perf['endDate'] ?? ''}',
                                    style: const TextStyle(
                                      fontFamily: 'Spoqa Han Sans Neo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
      );
    } else {
      // 베스트 플레이어 탭 - Podium UI
      return Container(
        width: double.infinity,
        height: 340,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/podium3.png'),
            fit: BoxFit.cover,
            alignment: Alignment(0, -0.3),
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : _items.isEmpty
                    ? const Center(child: Text('데이터가 없습니다.', style: TextStyle(color: Colors.grey)))
                    : Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // 2위 (왼쪽)
                          if (_items.length > 1)
                            Positioned(
                              left: 88,
                              bottom: 114,
                              child: _PodiumUser(
                                rank: 2,
                                nickname: _items[1]['userNickname'] ?? '익명',
                                profileImage: _items[1]['profileImage'],
                                size: 45,
                                spacing: 16,
                              ),
                            ),
                          // 1위 (가운데)
                          if (_items.isNotEmpty)
                            Positioned(
                              bottom: 193,
                              left: MediaQuery.of(context).size.width / 2 - 29,
                              child: _PodiumUser(
                                rank: 1,
                                nickname: _items[0]['userNickname'] ?? '익명',
                                profileImage: _items[0]['profileImage'],
                                size: 61,
                                spacing: 22,
                              ),
                            ),
                          // 3위 (오른쪽)
                          if (_items.length > 2)
                            Positioned(
                              right: 83,
                              bottom: 90,
                              child: _PodiumUser(
                                rank: 3,
                                nickname: _items[2]['userNickname'] ?? '익명',
                                profileImage: _items[2]['profileImage'],
                                size: 45,
                                spacing: 8,
                              ),
                            ),
                        ],
                      ),
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

// PodiumUser 위젯 추가
class _PodiumUser extends StatelessWidget {
  final int rank;
  final String nickname;
  final String? profileImage;
  final double size;
  final double spacing;
  const _PodiumUser({
    required this.rank, 
    required this.nickname, 
    this.profileImage, 
    this.size = 100,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: profileImage != null && profileImage!.isNotEmpty
              ? (profileImage!.startsWith('assets/')
                  ? Image.asset(profileImage!, fit: BoxFit.contain)
                  : Image.network(profileImage!, fit: BoxFit.contain, errorBuilder: (c, e, s) => Image.asset('assets/images/character_blue.png', fit: BoxFit.contain)))
              : Image.asset('assets/images/character_blue.png', fit: BoxFit.contain),
        ),
        SizedBox(height: spacing),
        Text(
          nickname,
          style: const TextStyle(
            fontFamily: 'Galmuri14',
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
} 