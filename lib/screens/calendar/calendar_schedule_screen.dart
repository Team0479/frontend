import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      locale: const Locale('ko'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickTicketDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTicketDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      locale: const Locale('ko'),
    );
    if (picked != null) {
      setState(() {
        _selectedTicketDate = picked;
      });
    }
  }

  Future<void> _pickTicketTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTicketTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTicketTime = picked;
      });
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
        title: const Text('일정 등록'),
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '공연명을 입력하세요',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF5F5F7),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '공연 일시',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: '날짜를 선택하세요',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF5F5F7),
                            suffixIcon: const Icon(Icons.calendar_today, size: 20),
                          ),
                          controller: TextEditingController(
                            text: _selectedDate == null
                                ? ''
                                : DateFormat('yyyy년 MM월 dd일').format(_selectedDate!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: AbsorbPointer(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: '공연 시간을 입력하세요',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF5F5F7),
                            suffixIcon: const Icon(Icons.access_time, size: 20),
                          ),
                          controller: TextEditingController(
                            text: _selectedTime == null
                                ? ''
                                : _selectedTime!.format(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '공연 장소',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _placeController,
                decoration: InputDecoration(
                  hintText: '공연 장소를 입력하세요',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF5F5F7),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '티켓팅 일정 등록',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTicketDate,
                      child: AbsorbPointer(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: '날짜를 선택하세요',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF5F5F7),
                            suffixIcon: const Icon(Icons.calendar_today, size: 20),
                          ),
                          controller: TextEditingController(
                            text: _selectedTicketDate == null
                                ? ''
                                : DateFormat('yyyy년 MM월 dd일').format(_selectedTicketDate!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTicketTime,
                      child: AbsorbPointer(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: '시간을 선택하세요',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF5F5F7),
                            suffixIcon: const Icon(Icons.access_time, size: 20),
                          ),
                          controller: TextEditingController(
                            text: _selectedTicketTime == null
                                ? ''
                                : _selectedTicketTime!.format(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '메모',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _memoController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '내용을 입력하세요',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF5F5F7),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
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
                        const SnackBar(content: Text('공연명과 날짜를 입력하세요.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F1F5),
                    foregroundColor: const Color(0xFF222222),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('일정 등록'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 