import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import 'package:flutter/cupertino.dart';

class CalendarScheduleScreen extends StatefulWidget {
  const CalendarScheduleScreen({super.key});

  @override
  State<CalendarScheduleScreen> createState() => _CalendarScheduleScreenState();
}

class _CalendarScheduleScreenState extends State<CalendarScheduleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _selectedTicketDate;
  TimeOfDay? _selectedTicketTime;

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _memoController.dispose();
    super.dispose();
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
              SizedBox(
                width: 348,
                height: 48,
                child: TextField(
                  controller: _titleController,
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
                        if (_selectedDate != null && _titleController.text.isNotEmpty) {
                          Navigator.of(context).pop({
                            'title': _titleController.text,
                            'date': _selectedDate,
                            'time': _selectedTime?.format(context) ?? '',
                            'place': _placeController.text,
                            'memo': _memoController.text,
                            'ticketDate': _selectedTicketDate == null ? '' : DateFormat('yyyy년 MM월 dd일').format(_selectedTicketDate!),
                            'ticketTime': _selectedTicketTime?.format(context) ?? '',
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('공연명과 날짜를 입력하세요.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo'))),
                          );
                        }
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