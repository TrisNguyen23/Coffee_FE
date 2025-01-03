import 'package:flutter/material.dart';

void main() {
  runApp(StarbucksApp());
}

class StarbucksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        // accentColor: Colors.brown,
        fontFamily: 'Roboto',
      ),
      home: StarbucksHomePage(),
    );
  }
}

class StarbucksHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Starbucks',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMenuList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.green,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 40,
            child: Image.network(
              'https://upload.wikimedia.org/wikipedia/sco/d/d3/Starbucks_Corporation_Logo_2011.svg',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Starbucks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Enjoy your favorite coffee',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    final List<Map<String, String>> menuItems = [
      {'name': 'Cappuccino', 'price': '4.50', 'image': 'https://via.placeholder.com/100'},
      {'name': 'Latte', 'price': '4.00', 'image': 'https://via.placeholder.com/100'},
      {'name': 'Mocha', 'price': '5.00', 'image': 'https://via.placeholder.com/100'},
      {'name': 'Americano', 'price': '3.50', 'image': 'https://via.placeholder.com/100'},
    ];

    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Image.network(item['image']!, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(item['name']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text(item['price']!, style: TextStyle(color: Colors.green)),
            trailing: Icon(Icons.add_shopping_cart, color: Colors.brown),
          ),
        );
      },
    );
  }
}
