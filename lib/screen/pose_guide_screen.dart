import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PoseGuideScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '운동 자세 가이드',
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
            title: '스쿼트',
            description: '등을 곧게 펴고 무릎이 발가락과 일직선이 되게 유지하세요.',
            imagePath: 'assets/images/스쿼트.png', // 스쿼트 이미지 경로
            videoId: 'fy9URmTqNio',
          ),
          SizedBox(height: 20),
          _buildPoseCard(
            context,
            title: '푸시업',
            description: '머리부터 발끝까지 일직선을 유지하세요.',
            imagePath: 'assets/images/푸시업.png', // 푸시업 이미지 경로
            videoId: '-_DUjHxgmWk',
          ),
          SizedBox(height: 20),
          _buildPoseCard(
            context,
            title: '벤치프레스',
            description: '가슴을 활짝 펴고 바벨을 천천히 내렸다가 밀어 올리세요.',
            imagePath: 'assets/images/벤치프레스.png', // 벤치프레스 이미지 경로
            videoId: 'e_JvjxyD0wQ', // 벤치프레스 YouTube 영상 ID
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
