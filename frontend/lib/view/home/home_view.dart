import 'dart:convert';
import 'package:center/view/home/vegetableservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeView extends StatefulWidget {
  final Function(List<Map<String, dynamic>> updatedCart) updateCart;
  final String userId;
  final String role;

  const HomeView({
    super.key,
    required this.updateCart,
    required this.userId,
    required this.role,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> vegetables = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = true;

  final VegetableService _vegetableService = VegetableService();
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _loadVegetables();
  }

  Future<void> _loadVegetables() async {
    try {
      setState(() => isLoading = true);
      final fetchedVegetables = await _vegetableService.fetchVegetables();
      setState(() {
        vegetables = fetchedVegetables;
        filteredItems = vegetables;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load vegetables: $e')),
      );
    }
  }

  void filterItems(String query) {
    setState(() {
      filteredItems = query.isEmpty
          ? List.from(vegetables)
          : vegetables
              .where((item) =>
                  item['name'].toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  Future<void> addToCart(String userId, Map<String, dynamic> newItem) async {
    try {
      // Fetch current cart items from the backend
      List<Map<String, dynamic>> currentCartItems =
          await _cartService.fetchCart(userId);

      bool isFound = false;
      for (var cartItem in currentCartItems) {
        if (cartItem["itemId"] == newItem["_id"]) {
          cartItem["quantity"] = (cartItem["quantity"] ?? 0) + 1;
          isFound = true;
          break;
        }
      }

      if (!isFound) {
        currentCartItems.add({
          "itemId": newItem["_id"],
          "name": newItem["name"] ?? "Unnamed Item", // Ensure name is not null
          "quantity": 1,
          "unitprice": newItem["unitprice"],
        });
      }

      // Log the complete list of cart items before sending to saveCart
      print("Complete Cart Items to be sent for user $userId:");
      for (var item in currentCartItems) {
        print("Cart Item: $item");
      }

      // Call saveCart with updated cart items
      await _cartService.saveCart(userId, currentCartItems);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added to cart successfully')),
        );
      }
    } catch (error) {
      print('Error in addToCart: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item to cart: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridCrossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Available Vegetables'),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: SizedBox(
                      height: screenWidth * 0.1,
                      child: TextField(
                        controller: txtSearch,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onChanged: filterItems,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCrossAxisCount,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: screenWidth * 0.03,
                          mainAxisSpacing: screenWidth * 0.03,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          var pObj = filteredItems[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Image.network(
                                        pObj["image"] ??
                                            'https://via.placeholder.com/100',
                                        width: screenWidth * 0.2,
                                        height: screenWidth * 0.2,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.image,
                                              size: screenWidth * 0.2);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    pObj["name"] ?? "Unknown Vegetable",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "Available Stock: ${pObj["quantity"] ?? 'N/A'} kg",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color:
                                          const Color.fromARGB(255, 17, 48, 28),
                                    ),
                                  ),
                                  Text(
                                    "Unit Price: Rs. ${pObj["unitprice"] ?? '0'}",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color:
                                          const Color.fromARGB(255, 17, 48, 28),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          addToCart(widget.userId, pObj),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 17, 48, 28),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02,
                                          vertical: screenWidth * 0.015,
                                        ),
                                      ),
                                      child: Text(
                                        "Add to Cart",
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.035),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class CartService {
  final String baseUrl = "http://localhost:5000/api/cart";

  Future<void> saveCart(
      String userId, List<Map<String, dynamic>> cartItems) async {
    try {
      final processedCartItems = cartItems.map((item) {
        return {
          'itemId': item['itemId'],
          'name': item['name'] ?? 'Unnamed Item', // Ensure name is not null
          'quantity': item['quantity'] ?? 0,
          'unitprice': item['unitprice'] ?? 0.0,
        };
      }).toList();

      // Log each processed cart item to ensure fields are correctly set
      print("Processed Cart Items for user $userId:");
      for (var item in processedCartItems) {
        print("Processed Cart Item: $item");
      }

      final response = await http.post(
        Uri.parse('$baseUrl/save-cart'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'cartItems': processedCartItems,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to save cart. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error in saveCart: $e');
      throw Exception('Error saving cart: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCart(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fetch-cart/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['cartItems']);
      } else {
        throw Exception('Failed to load cart. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchCart: $e');
      throw Exception('Error fetching cart: $e');
    }
  }

  Future<void> updateCartItemQuantity(
      String userId, String itemId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-quantity/$userId/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'quantity': quantity}),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update quantity. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateCartItemQuantity: $e');
      throw Exception('Error updating quantity: $e');
    }
  }

  Future<void> removeFromCart(String userId, String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/remove-item/$userId/$itemId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to remove item. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in removeFromCart: $e');
      throw Exception('Error removing item from cart: $e');
    }
  }
}
