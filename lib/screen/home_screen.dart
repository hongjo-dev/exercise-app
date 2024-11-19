import 'package:flutter/material.dart';
import 'analysis_screen.dart';
import 'history_screen.dart';
import 'pose_guide_screen.dart';
import 'product_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;  // 전체 화면의 높이를 가져옵니다.

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Exercise Summary',
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
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
              ),
              SizedBox(height: 20),
              _buildMenuOption(
                context,
                imagePath: 'assets/images/운동분석.png', // 운동 분석 이미지 경로
                text: '운동 분석',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnalysisScreen()),
                  );
                },
              ),
              _buildMenuOption(
                context,
                imagePath: 'assets/images/운동방법.png', // 운동 방법 이미지 경로
                text: '운동 자세',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PoseGuideScreen()),
                  );
                },
              ),
              _buildMenuOption(
                context,
                imagePath: 'assets/images/과거이력.png', // 과거 이력 이미지 경로
                text: '과거 이력',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  );
                },
              ),
              _buildMenuOption(
                context,
                imagePath: 'assets/images/제품추천.png', // 제품 추천 이미지 경로
                text: '제품 추천',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductScreen()),
                  );
                },
              ),
              SizedBox(height: 20), // 추가적인 패딩
              Container(
                width: double.infinity,
                height: screenHeight * 0.8,  // 화면 높이의 40%를 이미지에 할당
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/home_screen.png'), // 여기에 적합한 이미지 경로를 넣으세요.
                    fit: BoxFit.cover, // 이미지를 화면에 맞게 조정
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics, color: Colors.black),
            label: '분석',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.black),
            label: '추가',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.black),
            label: '이력',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: '프로필',
          ),
        ],
        selectedItemColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context, {required String imagePath, required String text, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(imagePath),
              ),
              SizedBox(width: 20),
              Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
