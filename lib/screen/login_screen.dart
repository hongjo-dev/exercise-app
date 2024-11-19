import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _verificationId;

  // Google 로그인 함수
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // 사용자가 로그인 취소 시
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 사용자 정보 Firestore에 저장
        await _saveUserToFirestore(user);
        // 로그인 성공 시 홈 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print('Google 로그인 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google 로그인 중 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 익명 로그인 함수
  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      final User? user = userCredential.user;

      if (user != null) {
        // 사용자 정보 Firestore에 저장
        await _saveUserToFirestore(user);
        // 로그인 성공 시 홈 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print('익명 로그인 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('익명 로그인 중 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 전화번호를 E.164 형식으로 변환하는 함수
  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1); // '0' 제거
    }
    return '+82$phoneNumber'; // 한국 국가 코드 추가
  }

  // 전화번호 인증 시작
  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    setState(() {
      _isLoading = true;
    });

    String formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInWithPhoneCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('전화번호 인증 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('전화번호 인증 중 오류가 발생했습니다. 다시 시도해주세요.')),
        );
        setState(() {
          _isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
        _showSmsCodeDialog();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // SMS 코드 팝업창
  void _showSmsCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('SMS 코드 입력'),
          content: TextField(
            controller: _smsController,
            decoration: InputDecoration(hintText: "SMS 코드"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
                _signInWithSmsCode(_smsController.text);
              },
            ),
            ElevatedButton(
              child: Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // SMS 코드로 로그인
  Future<void> _signInWithSmsCode(String smsCode) async {
    if (_verificationId != null) {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _signInWithPhoneCredential(credential);
    }
  }

  // 전화 인증으로 로그인
  Future<void> _signInWithPhoneCredential(PhoneAuthCredential credential) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print('전화 인증 로그인 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('전화 인증 로그인 중 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Firestore에 사용자 정보 저장 함수
  Future<void> _saveUserToFirestore(User user) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);

      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastSignIn': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Firestore 저장 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 정보를 저장하는 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // "로그인" 텍스트
            Text(
              '로그인',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 10.0),
            Text(
              'MADE BY PHOENIX',
              style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 30.0),
            // 전화번호 입력 필드
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: '전화번호',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20.0),
            // 다음 버튼
            ElevatedButton(
              child: Text('다음'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
              onPressed: () {
                _verifyPhoneNumber(_phoneController.text);
              },
            ),
            SizedBox(height: 20.0),
            Divider(color: Colors.grey[400]),
            // 구글 로그인 버튼
            ElevatedButton.icon(
              icon: Image.asset('assets/images/google_logo.png', height: 24.0),
              label: Text('Google로 로그인'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                side: BorderSide(color: Colors.grey[400]!), // 외곽선 추가
              ),
              onPressed: _signInWithGoogle,
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              child: Text('익명으로 로그인'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
              onPressed: _signInAnonymously,
            ),
          ],
        ),
      ),
    );
  }
}
