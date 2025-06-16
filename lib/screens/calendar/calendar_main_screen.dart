import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_schedule_screen.dart';
import '../square/review_write_screen.dart';
import 'package:intl/intl.dart';
import '../square/square_main_screen.dart';
import '../../main.dart';
import '../../theme/colors.dart';

class CalendarMainScreen extends StatefulWidget {
  const CalendarMainScreen({super.key});

  @override
  State<CalendarMainScreen> createState() => _CalendarMainScreenState();
}

class _CalendarMainScreenState extends State<CalendarMainScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  final Map<DateTime, List<Map<String, dynamic>>> _ticketEvents = {};

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  List<Map<String, dynamic>> getTicketEventsForDay(DateTime day) {
    return _ticketEvents[DateTime(day.year, day.month, day.day)] ?? [];
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
              },
              eventLoader: (day) {
                // 공연 일정과 티켓팅 일정 모두 반환
                return [
                  ...getEventsForDay(day).map((e) => {'type': 'show', ...e}),
                  ...getTicketEventsForDay(day).map((e) => {'type': 'ticket', ...e}),
                ];
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
                  final showExists = events.any((e) => e is Map && e['type'] == 'show');
                  final ticketExists = events.any((e) => e is Map && e['type'] == 'ticket');
                  if (!showExists && !ticketExists) return null;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showExists)
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (ticketExists)
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: AppColors.lightPink,
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
                      if (result != null && result is Map) {
                        final DateTime date = result['date'];
                        final key = DateTime(date.year, date.month, date.day);
                        setState(() {
                          _events.putIfAbsent(key, () => []);
                          _events[key]!.add(result.map((k, v) => MapEntry(k.toString(), v.toString())));
                          // 티켓팅 일정도 등록
                          if (result['ticketDate'] != null && result['ticketDate'] is String && result['ticketDate'] != '') {
                            try {
                              final ticketDate = DateFormat('yyyy년 MM월 dd일').parse(result['ticketDate']);
                              final ticketKey = DateTime(ticketDate.year, ticketDate.month, ticketDate.day);
                              _ticketEvents.putIfAbsent(ticketKey, () => []);
                              _ticketEvents[ticketKey]!.add(result.map((k, v) => MapEntry(k.toString(), v.toString())));
                            } catch (_) {}
                          }
                        });
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
                        Text(event['title'] ?? '', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w500, fontSize: 15)),
                        if (event['time'] != null) Text('시간 ${event['time']}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w300, fontSize: 13)),
                        if (event['place'] != null) Text('장소 ${event['place']}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w300, fontSize: 13)),
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
                        if (event['title'] != null) Text('공연명 ${event['title']}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.w300, fontSize: 13)),
                      ],
                    ),
                  )),
              if (getEventsForDay(_selectedDay!).isEmpty && getTicketEventsForDay(_selectedDay!).isEmpty)
                const Text('등록된 일정이 없습니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
} 