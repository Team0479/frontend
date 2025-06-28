import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_schedule_screen.dart';
import '../square/review_write_screen.dart';
import 'package:intl/intl.dart';
import '../square/square_main_screen.dart';
import '../../main.dart';
import '../../theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarMainScreen extends StatefulWidget {
  const CalendarMainScreen({super.key});

  @override
  State<CalendarMainScreen> createState() => _CalendarMainScreenState();
}

class _CalendarMainScreenState extends State<CalendarMainScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  final Map<DateTime, List<Map<String, dynamic>>> _allEvents = {};
  final Map<DateTime, List<Map<String, dynamic>>> _ticketEvents = {};

  // 날짜별 일정 불러오기
  Future<void> _fetchUserCalendarForDay(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    int? userId;
    if (jwt != null) {
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
    }
    print('조회 userId: $userId');
    if (userId == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    final url = Uri.parse('http://3.37.103.25:8080/api/calendar/entries/user/$userId?date=$dateStr');
    print('요청 URL: $url');
    try {
      final response = await http.get(url);
      print('응답 바디: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('받아온 일정: $data');
        final key = DateTime(day.year, day.month, day.day);
        print('저장할 key: $key');
        // watchedAt 날짜로 필터링
        final filtered = data.where((item) {
          final watchedAt = item['watchedAt'];
          if (watchedAt == null) return false;
          final watchedDate = DateTime.parse(watchedAt);
          return watchedDate.year == key.year && watchedDate.month == key.month && watchedDate.day == key.day;
        }).toList();
        setState(() {
          _events.clear();
          _events[key] = filtered.map((item) => item as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      print('에러: $e');
    }
  }

  // 전체 일정 받아와서 마커용으로 저장
  Future<void> _fetchAllUserCalendar() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    int? userId;
    if (jwt != null) {
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
    }
    if (userId == null) return;
    final url = Uri.parse('http://3.37.103.25:8080/api/calendar/entries/user/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allEvents.clear();
          for (final item in data) {
            final watchedAt = item['watchedAt'];
            if (watchedAt == null) continue;
            final date = DateTime.parse(watchedAt);
            final key = DateTime(date.year, date.month, date.day);
            _allEvents.putIfAbsent(key, () => []);
            _allEvents[key]!.add(item as Map<String, dynamic>);
          }
        });
      }
    } catch (e) {
      print('전체 일정 조회 에러: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchAllUserCalendar();
    _fetchUserCalendarForDay(_selectedDay!);
  }

  Future<void> _fetchUserCalendar() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return;
    final url = Uri.parse('http://3.37.103.25:8080/api/calendar/entries/user/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _events.clear();
          for (final item in data) {
            final date = DateTime.parse(item['viewingDate']);
            final key = DateTime(date.year, date.month, date.day);
            _events.putIfAbsent(key, () => []);
            _events[key]!.add(item as Map<String, dynamic>);
          }
        });
      }
    } catch (e) {
      // ignore error
    }
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  List<Map<String, dynamic>> getTicketEventsForDay(DateTime day) {
    return _ticketEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // 마커용: 해당 날짜에 일정이 있으면 리스트 반환
  List<Map<String, dynamic>> getAllEventsForDay(DateTime day) {
    return _allEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('플레이 캘린더', style: Theme.of(context).appBarTheme.titleTextStyle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _fetchUserCalendarForDay(selectedDay);
              },
              eventLoader: (day) {
                // 마커용: 전체 일정에서 해당 날짜에 일정이 있으면 리스트 반환
                return getAllEventsForDay(day);
              },
              daysOfWeekHeight: 32,
              rowHeight: 48,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 15, fontWeight: FontWeight.w500),
                weekendStyle: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 15, fontWeight: FontWeight.w500),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 15, fontWeight: FontWeight.w400),
                weekendTextStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 15, fontWeight: FontWeight.w400),
                outsideTextStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
                todayTextStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                selectedTextStyle: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                todayDecoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(), // 사용 안함, 아래에서 커스텀
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CalendarScheduleScreen(),
                        ),
                      );
                      if (result == true) {
                        _fetchUserCalendar();
                      }
                    },
                    child: const Text('일정 추가'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedDay != null) ...[
              Text(
                DateFormat('yyyy년 MM월 dd일').format(_selectedDay!),
                style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    ...getEventsForDay(_selectedDay!).map((event) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.lightBlue, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                offset: const Offset(2, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event['performanceTitle'] ?? '', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500, fontSize: 15)),
                              if (event['performanceVenue'] != null) Text('장소 ${event['performanceVenue']}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w300, fontSize: 13)),
                              if (event['memo'] != null) Text('메모 ${event['memo']}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w300, fontSize: 13)),
                            ],
                          ),
                        )),
                    ...getTicketEventsForDay(_selectedDay!).map((event) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.lightPink, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                offset: const Offset(2, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('티켓팅 일정', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500, fontSize: 15)),
                              if (event['ticketDate'] != null && event['ticketDate'] != '') Text('날짜 ${event['ticketDate']}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w300, fontSize: 13)),
                              if (event['ticketTime'] != null && event['ticketTime'] != '') Text('시간 ${event['ticketTime']}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w300, fontSize: 13)),
                              if (event['performanceTitle'] != null) Text('공연명 ${event['performanceTitle']}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w300, fontSize: 13)),
                            ],
                          ),
                        )),
                    if (getEventsForDay(_selectedDay!).isEmpty && getTicketEventsForDay(_selectedDay!).isEmpty)
                      const Text('등록된 일정이 없습니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 