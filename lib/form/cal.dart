import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<DateTime?> showCalendarDialog(
    BuildContext context, {
      DateTime? initialDate,
    }) async {
  await initializeDateFormatting('ko_KR');
  DateTime selectedDate = initialDate ?? DateTime.now();

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('날짜 선택'),
            content: SizedBox(
              width: 400,
              height: 400,
              child: TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime(2015),
                lastDay: DateTime(2101),
                focusedDay: selectedDate,
                selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                onDaySelected: (day, focusedDay) {
                  setState(() {
                    selectedDate = day; // 클릭한 날짜 선택 + UI 갱신
                  });
                },
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    final text = ['일','월','화','수','목','금','토'][day.weekday % 7];
                    final color = day.weekday == DateTime.sunday ? Colors.red : Colors.black;
                    return Center(
                      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    final isSunday = day.weekday == DateTime.sunday;
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: isSunday ? Colors.red : Colors.black),
                      ),
                    );
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(selectedDate),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    },
  );
}