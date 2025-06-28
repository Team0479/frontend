import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'square_review_detail_screen.dart';

class ReviewWriteScreen extends StatefulWidget {
  const ReviewWriteScreen({super.key});

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final TextEditingController _performanceNameController = TextEditingController();
  final TextEditingController _reviewTitleController = TextEditingController();
  final TextEditingController _reviewContentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _showDropdown = false;
  bool _isSearching = false;
  int _rating = 5;
  DateTime? _viewDate;
  bool _isSubmitting = false;
  int? _selectedPerformanceId;
  DateTime? _performanceStartDate;
  DateTime? _performanceEndDate;
  List<DateTime> _dateCandidates = [];

  @override
  void dispose() {
    _performanceNameController.dispose();
    _reviewTitleController.dispose();
    _reviewContentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPerformancesByButton() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _searchResults = [];
        _showDropdown = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
    });
    final url = Uri.parse('http://3.37.103.25:8080/api/calendar/performances/search?title=$keyword');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((e) => e as Map<String, dynamic>).toList();
          _showDropdown = true;
        });
      } else {
        setState(() {
          _searchResults = [];
          _showDropdown = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _showDropdown = false;
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _selectPerformanceFromDropdown(Map<String, dynamic> performance) {
    setState(() {
      _searchController.text = performance['title'] ?? '';
      _performanceNameController.text = performance['title'] ?? '';
      _selectedPerformanceId = performance['id'] ?? performance['performanceId'];
      _showDropdown = false;
      // 공연 시작/종료일 저장 및 날짜 후보 생성
      if (performance['startDate'] != null && performance['endDate'] != null) {
        _performanceStartDate = DateTime.tryParse(performance['startDate']);
        _performanceEndDate = DateTime.tryParse(performance['endDate']);
        if (_performanceStartDate != null && _performanceEndDate != null) {
          final days = _performanceEndDate!.difference(_performanceStartDate!).inDays;
          _dateCandidates = List.generate(days + 1, (i) => _performanceStartDate!.add(Duration(days: i)));
        } else {
          _dateCandidates = [];
        }
      } else {
        _performanceStartDate = null;
        _performanceEndDate = null;
        _dateCandidates = [];
      }
      // 관람일은 자동으로 채우지 않고, 직접 선택하게 둔다.
      _viewDate = null;
    });
  }

  Future<void> _pickViewDate() async {
    if (_dateCandidates.isEmpty) {
      // 기본값: 오늘~10일
      final today = DateTime.now();
      _dateCandidates = List.generate(10, (i) => DateTime(today.year, today.month, today.day + i));
    }
    int initialIndex = _dateCandidates.indexWhere((d) => d.year == _viewDate?.year && d.month == _viewDate?.month && d.day == _viewDate?.day);
    if (initialIndex < 0) initialIndex = 0;
    DateTime tempSelected = _dateCandidates[initialIndex];
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: AppColors.lightBlue,
          child: Column(
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: initialIndex),
                  itemExtent: 40,
                  onSelectedItemChanged: (idx) {
                    tempSelected = _dateCandidates[idx];
                  },
                  children: _dateCandidates.map((d) => Center(child: Text('${d.year}년 ${d.month}월 ${d.day}일', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo')))).toList(),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _viewDate = tempSelected;
                  });
                  Navigator.pop(context);
                },
                child: const Text('선택', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitReview() async {
    setState(() { _isSubmitting = true; });
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
      setState(() { _isSubmitting = false; });
      return;
    }
    // userId 얻기
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
    } catch (e) {
      print('프로필 조회 에러: $e');
    }
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
      setState(() { _isSubmitting = false; });
      return;
    }

    final url = Uri.parse('http://3.37.103.25:8080/api/reviews/create');
    final body = jsonEncode({
      'userId': userId,
      'performanceId': _selectedPerformanceId ?? 1,
      'rating': _rating,
      'title': _reviewTitleController.text,
      'content': _reviewContentController.text,
      'viewingDate': _viewDate?.toIso8601String().split('T')[0],
    });
    print('리뷰 등록 시도 (이미지 없이)');
    print('요청 URL: $url');
    print('요청 body: $body');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      print('응답 코드: ${response.statusCode}');
      print('응답 body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 등록되었습니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: ${response.statusCode}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
        );
      }
    } catch (e) {
      print('에러 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
    } finally {
      setState(() { _isSubmitting = false; });
    }
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
        child: SingleChildScrollView(
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
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _searchController,
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
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _searchPerformancesByButton,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontFamily: 'Spoqa Han Sans Neo',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: _isSearching
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('검색'),
                    ),
                  ),
                ],
              ),
              if (_showDropdown && _searchResults.isNotEmpty)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 200),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE8E9EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, idx) {
                      final perf = _searchResults[idx];
                      return ListTile(
                        dense: true,
                        title: Text(
                          perf['title'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          perf['venue'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () => _selectPerformanceFromDropdown(perf),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // 관람일
              const Text('관람일',
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
                child: GestureDetector(
                  onTap: _pickViewDate,
                  child: AbsorbPointer(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: '관람일을 선택하세요',
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
                      controller: TextEditingController(
                        text: _viewDate != null ? '${_viewDate!.year}년 ${_viewDate!.month.toString().padLeft(2,'0')}월 ${_viewDate!.day.toString().padLeft(2,'0')}일' : '',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Spoqa Han Sans Neo',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 리뷰 작성
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
                  maxLines: 15,
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
              const SizedBox(height: 16),
              // 평점
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        const Text('평점', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500, fontSize: 17, color: Colors.black)),
                        const SizedBox(width: 12),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.lightBlue, width: 1.2),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _rating,
                              icon: const Icon(Icons.expand_more, color: Colors.black),
                              dropdownColor: Colors.white,
                              style: const TextStyle(
                                fontFamily: 'Spoqa Han Sans Neo',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                              items: List.generate(5, (i) => DropdownMenuItem(
                                value: i+1,
                                child: Text('${i+1}점', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black)),
                              )),
                              onChanged: (val) { if (val != null) setState(() { _rating = val; }); },
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 126,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue,
                        foregroundColor: Colors.black,
                        elevation: 4,
                        shadowColor: AppColors.lightBlue.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('등록',
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 