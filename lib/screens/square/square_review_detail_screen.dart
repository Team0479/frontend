import 'package:flutter/material.dart';
import '../../theme/colors.dart';

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
  List<Map<String, dynamic>> _comments = [];
  final String _currentUser = '플레이어 닉네임'; // 임시 사용자 이름

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    
    setState(() {
      _comments.add({
        'user': _currentUser,
        'content': _commentController.text.trim(),
        'timestamp': DateTime.now(),
      });
      _commentController.clear();
    });
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
      body: Column(
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
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[300],
                          child: const Text('프로필'),
                        ),
                        const SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '플레이어 닉네임',
                              style: TextStyle(
                                fontFamily: 'Spoqa Han Sans Neo',
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Lv. ???',
                              style: TextStyle(
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
                  
                  // Review content
                  Container(
                    width: double.infinity,
                    height: 200.0,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text('리뷰 이미지 영역', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Colors.black)),
                    ),
                  ),
                  
                  // Performance title, Review title & content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '공연 : ${widget.review['performanceTitle']}',
                          style: const TextStyle(
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '후기 제목 : ${widget.review['reviewTitle']}',
                          style: const TextStyle(
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '후기 본문 : ${widget.review['reviewContent']}',
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
                              '조회수 ${widget.review['views']}회 | 좋아요 ${widget.review['likes']}개 | 댓글 ${widget.review['comments']}개',
                              style: TextStyle(
                                fontFamily: 'Spoqa Han Sans Neo',
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLiked = !_isLiked;
                                });
                              },
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
                                      Text(
                                        comment['user'],
                                        style: const TextStyle(
                                          fontFamily: 'Spoqa Han Sans Neo',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        _formatTimestamp(comment['timestamp']),
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
                                    comment['content'],
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
} 