import 'package:center/view/my_cart/payment_screen.dart';
import 'package:flutter/material.dart';

class MyCartView extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  const MyCartView({super.key, required this.cartItems});

  @override
  State<MyCartView> createState() => _MyCartViewState();
}

class _MyCartViewState extends State<MyCartView> {
  // Function to calculate total price
  double getTotalPrice() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      total += double.parse(item["price"].toString().replaceAll("Rs.", "")) * item["qty"];
    }
    return total;
  }

  // Function to increase or decrease item quantity
  void updateItemQuantity(int index, int change) {
    setState(() {
      widget.cartItems[index]["qty"] = (widget.cartItems[index]["qty"] + change).clamp(0, 100);
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
        backgroundColor: const Color.fromARGB(255, 17, 48, 28), // Change AppBar background color
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
                        leading: Image.asset(item["icon"], width: 50, height: 50),
                        title: Text(item["name"]),
                        subtitle: Text("Rs. ${item["price"]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                updateItemQuantity(index, -1);
                              },
                            ),
                            Text('${item["qty"]} ${item["unit"]}'),
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              ElevatedButton(
                onPressed: () {
                  // Pass the total price to PaymentMethodScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentMethodScreen(
                        totalPrice: getTotalPrice(), // Pass the total price
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 17, 48, 28), // Change button color here
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
