import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScheduleScreen extends StatefulWidget {
  const CalendarScheduleScreen({super.key});

  @override
  State<CalendarScheduleScreen> createState() => _CalendarScheduleScreenState();
}

class _CalendarScheduleScreenState extends State<CalendarScheduleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  // 추가: 검색창 컨트롤러 및 검색 결과 변수
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _showDropdown = false;
  bool _isSearching = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _selectedTicketDate;
  TimeOfDay? _selectedTicketTime;

  int? _selectedPerformanceId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _memoController.dispose();
    _searchController.dispose(); // 추가
    super.dispose();
  }

  // 검색 버튼 방식 공연명 검색 함수
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
    final url = Uri.parse('http://3.37.103.25:8080/api/performances/search?keyword=$keyword');
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

  // 드롭다운에서 공연 선택 시
  void _selectPerformanceFromDropdown(Map<String, dynamic> performance) {
    setState(() {
      _searchController.text = performance['title'] ?? '';
      _titleController.text = performance['title'] ?? '';
      _placeController.text = performance['venue'] ?? '';
      _selectedPerformanceId = performance['id'] ?? performance['performanceId'];
      _showDropdown = false;
    });
  }

  Future<void> _pickDate() async {
    // 6월 21~30일만 선택 가능한 Picker
    final List<DateTime> fakeDates = List.generate(10, (i) => DateTime(DateTime.now().year, 6, 21 + i));
    int initialIndex = _selectedDate != null
      ? fakeDates.indexWhere((d) => d.year == _selectedDate!.year && d.month == _selectedDate!.month && d.day == _selectedDate!.day)
      : 0;
    DateTime tempSelected = fakeDates[initialIndex >= 0 ? initialIndex : 0];
    final pickerBg = AppColors.lightBlue;
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: pickerBg,
          child: Column(
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: initialIndex >= 0 ? initialIndex : 0),
                  itemExtent: 40,
                  onSelectedItemChanged: (idx) {
                    tempSelected = fakeDates[idx];
                  },
                  children: fakeDates.map((d) => Center(child: Text('${d.year}년 6월 ${d.day}일', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo')))).toList(),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = tempSelected;
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

  Future<void> _pickTime() async {
    int initialHour = _selectedTime?.hour ?? 0;
    int initialMinute = _selectedTime?.minute ?? 0;
    int tempHour = initialHour;
    int tempMinute = initialMinute;
    final pickerBg = AppColors.lightBlue;
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: pickerBg,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: initialHour),
                        itemExtent: 40,
                        onSelectedItemChanged: (idx) {
                          tempHour = idx;
                        },
                        children: List.generate(24, (i) => Center(child: Text('$i 시', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo')))),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: initialMinute),
                        itemExtent: 40,
                        onSelectedItemChanged: (idx) {
                          tempMinute = idx;
                        },
                        children: List.generate(60, (i) => Center(child: Text(i.toString().padLeft(2, '0') + ' 분', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo')))),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedTime = TimeOfDay(hour: tempHour, minute: tempMinute);
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

  Future<void> _pickTicketDate() async {
    int initialMonth = _selectedTicketDate?.month != null ? (_selectedTicketDate!.month - 1) : (DateTime.now().month - 1);
    int initialDay = _selectedTicketDate?.day != null ? (_selectedTicketDate!.day - 1) : (DateTime.now().day - 1);
    int tempMonth = initialMonth;
    int tempDay = initialDay;
    final pickerBg = AppColors.lightBlue;
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: pickerBg,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: initialMonth),
                        itemExtent: 40,
                        onSelectedItemChanged: (idx) {
                          tempMonth = idx;
                        },
                        children: List.generate(12, (i) => Center(child: Text('${i + 1}월', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo')))),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: initialDay),
                        itemExtent: 40,
                        onSelectedItemChanged: (idx) {
                          tempDay = idx;
                        },
                        children: List.generate(31, (i) => Center(child: Text('${i + 1}일', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo')))),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    final now = DateTime.now();
                    _selectedTicketDate = DateTime(now.year, tempMonth + 1, tempDay + 1);
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

  Future<void> _pickTicketTime() async {
    int initialHour = _selectedTicketTime?.hour ?? 0;
    int initialMinute = _selectedTicketTime?.minute ?? 0;
    int tempHour = initialHour;
    int tempMinute = initialMinute;
    final pickerBg = AppColors.lightBlue;
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: pickerBg,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: initialHour),
                        itemExtent: 40,
                        onSelectedItemChanged: (idx) {
                          tempHour = idx;
                        },
                        children: List.generate(24, (i) => Center(child: Text('$i 시', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo')))),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: initialMinute),
                        itemExtent: 40,
                        onSelectedItemChanged: (idx) {
                          tempMinute = idx;
                        },
                        children: List.generate(60, (i) => Center(child: Text(i.toString().padLeft(2, '0') + ' 분', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo')))),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedTicketTime = TimeOfDay(hour: tempHour, minute: tempMinute);
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

  Future<void> _registerSchedule() async {
    if (_selectedDate == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공연명과 날짜를 입력하세요.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
      return;
    }
    final url = Uri.parse('http://3.37.103.25:8080/api/calendar/entries');
    final body = jsonEncode({
      'performanceId': _selectedPerformanceId ?? 0,
      'scheduledDate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'title': _titleController.text,
      'venue': _placeController.text,
    });
    print('보내는 데이터: $body');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일정이 등록되었습니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: ${response.statusCode}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
      );
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
        title: Text('일정 등록', style: Theme.of(context).appBarTheme.titleTextStyle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '공연명',
                style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 17, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 8),
              // 공연명 검색창 + 검색 버튼 + 드롭다운
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '공연명을 입력하세요',
                          hintStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Color(0xFF9D9D9D)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'),
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
              const SizedBox(height: 8),
              // 공연명, 장소 입력창(수동 입력 불가 → 직접 입력 가능)
              SizedBox(
                width: 348,
                height: 48,
                child: TextField(
                  controller: _titleController,
                  readOnly: false,
                  decoration: InputDecoration(
                    hintText: '공연명을 입력하세요',
                    hintStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Color(0xFF9D9D9D)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '공연 일시',
                style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 17, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 348,
                height: 48,
                child: GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: '날짜를 선택하세요',
                        hintStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Color(0xFF9D9D9D)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Image.asset('assets/images/calendar_icon.png', width: 21, height: 21),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
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
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ''
                            : DateFormat('yyyy년 MM월 dd일').format(_selectedDate!),
                      ),
                      style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 348,
                height: 48,
                child: GestureDetector(
                  onTap: _pickTime,
                  child: AbsorbPointer(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: '공연 시간을 입력하세요',
                        hintStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Color(0xFF9D9D9D)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Image.asset('assets/images/calendar_icon.png', width: 21, height: 21),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
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
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: TextEditingController(
                        text: _selectedTime == null
                            ? ''
                            : _selectedTime!.format(context),
                      ),
                      style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '공연 장소',
                style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 17, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 348,
                height: 48,
                child: TextField(
                  controller: _placeController,
                  readOnly: false,
                  decoration: InputDecoration(
                    hintText: '공연 장소를 입력하세요',
                    hintStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Color(0xFF9D9D9D)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Image.asset('assets/images/pin_icon.png', width: 21, height: 21),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
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
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '티켓팅 일정 등록',
                style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 17, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 348,
                height: 48,
                child: GestureDetector(
                  onTap: _pickTicketDate,
                  child: AbsorbPointer(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: '날짜를 선택하세요',
                        hintStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Color(0xFF9D9D9D)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Image.asset('assets/images/calendar_icon.png', width: 21, height: 21),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
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
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: TextEditingController(
                        text: _selectedTicketDate == null
                            ? ''
                            : DateFormat('yyyy년 MM월 dd일').format(_selectedTicketDate!),
                      ),
                      style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 348,
                height: 48,
                child: GestureDetector(
                  onTap: _pickTicketTime,
                  child: AbsorbPointer(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: '시간을 선택하세요',
                        hintStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Color(0xFF9D9D9D)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Image.asset('assets/images/calendar_icon.png', width: 21, height: 21),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
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
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: TextEditingController(
                        text: _selectedTicketTime == null
                            ? ''
                            : _selectedTicketTime!.format(context),
                      ),
                      style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '메모',
                style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 17, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 348,
                height: 48,
                child: TextField(
                  controller: _memoController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요',
                    hintStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Color(0xFF9D9D9D)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo'),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 126,
                    height: 44,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(3, 3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _registerSchedule();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(126, 44),
                        maximumSize: const Size(126, 44),
                        backgroundColor: AppColors.lightBlue,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontFamily: 'Spoqa Han Sans Neo',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('등록'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 