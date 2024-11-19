import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChickenScreen extends StatefulWidget {
  @override
  _ChickenScreenState createState() => _ChickenScreenState();
}

class _ChickenScreenState extends State<ChickenScreen> {
  final List<Map<String, String>> chickenProducts = [
    {"name": "아임닭", "image": "assets/images/chicken/아임닭.png", "url": "https://www.imdak.com/product/list.html?cate_no=275"},
    {"name": "하림", "image": "assets/images/chicken/하림.png", "url": "https://harimmall.com/product/list2.html?cate_no=263&sort_method=6#Product_ListMenu"},
    {"name": "허닭", "image": "assets/images/chicken/허닭.png", "url": "http://www.heodak.com/shop/shopbrand.html?type=N&xcode=016&mcode=006"},
    {"name": "홀리닭", "image": "assets/images/chicken/홀리닭.png", "url": "https://smartstore.naver.com/holydak/best?cp=1"},
    {"name": "맛있닭", "image": "assets/images/chicken/맛있닭.png", "url": "https://masitdak.com/shop/list2.php?ca=2020"},
    {"name": "바르닭", "image": "assets/images/chicken/바르닭.png", "url": "https://barudak.co.kr/product/list.html?cate_no=144"},
    {"name": "채우닭", "image": "assets/images/chicken/채우닭.png", "url": "https://chaewoodak.co.kr/product/list_best.html?cate_no=27"},
    {"name": "위하닭", "image": "assets/images/chicken/위하닭.png", "url": "https://wehadak.com/product/list.html?cate_no=105"},
    {"name": "굽네", "image": "assets/images/chicken/굽네.png", "url": "https://www.goobnemall.com/shop/shopbrand.html?type=X&xcode=003"},
    {"name": "bhc", "image": "assets/images/chicken/bhc.png", "url": "https://bhcmall.co.kr/goods/category.asp?cate=374"},
  ];

  // 각 제품의 좋아요 상태를 저장할 리스트
  final List<bool> likedProducts = List<bool>.filled(10, false);

  // 좋아요 필터링 상태를 저장하는 변수
  bool showOnlyLiked = false;

  @override
  Widget build(BuildContext context) {
    // 좋아요 상태에 따라 필터링된 리스트 생성
    final filteredProducts = showOnlyLiked
        ? chickenProducts.asMap().entries.where((entry) => likedProducts[entry.key]).toList()
        : chickenProducts.asMap().entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '닭가슴살 제품',
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
              backgroundImage: AssetImage('assets/images/닭가슴살.png'), // 여기에 큰 이미지를 추가하세요.
            ),
            SizedBox(height: 20),

            // 각 닭가슴살 제품들을 세로로 나열
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
