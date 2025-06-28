import 'package:flutter/material.dart';
import '../../main.dart';
import '../../theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyReviewScreen extends StatefulWidget {
  const MyReviewScreen({super.key});

  @override
  State<MyReviewScreen> createState() => _MyReviewScreenState();
}

class _MyReviewScreenState extends State<MyReviewScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedRating; // null이면 전체
  String? _selectedCategory; // null이면 전체

  final List<String> _categories = [
    '전체', '뮤지컬', '연극', '콘서트', '오페라', '클래식', '무용', '기타'
  ];

  Map<String, dynamic>? _statistics;
  bool _isStatsLoading = true;
  String? _statsError;

  @override
  void initState() {
    super.initState();
    _fetchMyReviews();
    _fetchMyReviewStats();
  }

  Future<void> _fetchMyReviewStats() async {
    setState(() { _isStatsLoading = true; _statsError = null; });
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null) {
      setState(() {
        _statsError = '로그인이 필요합니다.';
        _isStatsLoading = false;
      });
      return;
    }
    final url = Uri.parse('http://3.37.103.25:8080/api/reviews/my/statistics');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        setState(() {
          _statistics = json.decode(response.body);
          _isStatsLoading = false;
        });
      } else {
        setState(() {
          _statsError = '통계 조회 실패: ${response.statusCode}';
          _isStatsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statsError = '에러 발생: $e';
        _isStatsLoading = false;
      });
    }
  }

  Future<void> _fetchMyReviews() async {
    setState(() { _isLoading = true; _error = null; });
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null) {
      setState(() {
        _error = '로그인이 필요합니다.';
        _isLoading = false;
      });
      return;
    }
    Uri url;
    if (_selectedCategory != null && _selectedCategory != '전체') {
      url = Uri.parse('http://3.37.103.25:8080/api/reviews/my/category/${Uri.encodeComponent(_selectedCategory!)}');
    } else if (_selectedRating != null) {
      url = Uri.parse('http://3.37.103.25:8080/api/reviews/my/rating/${_selectedRating}');
    } else {
      url = Uri.parse('http://3.37.103.25:8080/api/reviews/my');
    }
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _reviews = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('마이 리뷰', style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(fontFamily: 'Spoqa Han Sans Neo')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 통계 카드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _isStatsLoading
              ? const Center(child: CircularProgressIndicator())
              : _statsError != null
                ? Text(_statsError!, style: const TextStyle(color: Colors.red))
                : _statistics == null
                  ? const SizedBox.shrink()
                  : Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('총 리뷰 수: ${_statistics!['totalReviews']}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('평균 평점: ${_statistics!['averageRating']}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo')),
                            const SizedBox(height: 8),
                            const Text('평점 분포:', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo')),
                            Row(
                              children: List.generate(5, (i) {
                                final rating = (i+1).toString();
                                final count = _statistics!['ratingDistribution']?[rating] ?? 0;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Text('$rating점: $count', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo')),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text('평점별 보기:', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 15)),
                const SizedBox(width: 12),
                DropdownButton<int?>(
                  value: _selectedRating,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('전체')),
                    ...List.generate(5, (i) => DropdownMenuItem(value: i+1, child: Text('${i+1}점'))),
                  ],
                  onChanged: (val) {
                    setState(() { _selectedRating = val; _selectedCategory = null; });
                    _fetchMyReviews();
                  },
                ),
                const SizedBox(width: 24),
                const Text('카테고리:', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 15)),
                const SizedBox(width: 12),
                DropdownButton<String?>(
                  value: _selectedCategory ?? '전체',
                  items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) {
                    setState(() { _selectedCategory = val; _selectedRating = null; });
                    _fetchMyReviews();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : _reviews.isEmpty
                  ? const Center(
                      child: Text(
                        '작성한 리뷰가 없습니다.',
                        style: TextStyle(color: Colors.grey, fontSize: 16, fontFamily: 'Spoqa Han Sans Neo'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return Center(
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left side - Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: review['performancePoster'] != null
                                      ? Image.network(review['performancePoster'], width: 120, height: 70, fit: BoxFit.cover)
                                      : Image.asset('assets/images/poster1.png', width: 120, height: 70, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 8.0),
                                  // Right side - Text content
                                  Expanded(
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
                                        Text(
                                          '평점: ${review['rating'] ?? '-'}',
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
                                            review['content'] ?? '',
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
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
} 