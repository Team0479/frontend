import 'package:flutter/material.dart';
import 'square_review_detail_screen.dart';
import '../../main.dart';
import 'review_write_screen.dart';
import '../../theme/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../home_screen.dart'; // ReviewCard 위젯을 사용하기 위해 import

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
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String? _error;
  Map<int, String> _posterCache = {}; // performanceId -> posterUrl

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() { _isLoading = true; _error = null; });
    final url = Uri.parse('http://3.37.103.25:8080/api/plaza/reviews');
    try {
      final response = await http.get(url);
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
        // 리뷰 정보 로그 출력
        for (final review in _reviews) {
          debugPrint('광장 리뷰 정보: ' + review.toString());
        }
        // 리뷰별 공연 포스터 미리 받아오기
        for (final review in _reviews) {
          final perfId = review['performanceId'];
          if (perfId != null && !_posterCache.containsKey(perfId)) {
            _fetchPerformancePoster(perfId);
          }
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

  Future<void> _fetchPerformancePoster(int performanceId) async {
    final url = Uri.parse('http://3.37.103.25:8080/api/calendar/performances/$performanceId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final posterUrl = data['posterUrl'] ?? data['imageUrl'] ?? data['performanceImageUrl'];
        if (posterUrl != null && posterUrl.toString().isNotEmpty) {
          setState(() {
            _posterCache[performanceId] = posterUrl;
          });
        }
      }
    } catch (e) {
      // ignore error
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
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : _reviews.isEmpty
            ? const Center(child: Text('등록된 리뷰가 없습니다.', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final review = _reviews[index];
                  final perfId = review['performanceId'];
                  final posterUrl = perfId != null ? _posterCache[perfId] : null;
                  return ReviewCard(
                    review: review,
                    posterUrl: posterUrl,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SquareReviewDetailScreen(review: review),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lightBlue,
        shape: const CircleBorder(),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReviewWriteScreen()),
          );
          _fetchReviews(); // 무조건 새로고침
        },
        child: Image.asset('assets/images/review_write_icon.png', width: 24, height: 24),
        tooltip: '리뷰 작성',
      ),
    );
  }
} 