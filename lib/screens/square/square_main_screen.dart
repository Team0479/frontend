import 'package:flutter/material.dart';
import 'square_review_detail_screen.dart';
import '../../main.dart';
import 'review_write_screen.dart';
import '../../theme/colors.dart';

class SquareMainScreen extends StatefulWidget {
  final Map<String, dynamic>? newReview;
  
  const SquareMainScreen({
    super.key,
    this.newReview,
  });

  @override
  State<SquareMainScreen> createState() => _SquareMainScreenState();
}

class _SquareMainScreenState extends State<SquareMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Default sample reviews
  final List<Map<String, dynamic>> _defaultReviews = [
    {
      'performanceTitle': '뮤지컬 라이온킹',
      'reviewTitle': '최고의 뮤지컬 경험',
      'reviewContent': '오늘 라이온킹을 보고 왔습니다. 배우들의 연기와 무대 세트가 정말 훌륭했습니다. 특히 심바 역할을 맡은 배우의 목소리가 매우 인상적이었고, 전체적인 음악과 안무도 완벽했습니다.',
      'views': 120,
      'likes': 45,
      'comments': 8
    },
    {
      'performanceTitle': '콘서트 BTS',
      'reviewTitle': '에너지 넘치는 공연',
      'reviewContent': 'BTS의 콘서트는 정말 에너지가 넘쳤습니다. 멤버들의 열정적인 무대와 관객들의 함성이 어우러져 잊을 수 없는 경험이었습니다. 다음 콘서트도 꼭 가고 싶습니다!',
      'views': 230,
      'likes': 76,
      'comments': 12
    },
    {
      'performanceTitle': '연극 햄릿',
      'reviewTitle': '고전의 재해석',
      'reviewContent': '햄릿의 현대적 재해석이 매우 인상적이었습니다. 전통적인 설정에서 벗어나 현대적 요소를 가미한 연출이 신선했고, 주연 배우의 감정 표현이 섬세했습니다.',
      'views': 85,
      'likes': 32,
      'comments': 5
    },
    {
      'performanceTitle': '오페라 투란도트',
      'reviewTitle': '환상적인 음악의 세계',
      'reviewContent': '푸치니의 투란도트는 정말 환상적이었습니다. 특히 네순 도르마 아리아에서는 전율이 느껴졌고, 무대 디자인과 의상도 화려하고 아름다웠습니다.',
      'views': 95,
      'likes': 41,
      'comments': 7
    },
  ];
  
  late List<Map<String, dynamic>> _reviews;

  @override
  void initState() {
    super.initState();
    
    // Initialize reviews list
    if (globalReviews.isEmpty) {
      // First time loading, use default reviews
      _reviews = List.from(_defaultReviews);
    } else {
      // Use global reviews
      _reviews = List.from(globalReviews);
    }
    
    // Add new review if available
    if (widget.newReview != null) {
      // Add some default values for display
      final Map<String, dynamic> completeReview = {
        ...widget.newReview!,
        'views': 1,
        'likes': 0,
        'comments': 0,
      };
      
      // Add to the beginning of both lists
      setState(() {
        _reviews.insert(0, completeReview);
        globalReviews.insert(0, completeReview);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('플레이어 광장', style: Theme.of(context).appBarTheme.titleTextStyle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: SizedBox(
                width: 348,
                height: 48,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '공연명을 입력하세요',
                    hintStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Color(0xFF9D9D9D)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Image.asset('assets/images/search_icon.png', width: 20, height: 20),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFFE8E9EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFFE8E9EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    children: [
                      const Text('공연명', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 12.0)),
                      const SizedBox(width: 4.0),
                      Icon(Icons.close, size: 16.0, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SquareReviewDetailScreen(review: review),
                      ),
                    );
                  },
                  child: Center(
                    child: Container(
                      width: 354,
                      height: 145,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFFE5EEFA), width: 1.5),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 145,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['performanceTitle'] ?? '제목 없음',
                              style: const TextStyle(
                                fontFamily: 'Spoqa Han Sans Neo',
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left side - Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/images/poster1.png',
                                      width: 120,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  // Right side - Text content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review['reviewTitle'] ?? '',
                                          style: const TextStyle(
                                            fontFamily: 'Spoqa Han Sans Neo',
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2.0),
                                        Expanded(
                                          child: Text(
                                            review['reviewContent'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Spoqa Han Sans Neo',
                                              fontSize: 12.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '조회수 ${review['views']}회 | 좋아요 ${review['likes']}개 | 댓글 ${review['comments']}개',
                              style: const TextStyle(
                                fontFamily: 'Spoqa Han Sans Neo',
                                fontSize: 10.0,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lightBlue,
        shape: const CircleBorder(),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReviewWriteScreen()),
          );
          if (result != null && result is Map<String, dynamic>) {
            final review = {
              ...result,
              'views': 1,
              'likes': 0,
              'comments': 0,
            };
            globalReviews.insert(0, review);
            setState(() {
              _reviews.insert(0, review);
            });
          }
        },
        child: Image.asset('assets/images/review_write_icon.png', width: 24, height: 24),
        tooltip: '리뷰 작성',
      ),
    );
  }
} 