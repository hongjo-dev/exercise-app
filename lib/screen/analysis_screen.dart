import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutterapp/analysis/pose_detector_view.dart';

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  Future<void> _loadCameras() async {
    cameras = await availableCameras();
  }

  // 예제 운동 리스트
  final List<Map<String, String>> _exercises = [
    {'name': '스쿼트', 'image': 'assets/images/스쿼트.png'},
    {'name': '푸시업', 'image': 'assets/images/푸시업.png'},
    {'name': '벤치프레스', 'image': 'assets/images/벤치프레스.png'},
  ];

  // 즐겨찾기 리스트
  List<String> _favorites = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('운동 분석'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: _navigateToFavorites,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildExerciseList(),
          ),
        ],
      ),
    );
  }

  // 검색 바 위젯
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: '운동 검색',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        onChanged: (text) {
          setState(() {
            _searchText = text.toLowerCase();
          });
        },
      ),
    );
  }

  // 운동 리스트 위젯
  Widget _buildExerciseList() {
    // 검색 텍스트에 따른 운동 리스트 필터링
    final filteredExercises = _exercises.where((exercise) {
      final name = exercise['name']!.toLowerCase();
      return name.contains(_searchText);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = filteredExercises[index];
        return Column(
          children: [
            _buildExerciseTile(context, exercise['name']!, exercise['image']!),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }

  // 운동 항목 타일 위젯
  Widget _buildExerciseTile(BuildContext context, String exerciseName, String imagePath) {
    final isFavorite = _favorites.contains(exerciseName);

    return GestureDetector(
      onTap: () {
        if (exerciseName == '스쿼트' && cameras != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoseDetectorView(),
            ),
          );
        }
        // 다른 운동을 추가하려면 이곳에 다른 조건을 추가하세요.
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exerciseName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isFavorite) {
                          _favorites.remove(exerciseName);
                        } else {
                          _favorites.add(exerciseName);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 즐겨찾기 화면으로 이동
  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(favorites: _favorites, exercises: _exercises),
      ),
    );
  }
}

// 즐겨찾기 화면
class FavoritesScreen extends StatelessWidget {
  final List<String> favorites;
  final List<Map<String, String>> exercises;

  FavoritesScreen({required this.favorites, required this.exercises});

  @override
  Widget build(BuildContext context) {
    final favoriteExercises = exercises.where((exercise) => favorites.contains(exercise['name'])).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('즐겨찾기 운동'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: favoriteExercises.length,
        itemBuilder: (context, index) {
          final exercise = favoriteExercises[index];
          return Column(
            children: [
              _buildExerciseTile(context, exercise['name']!, exercise['image']!),
              SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

    Widget _buildExerciseTile(BuildContext context, String exerciseName, String imagePath) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                exerciseName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
  }

