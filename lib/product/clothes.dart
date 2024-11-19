import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClothesScreen extends StatefulWidget {
  @override
  _ClothesScreenState createState() => _ClothesScreenState();
}

class _ClothesScreenState extends State<ClothesScreen> {
  final List<Map<String, String>> clothesProducts = [
    {"name": "나이키", "image": "assets/images/의류/나이키.png", "url": "https://www.nike.com/kr/w/training-apparel-58jtoz6ymx6"},
    {"name": "아디다스", "image": "assets/images/의류/아디다스.png", "url": "https://www.adidas.co.kr/gym_training"},
    {"name": "언더아머", "image": "assets/images/의류/언더아머.png", "url": "https://www.underarmour.co.kr/ko-kr/c/ec-only/sports/training/?start=12&sz=12"},
    {"name": "블랙몬스터핏", "image": "assets/images/의류/블랙몬스터핏.png", "url": "https://black-monster.co.kr/product/list.html?cate_no=254"},
    {"name": "뉴발란스", "image": "assets/images/의류/뉴발란스.png", "url": "https://www.nbkorea.com/product/productList.action?cateGrpCode=250110&cIdx=1883"},
    {"name": "디스커버리 익스페디션", "image": "assets/images/의류/디스커버리 익스페디션.png", "url": "https://www.discovery-expedition.com/display/DXMB01B04"},
    {"name": "젝시믹스", "image": "assets/images/의류/젝시믹스.png", "url": "https://www.xexymix.com/shop/shopbrand.html?xcode=006&mcode=005&type=Y"},
    {"name": "에이치덱스", "image": "assets/images/의류/에이치덱스.png", "url": "https://hdex.co.kr/index.html"},
    {"name": "데상트", "image": "assets/images/의류/데상트.png", "url": "https://shop.descentekorea.co.kr/DESCENTE/Category/016802000"},
    {"name": "푸마", "image": "assets/images/의류/푸마.png", "url": "https://kr.puma.com/kr/ko/%EC%8A%A4%ED%8F%AC%EC%B8%A0/%EB%9F%AC%EB%8B%9D?srule=New%20Arrivals&prefv1=%EC%9D%98%EB%A5%98&prefn1=productdivName&pmpt=discounted&pmid=nosales-category-promotion-KR"},
  ];

  // 각 제품의 좋아요 상태를 저장할 리스트
  final List<bool> likedProducts = List<bool>.filled(10, false);

  // 좋아요 필터링 상태를 저장하는 변수
  bool showOnlyLiked = false;

  @override
  Widget build(BuildContext context) {
    // 좋아요 상태에 따라 필터링된 리스트 생성
    final filteredProducts = showOnlyLiked
        ? clothesProducts.asMap().entries.where((entry) => likedProducts[entry.key]).toList()
        : clothesProducts.asMap().entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '의류 브랜드',
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
              backgroundImage: AssetImage('assets/images/의류.png'), // 여기에 큰 이미지를 추가하세요.
            ),
            SizedBox(height: 20),

            // 각 의류 브랜드를 세로로 나열
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
              Text('좋아요 한 브랜드가 없습니다.', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
