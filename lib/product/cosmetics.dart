import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CosmeticsScreen extends StatefulWidget {
  @override
  _CosmeticsScreenState createState() => _CosmeticsScreenState();
}

class _CosmeticsScreenState extends State<CosmeticsScreen> {
  final List<Map<String, String>> cosmeticProducts = [
    {"name": "미샤", "image": "assets/images/화장품/미샤.png", "url": "https://www.ableshop.kr/product/goods/view-goods?goodsId=BO00084693"},
    {"name": "코스노리", "image": "assets/images/화장품/코스노리.png", "url": "https://graceclub.com/product/%EC%98%AC%EC%9B%A8%EC%9D%B4%EC%A6%88-%EC%8A%AC%EB%A6%BC-%ED%95%8F-%EC%85%80%EB%A3%B0%EB%9D%BC%EC%9D%B4%ED%8A%B8-%EB%B0%94%EB%94%94%EC%A0%A4-%EC%9E%84%EC%83%81%EC%99%84%EB%A3%8C/185/category/53/display/1/"},
    {"name": "유라인코스메틱", "image": "assets/images/화장품/유라인코스메틱.png", "url": "https://ulinecosmetic.com/product/list.html?cate_no=26"},
    {"name": "프로피에스", "image": "assets/images/화장품/프로피에스.png", "url": "https://profis.co.kr/product/list.html?cate_no=175"},
    {"name": "릴리이브", "image": "assets/images/화장품/릴리이브.png", "url": "https://lilyeve.kr/category/%EC%A3%BC%EB%A6%84%C2%B7%ED%83%84%EB%A0%A5/29/"},
    {"name": "엘리메르", "image": "assets/images/화장품/엘리메르.png", "url": "https://www.elimerek.com/shop/shopdetail.html?branduid=3549577&xcode=003&mcode=005&scode=&type=Y&sort=regdate&cur_code=003005&search=&GfDT=bWx3UQ%3D%3D"},
    {"name": "슈엘로", "image": "assets/images/화장품/슈엘로.png", "url": "https://smartstore.naver.com/bigselect/products/9160306425"},
  ];

  // 각 제품의 좋아요 상태를 저장할 리스트
  final List<bool> likedProducts = List<bool>.filled(7, false);

  // 좋아요 필터링 상태를 저장하는 변수
  bool showOnlyLiked = false;

  @override
  Widget build(BuildContext context) {
    // 좋아요 상태에 따라 필터링된 리스트 생성
    final filteredProducts = showOnlyLiked
        ? cosmeticProducts.asMap().entries.where((entry) => likedProducts[entry.key]).toList()
        : cosmeticProducts.asMap().entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '화장품',
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
              backgroundImage: AssetImage('assets/images/화장품.png'), // 여기에 큰 이미지를 추가하세요.
            ),
            SizedBox(height: 20),

            // 각 화장품 제품들을 세로로 나열
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
