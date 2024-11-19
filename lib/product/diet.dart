import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DietScreen extends StatefulWidget {
  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final List<Map<String, String>> dietProducts = [
    {"name": "푸드올로지", "image": "assets/images/다이어트 보조제/푸드올로지.png", "url": "https://food-ology.co.kr/product/list.html?cate_no=26"},
    {"name": "스키니랩", "image": "assets/images/다이어트 보조제/스키니랩.png", "url": "https://www.skinnylab.co.kr/shop/diet/cissus"},
    {"name": "포뉴", "image": "assets/images/다이어트 보조제/포뉴.png", "url": "https://www.ponu.co.kr/m/product_list.html?xcode=001&type=M&mcode=005&viewtype=list#enp_mbris"},
    {"name": "grn", "image": "assets/images/다이어트 보조제/grn.png", "url": "https://grnplus.co.kr/category/%EB%8B%A4%EC%9D%B4%EC%96%B4%ED%8A%B8/49/"},
    {"name": "헬스헬퍼", "image": "assets/images/다이어트 보조제/헬스헬퍼.png", "url": "https://healthhelper.kr/category/%EB%B2%A0%EC%8A%A4%ED%8A%B8/137/"},
    {"name": "오늘부터", "image": "assets/images/다이어트 보조제/오늘부터.png", "url": "https://fromtoday.kr/product/list.html?cate_no=24"},
    {"name": "세리박스", "image": "assets/images/다이어트 보조제/세리박스.png", "url": "https://www.serybox.com/shop/big_section.php?cno1=1005"},
    {"name": "익스트림", "image": "assets/images/다이어트 보조제/익스트림.png", "url": "https://exxxtreme.co.kr/product/list.html?cate_no=60"},
    {"name": "종근당건강", "image": "assets/images/다이어트 보조제/종근당건강.png", "url": "https://ckdhcmall.co.kr/categoryProductList.do?lvl=3&categoryCode=B001001009"},
    {"name": "뉴오리진", "image": "assets/images/다이어트 보조제/뉴오리진.png", "url": "https://www.neworigin.co.kr/goods/goods_list.php?cateCd=024005005"},
  ];

  // 각 제품의 좋아요 상태를 저장할 리스트
  final List<bool> likedProducts = List<bool>.filled(10, false);

  // 좋아요 필터링 상태를 저장하는 변수
  bool showOnlyLiked = false;

  @override
  Widget build(BuildContext context) {
    // 좋아요 상태에 따라 필터링된 리스트 생성
    final filteredProducts = showOnlyLiked
        ? dietProducts.asMap().entries.where((entry) => likedProducts[entry.key]).toList()
        : dietProducts.asMap().entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '다이어트 보조제',
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
              backgroundImage: AssetImage('assets/images/보조식품.png'), // 여기에 큰 이미지를 추가하세요.
            ),
            SizedBox(height: 20),

            // 각 다이어트 보조제 제품들을 세로로 나열
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
