import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ExerciseAnalysisScreen extends StatefulWidget {
  final String exerciseName;

  ExerciseAnalysisScreen({required this.exerciseName});

  @override
  _ExerciseAnalysisScreenState createState() => _ExerciseAnalysisScreenState();
}

class _ExerciseAnalysisScreenState extends State<ExerciseAnalysisScreen> {
  CameraController? _cameraController;
  bool _isAnalyzing = false;
  int _score = 0;
  int _count = 0;
  List<String> _exerciseLogs = [];
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  bool _isFrontCamera = false; // 현재 카메라가 전면인지 후면인지 상태를 저장

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final selectedCamera = _isFrontCamera ? cameras.last : cameras.first;

    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController?.initialize();
    setState(() {});
  }

  void _toggleCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    await _initializeCamera();
  }

  void _simulatePostureAnalysis() {
    setState(() {
      _score += 10;
      _count += 1;
      _exerciseLogs.add('$_count개 - ${_formatElapsedTime(_stopwatch.elapsed)}');
    });
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _stopwatch.stop();
  }

  void _startAnalysis() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    _startTimer();
    _simulatePostureAnalysis();
  }

  void _stopAnalysis() {
    setState(() {
      _isAnalyzing = false;
    });

    _stopTimer();
  }

  String _formatElapsedTime(Duration elapsed) {
    return '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  // 평가 기준 설정 및 아이콘, 색상 변경
  Map<String, dynamic> _getEvaluation(int score, int count) {
    if (score >= 90 && count >= 100) {
      return {
        'label': '초인',
        'color': Colors.green,
        'icon': Icons.star,
      };
    } else if (score >= 70 && count >= 80) {
      return {
        'label': '타고난 헬스인',
        'color': Colors.blue,
        'icon': Icons.fitness_center,
      };
    } else if (score >= 50 && count >= 60) {
      return {
        'label': '헬린이',
        'color': Colors.orange,
        'icon': Icons.thumb_up,
      };
    } else if (score >= 30 && count >= 40) {
      return {
        'label': '평범',
        'color': Colors.yellow,
        'icon': Icons.sentiment_satisfied,
      };
    } else if (score >= 10 && count >= 20) {
      return {
        'label': '운동부족',
        'color': Colors.orange,
        'icon': Icons.warning,
      };
    } else {
      return {
        'label': '비실이',
        'color': Colors.red,
        'icon': Icons.error,
      };
    }
  }

  void _navigateToPoseGuide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PoseGuideScreen(exerciseName: widget.exerciseName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    final evaluation = _getEvaluation(_score, _count);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.redAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.exerciseName} 분석',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.black),
            onPressed: _toggleCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          // 카메라 뷰
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize!.height,
                      height: _cameraController!.value.previewSize!.width,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),
                _buildAnalysisOverlay(evaluation), // 오버레이를 카메라 위에 배치
              ],
            ),
          ),
          // 타이머 및 운동 기록
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTimerDisplay(),
                  Expanded(
                    child: _buildExerciseLogs(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(Icons.play_arrow, _startAnalysis, _isAnalyzing ? Colors.grey : Colors.green),
            SizedBox(width: 20),
            _buildControlButton(Icons.stop, _stopAnalysis, _isAnalyzing ? Colors.red : Colors.grey),
            SizedBox(width: 20),
            _buildControlButton(Icons.help, _navigateToPoseGuide, Colors.blueAccent),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, Color color) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
      backgroundColor: color,
    );
  }

  Widget _buildTimerDisplay() {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            '운동 시간',
            style: TextStyle(fontSize: 20, color: Colors.grey[800]),
          ),
          SizedBox(height: 10),
          Text(
            _formatElapsedTime(_stopwatch.elapsed),
            style: TextStyle(fontSize: 40, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseLogs() {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '운동 기록',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Divider(color: Colors.grey),
          Expanded(
            child: ListView.builder(
              itemCount: _exerciseLogs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    _exerciseLogs[index],
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisOverlay(Map<String, dynamic> evaluation) {
    return Align(
      alignment: Alignment.bottomCenter, // 화면 하단에 배치
      child: Container(
        margin: EdgeInsets.all(10), // 화면 경계에서 약간의 여백 추가
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 아이템을 균등하게 배치
          children: [
            _buildOverlayItem('점수', '$_score', evaluation['color']),
            _buildOverlayItem('개수', '$_count', evaluation['color']),
            _buildEvaluationItem(evaluation),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayItem(String title, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min, // 필요 이상으로 공간을 차지하지 않도록 설정
      crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽 정렬
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEvaluationItem(Map<String, dynamic> evaluation) {
    return Row(
      mainAxisSize: MainAxisSize.min, // 필요 이상으로 공간을 차지하지 않도록 설정
      children: [
        Icon(
          evaluation['icon'],
          color: evaluation['color'],
          size: 24, // 아이콘 크기를 줄여 텍스트와 균형을 맞춤
        ),
        SizedBox(width: 8),
        Text(
          evaluation['label'],
          style: TextStyle(
            fontSize: 18,
            color: evaluation['color'],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _stopTimer();
    super.dispose();
  }
}

class PoseGuideScreen extends StatelessWidget {
  final String exerciseName;

  PoseGuideScreen({required this.exerciseName});

  // 운동별 데이터 매핑
  final Map<String, Map<String, String>> exerciseData = {
    '스쿼트': {
      'description': '등을 곧게 펴고 무릎이 발가락과 일직선이 되게 유지하세요.',
      'imagePath': 'assets/images/스쿼트.png',
      'videoId': 'fy9URmTqNio',
    },
    '푸시업': {
      'description': '머리부터 발끝까지 일직선을 유지하세요.',
      'imagePath': 'assets/images/푸시업.png',
      'videoId': '-_DUjHxgmWk',
    },
    '벤치프레스': {
      'description': '가슴을 활짝 펴고 바벨을 천천히 내렸다가 밀어 올리세요.',
      'imagePath': 'assets/images/벤치프레스.png',
      'videoId': 'e_JvjxyD0wQ',
    },
    // 필요한 만큼 더 추가
  };

  @override
  Widget build(BuildContext context) {
    final exerciseInfo = exerciseData[exerciseName];

    if (exerciseInfo == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('운동 자세 가이드'),
        ),
        body: Center(
          child: Text('해당 운동에 대한 정보가 없습니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$exerciseName 가이드',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildPoseCard(
            context,
            title: exerciseName,
            description: exerciseInfo['description'] ?? '',
            imagePath: exerciseInfo['imagePath'] ?? '',
            videoId: exerciseInfo['videoId'] ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildPoseCard(BuildContext context, {required String title, required String description, required String imagePath, required String videoId}) {
    return InkWell(
      onTap: () {
        // 여기에 다른 동작 추가 가능 (예: 자세한 내용 보기)
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(imagePath),
                ),
                SizedBox(width: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 15),
            AspectRatio(
              aspectRatio: 16 / 9, // 비디오의 표준 비율
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.parse('https://www.youtube.com/embed/$videoId?controls=1'),
                  ),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      useShouldOverrideUrlLoading: true,
                      mediaPlaybackRequiresUserGesture: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
