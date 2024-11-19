import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:just_audio/just_audio.dart'; // 오디오 플레이어 패키지 추가
import 'pose_painter.dart';
import 'camera_view.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  int counter = 0;
  String currentStage = 'up';
  final AudioPlayer _audioPlayer = AudioPlayer(); // 오디오 플레이어 인스턴스 생성
  DateTime? _lastAlertTime; // 마지막 피드백 시간 추적
  List<String> _exerciseLog = []; // 운동 기록을 저장할 리스트

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 카메라뷰를 메인화면 전체에 배치
          CameraView(
            customPaint: _customPaint,
            onImage: (inputImage) {
              processImage(inputImage);
            },
          ),
          // 스쿼트 카운트를 표시하는 텍스트
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Squat Count: $counter',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 기록 보기 버튼을 화면의 오른쪽 상단에 배치
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => _showExerciseLog(context),
              child: Icon(Icons.list),
              backgroundColor: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    try {
      final List<Pose> poses = await _poseDetector.processImage(inputImage);
      print('Detected ${poses.length} poses');

      if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
        final painter = PosePainter(
          poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
        );

        if (mounted) {
          setState(() {
            _customPaint = CustomPaint(painter: painter);
          });
        }

        if (poses.isNotEmpty) {
          processSquat(poses.first);
        }
      } else {
        print('Missing metadata - Size: ${inputImage.metadata?.size}, Rotation: ${inputImage.metadata?.rotation}');
        if (mounted) {
          setState(() {
            _customPaint = null;
          });
        }
      }
    } catch (e, stackTrace) {
      print('Error processing image: $e');
      print('Stack trace: $stackTrace');
    }

    _isBusy = false;
  }

  void processSquat(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee]!;
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee]!;
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle]!;
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle]!;
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder]!;

    // 추가된 각도 계산: 힙 각도와 상체 각도
    double leftKneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
    double rightKneeAngle = calculateAngle(rightHip, rightKnee, rightAnkle);
    double leftHipAngle = calculateAngle(leftShoulder, leftHip, leftKnee);
    double rightHipAngle = calculateAngle(rightShoulder, rightHip, rightKnee);
    double torsoAngle = calculateAngle(leftShoulder, leftHip, rightHip);

    // 자세 분석 및 피드백 제공
    if (leftKneeAngle < 90 && currentStage == 'up') {
      currentStage = 'down';
      provideFeedback(
          leftKneeAngle,
          rightKneeAngle,
          leftHipAngle,
          rightHipAngle,
          torsoAngle,
          leftHip,
          leftAnkle,
          rightHip,
          rightAnkle);
    } else if (leftKneeAngle > 160 && currentStage == 'down') {
      currentStage = 'up';
      counter++;
      _exerciseLog.add('Squat $counter: 올바른 자세로 운동을 수행하고 있습니다.');
    }
  }

  double calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    double angle = atan2(c.y - b.y, c.x - b.x) - atan2(a.y - b.y, a.x - b.x);
    angle = angle * 180 / pi;

    if (angle > 180) {
      angle -= 360;
    }

    return angle.abs();
  }

  void provideFeedback(
      double leftKneeAngle,
      double rightKneeAngle,
      double leftHipAngle,
      double rightHipAngle,
      double torsoAngle,
      PoseLandmark leftHip,
      PoseLandmark leftAnkle,
      PoseLandmark rightHip,
      PoseLandmark rightAnkle) {
    final DateTime now = DateTime.now();
    if (_lastAlertTime == null || now.difference(_lastAlertTime!).inSeconds > 5) {
      _lastAlertTime = now;

      if (torsoAngle < 160) {
        playSound('assets/audio/excessive_arch_1.mp3');
        showFeedback('허리를 너무 아치 모양으로 만들지 말고 가슴을 피려고 노력하세요.');
        _exerciseLog.add('Squat $counter: 허리를 너무 아치 모양으로 만들지 말고 가슴을 피려고 노력하세요.');
      } else if (leftKneeAngle < 160 || rightKneeAngle < 160) {
        playSound('assets/audio/caved_in_knees_feedback_1.mp3');
        showFeedback('무릎이 움푹 들어가지 않도록 주의하세요.');
        _exerciseLog.add('Squat $counter: 무릎이 움푹 들어가지 않도록 주의하세요.');
      } else if (leftHipAngle < 70 || rightHipAngle < 70) {
        playSound('assets/audio/hips_too_high.mp3');
        showFeedback('엉덩이를 너무 높게 들어올리지 않도록 주의하세요.');
        _exerciseLog.add('Squat $counter: 엉덩이를 너무 높게 들어올리지 않도록 주의하세요.');
      } else if (isFeetTooWide(leftHip, leftAnkle, rightHip, rightAnkle)) {
        playSound('assets/audio/feet_spread.mp3');
        showFeedback('발을 어깨 너비 정도로만 벌리도록 좁히세요.');
        _exerciseLog.add('Squat $counter: 발을 어깨 너비 정도로만 벌리도록 좁히세요');
      } else {
        showFeedback('올바른 자세로 운동을 수행하고 있습니다.');
      }
    }
  }

  bool isFeetTooWide(PoseLandmark leftHip, PoseLandmark leftAnkle,
      PoseLandmark rightHip, PoseLandmark rightAnkle) {
    double hipWidth = (rightHip.x - leftHip.x).abs();
    double ankleWidth = (rightAnkle.x - leftAnkle.x).abs();
    return ankleWidth > 1.5 * hipWidth;
  }

  void playSound(String path) async {
    try {
      await _audioPlayer.setAsset(path);
      _audioPlayer.play();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 운동 기록을 표시하는 함수
  void _showExerciseLog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '스쿼트 기록',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.black54),
              Expanded(
                child: ListView.builder(
                  itemCount: _exerciseLog.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _exerciseLog[index],
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _exerciseLog.clear();
                  });
                  Navigator.pop(context);
                },
                child: Text('기록 삭제'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ],
          ),
        );
      },
    );
  }
}
