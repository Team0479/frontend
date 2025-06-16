import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class ReviewWriteScreen extends StatefulWidget {
  const ReviewWriteScreen({super.key});

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final TextEditingController _performanceNameController = TextEditingController();
  final TextEditingController _reviewTitleController = TextEditingController();
  final TextEditingController _reviewContentController = TextEditingController();

  @override
  void dispose() {
    _performanceNameController.dispose();
    _reviewTitleController.dispose();
    _reviewContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('리뷰 등록', style: Theme.of(context).appBarTheme.titleTextStyle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '공연명',
              style: TextStyle(
                fontFamily: 'Spoqa Han Sans Neo',
                fontSize: 17,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 348,
              height: 48,
              child: TextField(
                controller: _performanceNameController,
                decoration: InputDecoration(
                  hintText: '공연명을 입력하세요',
                  hintStyle: const TextStyle(
                    fontFamily: 'Spoqa Han Sans Neo',
                    color: Color(0xFF9D9D9D),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E9EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E9EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Spoqa Han Sans Neo',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('사진 / 동영상 첨부하기',
              style: TextStyle(
                fontFamily: 'Spoqa Han Sans Neo',
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(3, (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo, color: Colors.white),
                ),
              )),
            ),
            const SizedBox(height: 16),
            const Text('리뷰 작성',
              style: TextStyle(
                fontFamily: 'Spoqa Han Sans Neo',
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 348,
              height: 48,
              child: TextField(
                controller: _reviewTitleController,
                decoration: InputDecoration(
                  hintText: '리뷰 제목을 입력하세요',
                  hintStyle: const TextStyle(
                    fontFamily: 'Spoqa Han Sans Neo',
                    color: Color(0xFF9D9D9D),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E9EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E9EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Spoqa Han Sans Neo',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 348,
              height: 300,
              child: TextField(
                controller: _reviewContentController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: '리뷰 내용을 입력하세요',
                  hintStyle: const TextStyle(
                    fontFamily: 'Spoqa Han Sans Neo',
                    color: Color(0xFF9D9D9D),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E9EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E9EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Spoqa Han Sans Neo',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 126,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      final data = {
                        'performanceTitle': _performanceNameController.text,
                        'reviewTitle': _reviewTitleController.text,
                        'reviewContent': _reviewContentController.text,
                        'date': DateTime.now(),
                      };
                      Navigator.pop(context, data);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightBlue,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shadowColor: AppColors.lightBlue.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('등록',
                      style: TextStyle(
                        fontFamily: 'Spoqa Han Sans Neo',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 