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
    required List<Map<String, dynamic>> cartItems,
    required this.role,
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
        cartItems = List<Map<String, dynamic>>.from(fetchedCartItems);
        qtyControllers = List.generate(cartItems.length, (index) {
          return TextEditingController(
            text: (cartItems[index]["quantity"] ?? '').toString(),
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
      int quantity = int.tryParse(value) ?? 0;

      // Update local state
      setState(() {
        cartItems[index]["quantity"] = quantity;
      });

      // Update in backend
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
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
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onChanged: (value) =>
                                        onQuantityChange(index, value),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _removeItem(index),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentMethodScreen(
                                totalPrice: getTotalPrice()),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 17, 48, 28),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Proceed to Payment',
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
