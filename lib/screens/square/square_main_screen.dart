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
        backgroundColor: AppColors.navBarBackground,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '공연명을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      suffixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ],
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
                      const Text('공연명', style: TextStyle(fontSize: 12.0)),
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
              padding: const EdgeInsets.all(16.0),
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
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['performanceTitle'] ?? '제목 없음',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side - Image
                            Container(
                              height: 100.0,
                              width: 100.0,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(width: 12.0),
                            // Right side - Text content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review['reviewTitle'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    review['reviewContent'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          '조회수 ${review['views']}회 | 좋아요 ${review['likes']}개 | 댓글 ${review['comments']}개',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBarBackground,
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
        child: const Icon(Icons.edit),
        tooltip: '리뷰 작성',
      ),
    );
  }
} 