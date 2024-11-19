import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProteinScreen extends StatefulWidget {
  @override
  _ProteinScreenState createState() => _ProteinScreenState();
}

class _ProteinScreenState extends State<ProteinScreen> {
  final List<Map<String, String>> proteinProducts = [
    {"name": "옵티멈 뉴트리션", "image": "assets/images/프로틴/옵티멈 뉴트리션.png", "url": "https://www.optimumnutrition.co.kr/product/list.html?cate_no=123"},
    {"name": "웨이테크", "image": "assets/images/프로틴/웨이테크.png", "url": "https://wheytech.co.kr/product/list.html?cate_no=24"},
    {"name": "후디스", "image": "assets/images/프로틴/일동후디스.png", "url": "https://foodismall.com/product/list.html?cate_no=621"},
    {"name": "칼로바이", "image": "assets/images/프로틴/칼로바이.png", "url": "https://www.calobye.com/diet_shake_html.php"},
    {"name": "밀팜", "image": "assets/images/프로틴/밀팜.png", "url": "https://mealfarm.co.kr/category/%EA%B3%A0%EB%A6%B4%EB%9D%BC%ED%91%B8%EB%93%9C/24/"},
    {"name": "bsn", "image": "assets/images/프로틴/bsn.png", "url": "https://bsn.co.kr/product/list.html?cate_no=123"},
    {"name": "삼대오백", "image": "assets/images/프로틴/삼대오백.png", "url": "https://samdae500.com/product/list.html?cate_no=248"},
  ];

  // 각 제품의 좋아요 상태를 저장할 리스트
  final List<bool> likedProducts = List<bool>.filled(7, false);

  // 좋아요 필터링 상태를 저장하는 변수
  bool showOnlyLiked = false;

  @override
  Widget build(BuildContext context) {
    // 좋아요 상태에 따라 필터링된 리스트 생성
    final filteredProducts = showOnlyLiked
        ? proteinProducts.asMap().entries.where((entry) => likedProducts[entry.key]).toList()
        : proteinProducts.asMap().entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '프로틴 제품',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(showOnlyLiked ? Icons.favorite : Icons.favorite_border, color: Colors.red),
            onPressed: () {
              setState(() {
                showOnlyLiked = !showOnlyLiked;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 큰 이미지를 상단에 배치
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/프로틴.png'), // 여기에 큰 이미지를 추가하세요.
            ),
            SizedBox(height: 20),

            // 각 프로틴 제품들을 세로로 나열
            if (filteredProducts.isNotEmpty)
              ...filteredProducts.map((entry) {
                int index = entry.key;
                Map<String, String> product = entry.value;

                return GestureDetector(
                  onTap: () async {
                    final url = product["url"]!;
                    final uri = Uri.parse(url);

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(product["image"]!),
                      ),
                      title: Text(
                        product["name"]!,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          likedProducts[index] ? Icons.favorite : Icons.favorite_border,
                          color: likedProducts[index] ? Colors.red : null,
                        ),
                        onPressed: () {
                          setState(() {
                            likedProducts[index] = !likedProducts[index]; // 좋아요 상태 토글
                          });
                        },
                      ),
                    ),
                  ),
                );
              }).toList()
            else
              Text('좋아요 한 제품이 없습니다.', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
