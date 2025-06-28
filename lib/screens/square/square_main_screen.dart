import 'package:flutter/material.dart';
import 'square_review_detail_screen.dart';
import '../../main.dart';
import 'review_write_screen.dart';
import '../../theme/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
          _isLoading = false;
        });
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
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SquareReviewDetailScreen(review: review),
                          ),
                        );
                      },
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
                                child: (posterUrl != null && posterUrl.isNotEmpty)
                                  ? Image.network(posterUrl, width: 120, height: 70, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/poster1.png', width: 120, height: 70, fit: BoxFit.cover))
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
                                      review['userNickname'] ?? '',
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
                    ),
                  );
                },
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
            _fetchReviews(); // 새로고침
          }
        },
        child: Image.asset('assets/images/review_write_icon.png', width: 24, height: 24),
        tooltip: '리뷰 작성',
      ),
    );
  }
} 