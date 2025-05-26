import 'package:flutter/material.dart';

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
            TextField(
              controller: _performanceNameController,
              decoration: InputDecoration(
                labelText: '공연명',
                hintText: '공연명을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('사진 / 동영상 첨부하기'),
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
            const Text('후기 작성'),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewTitleController,
              decoration: InputDecoration(
                labelText: '후기 제목',
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewContentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: '후기 본문',
                hintText: '내용을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Pass the data back to update in the square screen
                  final data = {
                    'performanceTitle': _performanceNameController.text,
                    'reviewTitle': _reviewTitleController.text,
                    'reviewContent': _reviewContentController.text,
                    'date': DateTime.now(),
                  };
                  Navigator.pop(context, data);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 