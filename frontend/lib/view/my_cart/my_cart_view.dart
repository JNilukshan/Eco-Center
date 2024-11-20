import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/home/vegetableservice.dart';
import 'package:center/view/main_tabview/main_tabview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyCartView extends StatefulWidget {
  final String userId;
  final String role;
  final Function(List<Map<String, dynamic>>) updateStock;

  const MyCartView({
    super.key,
    required this.userId,
    required this.role,
    required this.updateStock,
  });

  @override
  State<MyCartView> createState() => _MyCartViewState();
}

class _MyCartViewState extends State<MyCartView> {
  final CartService _cartService = CartService();
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  List<TextEditingController> qtyControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() => isLoading = true);
    try {
      final fetchedCartItems = await _cartService.fetchCart(widget.userId);
      setState(() {
        cartItems =
            List<Map<String, dynamic>>.from(fetchedCartItems).map((item) {
          item['name'] = item['name'] ?? 'Unknown Item';
          return item;
        }).toList();

        qtyControllers = List.generate(cartItems.length, (index) {
          return TextEditingController(
            text: (cartItems[index]["quantity"] ?? '1').toString(),
          );
        });
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching cart: $error');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load cart: $error')),
        );
      }
    }
  }

  void onQuantityChange(int index, String value) async {
    try {
      int quantity = int.tryParse(value) ?? 1;

      setState(() {
        cartItems[index]["quantity"] = quantity;
      });

      await _cartService.updateCartItemQuantity(
          widget.userId, cartItems[index]["itemId"], quantity);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity: $error')),
      );
    }
  }

  double getTotalPrice() {
    return cartItems.fold(0.0, (total, item) {
      final unitPrice = (item['unitprice'] ?? 0.0) as num;
      final quantity = (item['quantity'] ?? 0) as num;
      return total + (unitPrice * quantity);
    });
  }

  Future<void> _removeItem(int index) async {
    try {
      String itemId = cartItems[index]["itemId"].toString();
      await _cartService.removeFromCart(widget.userId, itemId);
      setState(() {
        cartItems.removeAt(index);
        qtyControllers.removeAt(index);
      });
    } catch (error) {
      print('Error removing item: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: $error')),
        );
      }
    }
  }

  Future<void> placeOrder() async {
    setState(() => isLoading = true);
    try {
      double totalAmount = getTotalPrice();
      final cartItemsData = cartItems.map((item) {
        return {
          'itemId': item['itemId'],
          'name': item['name'],
          'quantity': item['quantity'],
          'unitPrice': item['unitprice'],
        };
      }).toList();

      // Create the order
      final response = await _cartService.createOrder(
          widget.userId, cartItemsData, totalAmount);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final orderId = responseData['orderId'];

        if (orderId != null) {
          await _cartService.createNotification(
              widget.userId, orderId, totalAmount);

          // Clear cart in the database
          await _cartService.clearCart(widget.userId);

          // Update stock in the database for each ordered item
          final vegetableService = VegetableService();
          for (var orderedItem in cartItems) {
            await vegetableService.updateStock(
                orderedItem['itemId'], orderedItem['quantity']);
          }

          // Notify HomeView to update stock based on the ordered items
          widget.updateStock(cartItems);

          // Clear cart items locally
          setState(() {
            cartItems.clear();
            qtyControllers.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Order placed successfully!"),
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              duration: const Duration(seconds: 1),
            ),
          );

          // Navigate to main view
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainTabView(
                userId: widget.userId,
                role: widget.role,
                updateStock: true,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Fail to place order!"),
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error placing order.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: TColor.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(
                  child: Text("Your cart is empty. Please add items."),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final qtyController = qtyControllers[index];

                          return ListTile(
                            leading: item['image'] != null &&
                                    item['image'].isNotEmpty
                                ? Image.network(
                                    item['image'],
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        const Icon(Icons.image_not_supported),
                                  )
                                : const Icon(Icons.image_not_supported),
                            title: Text(item['name'] ?? "Unknown"),
                            subtitle:
                                Text("Unit Price: Rs. ${item['unitprice']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: qtyController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.isEmpty ||
                                          value == "0" ||
                                          int.tryParse(value) == null) {
                                        qtyController.text = '1';
                                        onQuantityChange(index, '1');
                                      } else if (value.startsWith("0")) {
                                        qtyController.text =
                                            int.parse(value).toString();
                                      } else {
                                        onQuantityChange(index, value);
                                      }
                                    },
                                    onEditingComplete: () {
                                      if (qtyController.text.isEmpty ||
                                          qtyController.text == "0") {
                                        qtyController.text = '1';
                                        onQuantityChange(index, '1');
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      Icon(Icons.delete, color: TColor.primary),
                                  onPressed: () => _removeItem(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : BottomAppBar(
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: Rs. ${getTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    ElevatedButton(
                      onPressed: placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Place Order',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class CartService {
  final String baseUrl = "http://localhost:5000/api/cart";

  Future<http.Response> createOrder(String userId,
      List<Map<String, dynamic>> items, double totalAmount) async {
    final orderData = {
      'userId': userId,
      'items': items,
      'totalAmount': totalAmount,
    };

    return await http.post(
      Uri.parse("http://localhost:5000/api/order/createOrder"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orderData),
    );
  }

  Future<http.Response> createNotification(
      String userId, String orderId, double totalAmount) async {
    final notificationData = {
      'userId': userId,
      'orderId': orderId,
      'totalAmount': totalAmount,
    };

    return await http.post(
      Uri.parse("http://localhost:5000/api/notification/createNotification"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(notificationData),
    );
  }

  Future<List<Map<String, dynamic>>> fetchCart(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/fetch-cart/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['cartItems']);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<void> updateCartItemQuantity(
      String userId, String itemId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update-quantity/$userId/$itemId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'quantity': quantity}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update quantity');
    }
  }

  Future<void> removeFromCart(String userId, String itemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/remove-item/$userId/$itemId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove item');
    }
  }

  Future<void> saveCart(
      String userId, List<Map<String, dynamic>> cartItems) async {
    try {
      final processedCartItems = cartItems.map((item) {
        return {
          'itemId': item['itemId'],
          'name': item['name'] ?? 'Unnamed Item',
          'quantity': item['quantity'] ?? 0,
          'unitprice': item['unitprice'] ?? 0.0,
        };
      }).toList();

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

  Future<List<Map<String, dynamic>>> fetchOrders(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['orders']);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> clearCart(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/clear-cart/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart in the database');
    }
  }
}
