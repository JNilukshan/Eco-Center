import 'package:center/view/main_tabview/main_tabview.dart';
import 'package:center/view/my_cart/payment_screen.dart';
import 'package:flutter/material.dart';

class MyCartView extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String userId;
  final String role;

  const MyCartView({
    super.key,
    required this.cartItems,
    required this.userId,
    required this.role,
  });

  @override
  State<MyCartView> createState() => _MyCartViewState();
}

class _MyCartViewState extends State<MyCartView> {
  // Function to calculate total price
  double getTotalPrice() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      total += item["unitprice"] * item["qty"];
    }
    return total;
  }

  // Function to increase or decrease item quantity
  void updateItemQuantity(int index, int change) {
    setState(() {
      widget.cartItems[index]["qty"] =
          (widget.cartItems[index]["qty"] + change).clamp(0, 100);
      if (widget.cartItems[index]["qty"] == 0) {
        widget.cartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: const Color.fromARGB(255, 17, 48, 28),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to HomeView
          },
        ),
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
              child: Text("Your cart is empty"),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      var item = widget.cartItems[index];
                      return ListTile(
                        leading: item["icon"] != null
                            ? Image.asset(item["icon"], width: 50, height: 50)
                            : Icon(Icons.image, size: 50),
                        title: Text(item["name"] ?? "Unknown"),
                        subtitle: Text("Unit Price: Rs. ${item["unitprice"]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                updateItemQuantity(index, -1);
                              },
                            ),
                            Text('${item["qty"]} kg'), // Display quantity with kg
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                updateItemQuantity(index, 1);
                              },
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
