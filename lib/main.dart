import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'screen/login_screen.dart';

// 카메라 목록 변수
List<CameraDescription> cameras = [];

Future<void> main() async {
  // 비동기 메서드를 사용함
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 사용 가능한 카메라 목록 받아옴
  cameras = await availableCameras();

  // 앱 실행
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 운동선생님',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // 로그인 화면으로 시작
      home: LoginScreen(),
    );
  }
}
