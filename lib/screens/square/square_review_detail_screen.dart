import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SquareReviewDetailScreen extends StatefulWidget {
  final Map<String, dynamic> review;
  
  const SquareReviewDetailScreen({
    super.key, 
    required this.review,
  });

  @override
  State<SquareReviewDetailScreen> createState() => _SquareReviewDetailScreenState();
}

class _SquareReviewDetailScreenState extends State<SquareReviewDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;
  int _likeCount = 0;
  List<Map<String, dynamic>> _comments = [];
  final String _currentUser = '플레이어 닉네임'; // 임시 사용자 이름

  Map<String, dynamic>? _reviewDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReviewDetail();
    _fetchComments();
  }

  Future<void> _fetchReviewDetail() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final reviewId = widget.review['reviewId'] ?? widget.review['id'];
      final url = Uri.parse('http://3.37.103.25:8080/api/reviews/$reviewId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final detail = json.decode(response.body);
        setState(() {
          _reviewDetail = detail;
          _isLoading = false;
          _likeCount = detail['likeCount'] ?? 0;
          _isLiked = detail['isLiked'] ?? false;
        });
      } else {
        setState(() {
          _error = '조회 실패: \\${response.statusCode}';
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

  Future<void> _fetchComments() async {
    final reviewId = widget.review['reviewId'] ?? widget.review['id'];
    final url = Uri.parse('http://3.37.103.25:8080/api/comments/review/$reviewId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _comments = data.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      // ignore error
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
      return;
    }
    final reviewId = widget.review['reviewId'] ?? widget.review['id'];
    // userId 가져오기
    int? userId;
    try {
      final profileResponse = await http.get(
        Uri.parse('http://3.37.103.25:8080/api/users/me/profile'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );
      if (profileResponse.statusCode == 200) {
        final profileData = json.decode(profileResponse.body);
        userId = profileData['userId'] ?? profileData['id'];
      }
    } catch (e) {}
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('userId를 불러올 수 없습니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
      return;
    }
    final url = Uri.parse('http://3.37.103.25:8080/api/reviews/$reviewId/like');
    final body = jsonEncode({'userId': userId});
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      print('좋아요 요청 status: \\${response.statusCode}, body: \\${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('좋아요 실패: \\${response.statusCode}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 에러: $e', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
      return;
    }
    final reviewId = widget.review['reviewId'] ?? widget.review['id'];
    // userId 가져오기
    int? userId;
    try {
      final profileResponse = await http.get(
        Uri.parse('http://3.37.103.25:8080/api/users/me/profile'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );
      if (profileResponse.statusCode == 200) {
        final profileData = json.decode(profileResponse.body);
        userId = profileData['userId'] ?? profileData['id'];
      }
    } catch (e) {}
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('userId를 불러올 수 없습니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
      return;
    }
    final url = Uri.parse('http://3.37.103.25:8080/api/comments');
    final body = jsonEncode({
      'reviewId': reviewId,
      'userId': userId,
      'content': _commentController.text.trim(),
    });
    print('댓글 등록 요청 body: $body');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      print('댓글 등록 응답 status: \\${response.statusCode}, body: \\${response.body}');
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 등록되었습니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
        );
        setState(() {
          _commentController.clear();
        });
        await _fetchComments();
        // 댓글 작성 후 미션 목록 조회 및 로그 출력
        await _fetchAndLogMissions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 등록 실패: \\${response.statusCode}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
    }
  }

  // 미션 목록을 불러오고 로그에 출력하는 함수
  Future<void> _fetchAndLogMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null) return;
    final url = Uri.parse('http://3.37.103.25:8080/api/missions/me');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      });
      print('미션 응답: ' + response.body);
    } catch (e) {
      print('미션 조회 에러: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('리뷰 상세보기', style: Theme.of(context).appBarTheme.titleTextStyle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info section
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              _buildProfileImage(_reviewDetail?['userProfileImage'], radius: 30, iconSize: 24),
                              const SizedBox(width: 16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _reviewDetail?['userNickname'] ?? '플레이어 닉네임',
                                    style: const TextStyle(
                                      fontFamily: 'Spoqa Han Sans Neo',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Lv. ${_reviewDetail?['userLevel'] ?? '??'}',
                                    style: const TextStyle(
                                      fontFamily: 'Spoqa Han Sans Neo',
                                      color: Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Review content (이미지 영역 완전히 제거)
                        const SizedBox(height: 16),
                        
                        // Performance title, Review title & content
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '공연 : ${_reviewDetail?['performanceTitle'] ?? ''}',
                                style: const TextStyle(
                                  fontFamily: 'Spoqa Han Sans Neo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                '평점 : ${_reviewDetail?['rating'] ?? ''}',
                                style: const TextStyle(
                                  fontFamily: 'Spoqa Han Sans Neo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                '후기 본문 : ${_reviewDetail?['content'] ?? ''}',
                                style: const TextStyle(
                                  fontFamily: 'Spoqa Han Sans Neo',
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                children: [
                                  Text(
                                    '좋아요 ${_likeCount}개 | 댓글 ${_reviewDetail?['commentCount'] ?? 0}개',
                                    style: const TextStyle(
                                      fontFamily: 'Spoqa Han Sans Neo',
                                      fontSize: 12.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: _toggleLike,
                                    child: Icon(
                                      _isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: _isLiked ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        
                        // Comments section
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '댓글',
                            style: TextStyle(
                              fontFamily: 'Spoqa Han Sans Neo',
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        _comments.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                child: Text(
                                  '아직 댓글이 없습니다.',
                                  style: TextStyle(
                                    fontFamily: 'Spoqa Han Sans Neo',
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _comments.length,
                                itemBuilder: (context, index) {
                                  final comment = _comments[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            _buildProfileImage(comment['userProfileImage']),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              comment['userNickname'] ?? '',
                                              style: const TextStyle(
                                                fontFamily: 'Spoqa Han Sans Neo',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              comment['createdAt'] != null ? comment['createdAt'].toString().substring(0, 10) : '',
                                              style: TextStyle(
                                                fontFamily: 'Spoqa Han Sans Neo',
                                                fontSize: 12.0,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          comment['content'] ?? '',
                                          style: const TextStyle(
                                            fontFamily: 'Spoqa Han Sans Neo',
                                            fontSize: 14.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
                
                // Comment input area
                Container(
                  color: AppColors.lightBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: '댓글을 입력하세요',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                hintStyle: TextStyle(
                                  fontFamily: 'Spoqa Han Sans Neo',
                                  color: Colors.grey,
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Spoqa Han Sans Neo',
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.black),
                            onPressed: _addComment,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${timestamp.year}.${timestamp.month}.${timestamp.day}';
    }
  }

  // 이미지 경로에 따라 AssetImage 또는 NetworkImage를 반환하는 헬퍼
  Widget _buildProfileImage(String? imageUrl, {double radius = 14, double iconSize = 16}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, size: iconSize),
      );
    }
    if (imageUrl.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        backgroundImage: AssetImage(imageUrl),
      );
    }
  }
} 