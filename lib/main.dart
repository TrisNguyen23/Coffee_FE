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
  List<Drink> cart = [];
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

  void addToCart(Drink drink) {
    setState(() {
      cart.add(drink);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drink.name} has been added to your cart!'),
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

  void deleteFromCart(Drink drink) {
    setState(() {
      cart.remove(drink);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drink.name} has been removed from your cart!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Coffee",
          style: TextStyle(
            fontWeight: FontWeight.bold, // Làm chữ đậm
          ),
        ),
        backgroundColor: const Color.fromARGB(219, 228, 202, 185),
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
            padding: const EdgeInsets.all(6.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0), // Góc bo giống iOS
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                      color: Colors.grey), // Màu viền khi không focus
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(
                          255, 32, 27, 18)), // Màu viền khi focus
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDrinks.length,
              itemBuilder: (context, index) {
                return DrinkCard(
                  drink: filteredDrinks[index],
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
  final Drink drink;
  final Function(Drink) onAddToCart;

  const DrinkCard({
    super.key,
    required this.drink,
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
              drink.imageUrl,
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
                  drink.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  drink.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 32, 27, 18),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${drink.price}', // Thêm ký hiệu $ trước giá
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 96, 51, 23),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () =>
                      onAddToCart(drink), // Gọi hàm thêm vào giỏ hàng
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(
                        color: const Color.fromARGB(184, 55, 51, 40), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
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

//Trang kiểm tra hàng trước khi thanh toán
class CartPage extends StatelessWidget {
  final List<Drink> cart;
  final Function(Drink) onDelete;

  const CartPage({super.key, required this.cart, required this.onDelete});

  double calculateTotal() {
    return cart.fold(0, (sum, drink) => sum + double.parse(drink.price));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Cart",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(219, 228, 202, 185),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text("Your cart is empty"))
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(cart[index].name),
                        subtitle: Text('\$${cart[index].price}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onDelete(cart[index]),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total: \$${calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: cart.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                totalAmount: calculateTotal(),
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cart.isEmpty
                        ? Colors.grey
                        : const Color.fromARGB(219, 228, 202, 185),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    "Proceed to Payment",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//Trang tính tiền
class PaymentPage extends StatelessWidget {
  final double totalAmount;

  const PaymentPage({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(219, 228, 202, 185),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Total: \$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Payment successful!"),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context); // Quay lại màn hình trước
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(219, 228, 202, 185),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                "Pay Now",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black, // Đổi màu chữ thành trắng
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
