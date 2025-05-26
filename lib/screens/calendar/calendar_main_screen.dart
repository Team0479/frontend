import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_schedule_screen.dart';
import '../square/review_write_screen.dart';
import 'package:intl/intl.dart';
import '../square/square_main_screen.dart';
import '../../main.dart';

class CalendarMainScreen extends StatefulWidget {
  const CalendarMainScreen({super.key});

  @override
  State<CalendarMainScreen> createState() => _CalendarMainScreenState();
}

class _CalendarMainScreenState extends State<CalendarMainScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('플레이 캘린더'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
              eventLoader: getEventsForDay,
              daysOfWeekHeight: 32,
              rowHeight: 48,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                weekendStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedDay != null) ...[
              Text(
                DateFormat('yyyy년 MM월 dd일').format(_selectedDay!),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...getEventsForDay(_selectedDay!).map((event) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (event['time'] != null) Text('시간: ${event['time']}'),
                        if (event['place'] != null) Text('장소: ${event['place']}'),
                        if (event['memo'] != null) Text('메모: ${event['memo']}'),
                      ],
                    ),
                  )),
              if (getEventsForDay(_selectedDay!).isEmpty)
                const Text('등록된 일정이 없습니다.', style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
              _selectedDay = key;
              _focusedDay = key;
            });
          }
        },
        child: const Icon(Icons.add),
        tooltip: '일정 추가',
      ),
    );
  }
} 