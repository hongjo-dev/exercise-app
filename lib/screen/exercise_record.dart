import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'history_screen.dart'; // Exercise 클래스 사용을 위해 import

class ExerciseRecordScreen extends StatefulWidget {
  final Map<DateTime, List<Exercise>> exerciseHistory;

  ExerciseRecordScreen({required this.exerciseHistory});

  @override
  _ExerciseRecordScreenState createState() => _ExerciseRecordScreenState();
}

class _ExerciseRecordScreenState extends State<ExerciseRecordScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // selectedDate의 시간을 자정으로 설정하여 일관된 비교를 할 수 있도록 합니다.
    selectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('운동 기록'),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(child: _buildExerciseList()),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TableCalendar(
        focusedDay: selectedDate,
        firstDay: DateTime(2000),
        lastDay: DateTime(2025),
        selectedDayPredicate: (day) => isSameDay(day, selectedDate),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            selectedDate = DateTime(
              selectedDay.year,
              selectedDay.month,
              selectedDay.day,
            );
          });
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    final exercises = widget.exerciseHistory[selectedDate] ?? [];

    if (exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '이 날에는 운동 기록이 없습니다.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return ListTile(
            title: Text('${exercise.name} - ${exercise.duration}분'),
            subtitle: Text('소모 칼로리: ${exercise.calculateCalories()} kcal'),
          );
        },
      );
    }
  }
}
