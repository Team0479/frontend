import 'package:flutter/material.dart';
import '../../main.dart';
import '../../theme/colors.dart';

class MyReviewScreen extends StatelessWidget {
  const MyReviewScreen({super.key});

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
      body: globalReviews.isEmpty
          ? const Center(
              child: Text(
                '작성한 리뷰가 없습니다.',
                style: TextStyle(color: Colors.grey, fontSize: 16, fontFamily: 'Spoqa Han Sans Neo'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              itemCount: globalReviews.length,
              itemBuilder: (context, index) {
                final review = globalReviews[index];
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
                );
              },
            ),
    );
  }
} 