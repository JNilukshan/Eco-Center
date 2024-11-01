import 'package:center/view/home/vegetableservice.dart';
import 'package:center/view/home/cartservice.dart';
import 'package:flutter/material.dart';
import 'package:center/common/color_extrnsion.dart';

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
      // Step 1: Fetch current cart items
      List<Map<String, dynamic>> currentCartItems =
          await _cartService.fetchCart(userId);

      // Step 2: Check if item exists and update quantity
      bool isFound = false;
      for (var cartItem in currentCartItems) {
        if (cartItem["itemId"] == newItem["_id"]) {
          cartItem["quantity"] = (cartItem["quantity"] ?? 0) + 1;
          isFound = true;
          break;
        }
      }

      // Step 3: If item not found, add it with required structure
      if (!isFound) {
        currentCartItems.add({
          "itemId": newItem["_id"], // Make sure your vegetable objects have _id
          "name": newItem["name"],
          "quantity": 1,
          "unitprice": newItem["unitprice"],
        });
      }

      // Step 4: Save updated cart
      await _cartService.saveCart(userId, currentCartItems);

      // Step 5: Show success message
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
        backgroundColor: TColor.primary,
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
