import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Tạo một lớp để lưu trữ thông tin đồ uống
class Drink {
  final String name;
  final String description;
  final String price;
  final String imageUrl;

  Drink({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  // Hàm tạo đối tượng Drink từ JSON
  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['imageUrl'],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee UI',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const StarbucksHomePage(),
    );
  }
}

class StarbucksHomePage extends StatefulWidget {
  const StarbucksHomePage({super.key});

  @override
  _StarbucksHomePageState createState() => _StarbucksHomePageState();
}

class _StarbucksHomePageState extends State<StarbucksHomePage> {
  List<Drink> drinks = [];
  List<Drink> filteredDrinks = [];
  List<String> cart = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDrinks();
    searchController.addListener(() {
      filterDrinks();
    });
  }

  Future<void> _loadDrinks() async {
    // Đọc file JSON từ assets
    final String response = await rootBundle.loadString('assets/drinks.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      drinks = data.map((item) => Drink.fromJson(item)).toList();
      filteredDrinks = drinks;
    });
  }

  void addToCart(String drink) {
    setState(() {
      cart.add(drink);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$drink has been added to your cart!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cart: cart, onDelete: deleteFromCart),
      ),
    );
  }

  void filterDrinks() {
    setState(() {
      filteredDrinks = drinks
          .where((drink) => drink.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  void deleteFromCart(String drink) {
    setState(() {
      cart.remove(drink);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$drink has been removed from your cart!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coffee"),
        backgroundColor: const Color.fromARGB(219, 31, 19, 11),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: goToCart,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDrinks.length,
              itemBuilder: (context, index) {
                return DrinkCard(
                  name: filteredDrinks[index].name,
                  description: filteredDrinks[index].description,
                  price: filteredDrinks[index].price,
                  imageUrl: filteredDrinks[index].imageUrl,
                  onAddToCart: addToCart,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DrinkCard extends StatelessWidget {
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final Function(String) onAddToCart;

  const DrinkCard({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(219, 31, 19, 11),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () =>
                      onAddToCart(name), // Gọi hàm thêm vào giỏ hàng
                  child: const Text("Add to Cart"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final List<String> cart;
  final Function(String) onDelete;

  const CartPage({super.key, required this.cart, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: const Color.fromARGB(219, 31, 19, 11),
      ),
      body: cart.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cart[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDelete(cart[index]),
                  ),
                );
              },
            ),
    );
  }
}
