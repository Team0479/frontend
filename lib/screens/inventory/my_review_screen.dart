import 'package:flutter/material.dart';
import '../../main.dart';
import '../../theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart'; // ReviewCard 위젯을 사용하기 위해 import

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
          _reviews.sort((a, b) {
            final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(1970);
            final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(1970);
            return bDate.compareTo(aDate); // 최신순
          });
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text('평점', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black)),
                    const SizedBox(width: 8),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightBlue, width: 1.2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: _selectedRating,
                          icon: const Icon(Icons.expand_more, color: Colors.black),
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('전체', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
                            ...List.generate(5, (i) => DropdownMenuItem(value: i+1, child: Text('${i+1}점', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo')))),
                          ],
                          onChanged: (val) {
                            setState(() { _selectedRating = val; _selectedCategory = null; });
                            _fetchMyReviews();
                          },
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    const Text('카테고리', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black)),
                    const SizedBox(width: 8),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightBlue, width: 1.2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _selectedCategory ?? '전체',
                          icon: const Icon(Icons.expand_more, color: Colors.black),
                          isDense: true,
                          isExpanded: false,
                          alignment: Alignment.centerLeft,
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                          items: _categories.map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat, style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo')),
                          )).toList(),
                          onChanged: (val) {
                            setState(() { _selectedCategory = val; _selectedRating = null; });
                            _fetchMyReviews();
                          },
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
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
                        return ReviewCard(
                          review: review,
                          posterUrl: review['performancePoster'],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
} 