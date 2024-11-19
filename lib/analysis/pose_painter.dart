import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';
import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.absoluteImageSize, this.rotation);

  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  double? leftKneeAngle;
  double? rightKneeAngle;
  double? leftHipAngle;
  double? rightHipAngle;
  double? torsoAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
          Offset(
            translateX(landmark.x, rotation, size, absoluteImageSize),
            translateY(landmark.y, rotation, size, absoluteImageSize),
          ),
          5,
          paint,
        );
      });

      void paintLine(PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final joint1 = pose.landmarks[type1]!;
        final joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
          Offset(
            translateX(joint1.x, rotation, size, absoluteImageSize),
            translateY(joint1.y, rotation, size, absoluteImageSize),
          ),
          Offset(
            translateX(joint2.x, rotation, size, absoluteImageSize),
            translateY(joint2.y, rotation, size, absoluteImageSize),
          ),
          paintType,
        );
      }

      // 팔
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rightPaint);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      // 몸통
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, rightPaint);

      // 다리
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);

      // 각도 계산
      leftKneeAngle = calculateAngle(
        pose.landmarks[PoseLandmarkType.leftHip]!,
        pose.landmarks[PoseLandmarkType.leftKnee]!,
        pose.landmarks[PoseLandmarkType.leftAnkle]!,
      );
      rightKneeAngle = calculateAngle(
        pose.landmarks[PoseLandmarkType.rightHip]!,
        pose.landmarks[PoseLandmarkType.rightKnee]!,
        pose.landmarks[PoseLandmarkType.rightAnkle]!,
      );
      leftHipAngle = calculateHipAngle(
        pose.landmarks[PoseLandmarkType.leftShoulder]!,
        pose.landmarks[PoseLandmarkType.leftHip]!,
        pose.landmarks[PoseLandmarkType.leftKnee]!,
      );
      rightHipAngle = calculateHipAngle(
        pose.landmarks[PoseLandmarkType.rightShoulder]!,
        pose.landmarks[PoseLandmarkType.rightHip]!,
        pose.landmarks[PoseLandmarkType.rightKnee]!,
      );
      torsoAngle = calculateTorsoAngle(
        pose.landmarks[PoseLandmarkType.leftShoulder]!,
        pose.landmarks[PoseLandmarkType.leftHip]!,
        pose.landmarks[PoseLandmarkType.rightHip]!,
      );
    }

    // 각도를 화면 상단에 표시
    if (leftKneeAngle != null && rightKneeAngle != null && leftHipAngle != null && rightHipAngle != null && torsoAngle != null) {
      _drawAngleText(canvas, size);
    }
  }

  // 두 관절 사이의 각도를 계산하는 함수
  double calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    double angle = atan2(c.y - b.y, c.x - b.x) - atan2(a.y - b.y, a.x - b.x);
    angle = angle * 180 / pi;
    if (angle > 180) angle -= 360;
    return angle.abs();
  }

  // 힙 각도 계산 함수
  double calculateHipAngle(PoseLandmark shoulder, PoseLandmark hip, PoseLandmark knee) {
    return calculateAngle(shoulder, hip, knee);
  }

  // 상체 각도 계산 함수
  double calculateTorsoAngle(PoseLandmark shoulder, PoseLandmark hip, PoseLandmark oppositeHip) {
    return calculateAngle(shoulder, hip, oppositeHip);
  }

  // 각도를 화면 상단에 표시하는 함수
  void _drawAngleText(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Left Knee: ${leftKneeAngle!.toStringAsFixed(2)}° | Right Knee: ${rightKneeAngle!.toStringAsFixed(2)}°\n'
            'Left Hip: ${leftHipAngle!.toStringAsFixed(2)}° | Right Hip: ${rightHipAngle!.toStringAsFixed(2)}°\n'
            'Torso: ${torsoAngle!.toStringAsFixed(2)}°',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          backgroundColor: Colors.black54,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(10, 10),  // 화면 상단에 텍스트 위치 설정
    );
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
