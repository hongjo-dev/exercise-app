import 'package:flutter/material.dart';
import '/product/chicken.dart'; // ChickenScreen 클래스를 가져옵니다.
import '/product/diet.dart';
import '/product/clothes.dart';
import '/product/protien.dart';
import '/product/cosmetics.dart';
import '/product/equipment.dart';

class ProductScreen extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {"title": "의류", "image": "assets/images/의류.png"},
    {"title": "닭가슴살", "image": "assets/images/닭가슴살.png"},
    {"title": "프로틴", "image": "assets/images/프로틴.png"},
    {"title": "운동장비", "image": "assets/images/보조기구.png"},
    {"title": "보조식품", "image": "assets/images/보조식품.png"},
    {"title": "화장품", "image": "assets/images/화장품.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '제품 추천',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                print('Tapped on category: ${categories[index]["title"]}'); // 로그 출력 추가
                _navigateToCategory(context, categories[index]["title"]!);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.asset(
                          categories[index]["image"]!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        categories[index]["title"]!,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    if (category == "닭가슴살") {
      print('Navigating to ChickenScreen'); // 로그 출력 추가
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChickenScreen()),
      );
    }
    // 다른 카테고리들에 대해서도 동일하게 조건을 추가할 수 있습니다.
    else if (category == "보조식품") {
      print('Navigating to DietScreen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DietScreen()),
      );
    }
    else if (category == "의류") {
      print('Navigating to ClothesScreen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClothesScreen()),
      );
    }
    else if (category == "프로틴") {
      print('Navigating to ProtienScreen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProteinScreen()),
      );
    }
    else if (category == "화장품") {
      print('Navigating to CosmeticsScreen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CosmeticsScreen ()),
      );
    }
    else if (category == "운동장비") {
      print('Navigating to EquipmentScreen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EquipmentScreen ()),
      );
    }
  }
}