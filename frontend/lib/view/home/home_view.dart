import 'package:center/view/home/vegetableservice.dart';
import 'package:center/view/my_cart/my_cart_view.dart';
import 'package:flutter/material.dart';

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

  Future<void> addToCart(Map<String, dynamic> item) async {
    try {
      final response = await _vegetableService
          .addToCart(item['itemId']); // Adjust to send item ID
      setState(() {
        cartItems = response[
            'cart']; // Update local cart state with the server's response
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item added to cart')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
  }

  void navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyCartView(
          cartItems: cartItems,
          userId: widget.userId,
          role: widget.role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Available Vegetables'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: navigateToCart,
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 15),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: txtSearch,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      onChanged: filterItems,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          var pObj = filteredItems[index];
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    pObj["icon"] ??
                                        'assets/img/placeholder.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    pObj["name"] ?? "Unknown Vegetable",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Available Stock: ${pObj["quantity"] ?? 'N/A'} kg",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 17, 48, 28)),
                                  ),
                                  Text(
                                    "Unit Price: Rs. ${pObj["unitprice"] ?? '0'}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 17, 48, 28)),
                                  ),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () => addToCart(pObj),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 17, 48, 28),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text("Add to Cart"),
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
