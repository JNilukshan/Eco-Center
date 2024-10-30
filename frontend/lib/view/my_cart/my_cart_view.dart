import 'package:center/view/home/cartservice.dart';
import 'package:center/view/my_cart/payment_screen.dart';
import 'package:center/view/main_tabview/main_tabview.dart';
import 'package:flutter/material.dart';
import 'package:center/common/color_extrnsion.dart';

class MyCartView extends StatefulWidget {
  final String userId;
  final String role;

  const MyCartView({
    super.key,
    required this.userId,
    required this.role,
    required List<Map<String, dynamic>> cartItems,
  });

  @override
  State<MyCartView> createState() => _MyCartViewState();
}

class _MyCartViewState extends State<MyCartView> {
  List<Map<String, dynamic>> cartItems = [];
  final CartService _cartService = CartService();
  bool isLoading = true;
  List<TextEditingController> qtyControllers = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  // Load cart items from backend based on userId using CartService
  Future<void> _loadCartItems() async {
    try {
      setState(() => isLoading = true);
      final fetchedCartItems = await _cartService.fetchCart(widget.userId);
      setState(() {
        cartItems = fetchedCartItems;
        qtyControllers = List.generate(cartItems.length, (index) {
          return TextEditingController(
            text: (cartItems[index]["qty"] ?? '').toString(),
          );
        });
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cart: $e')),
      );
    }
  }

  // Calculate total price
  double getTotalPrice() {
    double total = 0.0;
    for (var item in cartItems) {
      double unitPrice = (item["unitprice"] ?? 0.0).toDouble();
      int quantity = (item["qty"] ?? 0).toInt();
      total += unitPrice * quantity;
    }
    return total;
  }

  // Update item quantity
  void onQuantityChange(int index, String value) {
    int quantity = int.tryParse(value) ?? 0;
    setState(() {
      cartItems[index]["qty"] = quantity;
    });
    _cartService.saveCart(widget.userId, cartItems).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save cart: $error')),
      );
    });
  }

  // Remove item from cart
  void removeItem(int index) async {
    try {
      String userId = widget.userId;
      String itemId = cartItems[index]["itemId"];

      await _cartService.removeFromCart(userId, itemId);

      setState(() {
        cartItems.removeAt(index);
        qtyControllers.removeAt(index);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: TColor.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainTabView(
                  userId: widget.userId,
                  role: widget.role,
                ),
              ),
            );
          },
        ),
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
                          if (index >= qtyControllers.length) {
                            return const SizedBox.shrink();
                          }

                          var item = cartItems[index];
                          final qtyController = qtyControllers[index];

                          return ListTile(
                            leading: item["icon"] != null
                                ? Image.asset(item["icon"],
                                    width: 50, height: 50)
                                : const Icon(Icons.image, size: 50),
                            title: Text(item["name"] ?? "Unknown"),
                            subtitle:
                                Text("Unit Price: Rs. ${item["unitprice"]}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: qtyController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                      hintText: 'kg',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        onQuantityChange(index, "0");
                                      } else {
                                        onQuantityChange(index, value);
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => removeItem(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Total: Rs. ${getTotalPrice().toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: Rs. ${getTotalPrice().toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentMethodScreen(
                        totalPrice: getTotalPrice(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 17, 48, 28),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Payment',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
