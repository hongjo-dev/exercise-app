import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'exercise_record.dart'; // 새로운 스크린을 사용하기 위해 import
import 'calories.dart';  // ExerciseCalories 클래스 사용을 위해 import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '건강 대시보드',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HistoryScreen(),
    );
  }
}

class Exercise {
  final String name;
  final int duration; // 분 단위
  final int sets;
  final int reps;
  final DateTime date;

  Exercise({
    required this.name,
    required this.duration,
    required this.sets,
    required this.reps,
    required this.date,
  });

  int calculateCalories() {
    double caloriesPerMinute = ExerciseCalories.getCaloriesPerMinute(name);
    return (caloriesPerMinute * duration * sets).round(); // 칼로리 계산 및 반올림
  }
}

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _exerciseDurationController = TextEditingController();
  final TextEditingController _exerciseSetsController = TextEditingController();
  final TextEditingController _exerciseRepsController = TextEditingController();

  String _gender = '남성';
  String? _selectedExercise;
  double _bmi = 0;
  double _bmr = 0;
  Map<DateTime, List<Exercise>> exerciseHistory = {};
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('건강 대시보드'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildWelcomeCard(),
            SizedBox(height: 20),
            _buildOverallExerciseDataCard(),
            SizedBox(height: 20),
            _buildBmiChart(),
            SizedBox(height: 20),
            _buildExerciseInputCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              '환영합니다!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildInputField('키 (cm)', _heightController),
            SizedBox(height: 10),
            _buildInputField('몸무게 (kg)', _weightController),
            SizedBox(height: 10),
            _buildInputField('나이', _ageController),
            SizedBox(height: 10),
            _buildGenderSelection(),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('BMI & BMR 계산하기'),
              onPressed: () {
                setState(() {
                  _calculateBmiBmr();
                });
              },
            ),
            SizedBox(height: 10),
            _buildBmiBmrResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Radio<String>(
          value: '남성',
          groupValue: _gender,
          onChanged: (String? value) {
            setState(() {
              if (value != null) {
                _gender = value;
              }
            });
          },
        ),
        Text('남성'),
        Radio<String>(
          value: '여성',
          groupValue: _gender,
          onChanged: (String? value) {
            setState(() {
              if (value != null) {
                _gender = value;
              }
            });
          },
        ),
        Text('여성'),
      ],
    );
  }

  Widget _buildBmiBmrResult() {
    return Column(
      children: <Widget>[
        Text('BMI: ${_bmi.toStringAsFixed(1)}', style: TextStyle(fontSize: 18)),
        Text('BMR: ${_bmr.toStringAsFixed(0)} kcal/day', style: TextStyle(fontSize: 18)),
      ],
    );
  }

  void _calculateBmiBmr() {
    final double height = double.tryParse(_heightController.text) ?? 0;
    final double weight = double.tryParse(_weightController.text) ?? 0;
    final int age = int.tryParse(_ageController.text) ?? 0;

    if (height > 0 && weight > 0 && age > 0) {
      _bmi = weight / ((height / 100) * (height / 100));

      if (_gender == '남성') {
        _bmr = 88.36 + (13.4 * weight) + (4.8 * height) - (5.7 * age);
      } else {
        _bmr = 447.6 + (9.2 * weight) + (3.1 * height) - (4.3 * age);
      }
    }
  }

  Widget _buildOverallExerciseDataCard() {
    int totalCalories = exerciseHistory.values.fold(0, (sum, exercises) => sum + exercises.fold(0, (subSum, exercise) => subSum + exercise.calculateCalories()));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text('BMI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${_bmi.toStringAsFixed(1)}'),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text('BMR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${_bmr.toStringAsFixed(0)} kcal/day'),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text('운동 횟수', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${exerciseHistory.values.fold(0, (sum, exercises) => sum + exercises.length)} 회'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('소모한 총 칼로리: $totalCalories kcal', style: TextStyle(fontSize: 16)),
                Icon(Icons.local_fire_department, color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBmiChart() {
    final Map<String, Map<int, double>> averageBmiData = {
      '남성': {
        20: 21.7, 30: 23.2, 40: 24.3, 50: 24.8, 60: 24.3
      },
      '여성': {
        20: 21.0, 30: 22.4, 40: 23.5, 50: 24.6, 60: 24.7
      }
    };

    final int age = int.tryParse(_ageController.text) ?? 0;
    final int ageGroup = (age ~/ 10) * 10;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('나이별 평균 BMI 비교', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: averageBmiData[_gender]!.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.blueAccent,
                          width: 15,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        if (entry.key == ageGroup)
                          BarChartRodData(
                            toY: _bmi,
                            color: Colors.redAccent,
                            width: 15,
                            borderRadius: BorderRadius.circular(5),
                          ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}대');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              '파란색은 평균 BMI, 빨간색은 당신의 BMI입니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseInputCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text('운동 기록하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedExercise,
              items: ExerciseCalories.caloriesPerMinute.keys.map((String exercise) {
                return DropdownMenuItem<String>(
                  value: exercise,
                  child: Text(exercise),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedExercise = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: '운동 선택',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _exerciseDurationController,
              decoration: InputDecoration(
                labelText: '운동 시간 (분)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _exerciseSetsController,
              decoration: InputDecoration(
                labelText: '세트 수',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _exerciseRepsController,
              decoration: InputDecoration(
                labelText: '반복 횟수',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('날짜 선택'),
              onPressed: () => _selectDate(context),
            ),
            SizedBox(height: 10),
            Text('선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: Text('운동 기록 저장'),
                    onPressed: _saveExercise,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    child: Text('운동 기록 보기'),
                    onPressed: () => _navigateToExerciseRecord(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
        ); // 시간을 제거하여 저장
      });
    }
  }

  void _saveExercise() {
    if (_selectedExercise != null &&
        _exerciseDurationController.text.isNotEmpty &&
        _exerciseSetsController.text.isNotEmpty &&
        _exerciseRepsController.text.isNotEmpty) {
      final exercise = Exercise(
        name: _selectedExercise!,
        duration: int.parse(_exerciseDurationController.text),
        sets: int.parse(_exerciseSetsController.text),
        reps: int.parse(_exerciseRepsController.text),
        date: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        ), // 시간을 제거하여 저장
      );
      setState(() {
        if (exerciseHistory.containsKey(exercise.date)) {
          exerciseHistory[exercise.date]!.add(exercise);
        } else {
          exerciseHistory[exercise.date] = [exercise];
        }
        print("Exercise saved for ${exercise.date}: ${exerciseHistory[exercise.date]}");  // 운동 기록이 올바르게 저장되는지 확인
      });

      _clearInputFields();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('운동 기록이 저장되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
    }
  }

  void _clearInputFields() {
    _selectedExercise = null;
    _exerciseDurationController.clear();
    _exerciseSetsController.clear();
    _exerciseRepsController.clear();
  }

  void _navigateToExerciseRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseRecordScreen(exerciseHistory: exerciseHistory),
      ),
    );
  }
}
