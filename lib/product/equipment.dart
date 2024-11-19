import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EquipmentScreen extends StatefulWidget {
  @override
  _EquipmentScreenState createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final List<Map<String, dynamic>> categories = [
    {
      "title": "폼롤러",
      "image": "assets/images/운동기구/폼롤러.png",
      "products": [
        {"name": "트라택 EPP 폼롤러 원형", "price": "20,900원", "url": "https://www.coupang.com/vp/products/45079633"},
        {"name": "코멧 EPP 폼롤러", "price": "25,900원", "url": "https://www.coupang.com/vp/products/172134008"},
        {"name": "아리프 EVA 마블 폼롤러", "price": "29,720원", "url": "https://www.coupang.com/vp/products/7563497247"},
      ],
    },
    {
      "title": "아령",
      "image": "assets/images/운동기구/아령.png",
      "products": [
        {"name": "블루선 아령 덤벨 세트", "price": "35,100원", "url": "https://www.coupang.com/vp/products/8068053169"},
        {"name": "아리프 네오프렌 아령", "price": "8,200원", "url": "https://www.coupang.com/vp/products/6465787707"},
        {"name": "코멧 스포츠 고중량 아령", "price": "17,090원", "url": "https://www.coupang.com/vp/products/7578389096"},
      ],
    },
    {
      "title": "푸쉬업바",
      "image": "assets/images/운동기구/푸쉬업바.png",
      "products": [
        {"name": "핏에이블 스틸 푸쉬업바", "price": "69,900원", "url": "https://www.coupang.com/vp/products/7781136608"},
        {"name": "코멧 스포츠 푸쉬업바", "price": "13,900원", "url": "https://www.coupang.com/vp/products/4705761543"},
        {"name": "나이키 푸쉬업 그립", "price": "31,600원", "url": "https://www.coupang.com/vp/products/5911335692"},
      ],
    },
    {
      "title": "악력기",
      "image": "assets/images/운동기구/악력기.png",
      "products": [
        {"name": "하디로어 프리미엄 악력기", "price": "19,000원", "url": "https://www.coupang.com/vp/products/4770622653"},
        {"name": "지디 그립 프로 악력기", "price": "20,000원", "url": "https://www.coupang.com/vp/products/7144403308"},
        {"name": "강도조절 그립 카운터", "price": "4,390원", "url": "https://www.coupang.com/vp/products/4846830941"},
      ],
    },
    {
      "title": "실내자전거",
      "image": "assets/images/운동기구/실내자전거.png",
      "products": [
        {"name": "스포틀러 엑스바이크", "price": "349,000원", "url": "https://www.coupang.com/vp/products/7593599328"},
        {"name": "엑사이더 접이식 자전거", "price": "189,200원", "url": "https://www.coupang.com/vp/products/261120257"},
        {"name": "코멧 스포츠 자전거", "price": "139,990원", "url": "https://www.coupang.com/vp/products/6545696170"},
      ],
    },
    {
      "title": "요가매트",
      "image": "assets/images/운동기구/요가매트.png",
      "products": [
        {"name": "트라택 요가매트", "price": "28,000원", "url": "https://www.coupang.com/vp/products/6890690736"},
        {"name": "코멧 NBR 요가매트", "price": "9,890원", "url": "https://www.coupang.com/vp/products/172134026"},
        {"name": "고무나라 TPE 요가매트", "price": "17,200원", "url": "https://www.coupang.com/vp/products/64527390"},
      ],
    },
  ];

  final List<bool> likedProducts = List<bool>.filled(18, false);
  bool showOnlyLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '운동 기구',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categories.map((category) {
            final filteredProducts = showOnlyLiked
                ? category["products"].where((product) => likedProducts[categories.indexOf(category)]).toList()
                : category["products"];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      Image.asset(
                        category["image"],
                        width: 40,
                        height: 40,
                      ),
                      SizedBox(width: 10),
                      Text(
                        category["title"],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                ...filteredProducts.map<Widget>((product) {
                  int index = category["products"].indexOf(product);

                  return GestureDetector(
                    onTap: () async {
                      final url = product["url"];
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
                        title: Text(
                          product["name"],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(product["price"]),
                        trailing: IconButton(
                          icon: Icon(
                            likedProducts[index] ? Icons.favorite : Icons.favorite_border,
                            color: likedProducts[index] ? Colors.red : null,
                          ),
                          onPressed: () {
                            setState(() {
                              likedProducts[index] = !likedProducts[index];
                            });
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
