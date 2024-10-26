import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  final Function(List<Map<String, dynamic>> updatedCart) updateCart;

  const HomeView({super.key, required this.updateCart});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();

  // List to track cart items
  List<Map<String, dynamic>> cartItems = [];

  // Exclusive offers array with item data
  List<Map<String, dynamic>> exclusiveOfferArr = [
    {
      "name": "Carrot",
      "icon": "assets/img/carrot.jpeg",
      "qty": 7,
      "unit": "kg",
      "price": 350
    },
    {
      "name": "Onion",
      "icon": "assets/img/onion.jpeg",
      "qty": 5,
      "unit": "kg",
      "price": 500
    },
    {
      "name": "Bell Pepper",
      "icon": "assets/img/bell_pepper_red.png",
      "qty": 10,
      "unit": "kg",
      "price": 600
    },
    // Additional items can be added here...
  ];

  // List to hold filtered items based on search input
  List<Map<String, dynamic>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = exclusiveOfferArr; // Initially, show all items
  }

  // Function to filter items based on search input
  void filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredItems = exclusiveOfferArr;
      });
    } else {
      setState(() {
        filteredItems = exclusiveOfferArr
            .where((item) =>
                item['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  // Function to add item to cart
  void addToCart(Map<String, dynamic> item) {
    setState(() {
      bool isFound = false;
      for (var cartItem in cartItems) {
        if (cartItem["name"] == item["name"]) {
          cartItem["qty"] += 1;
          isFound = true;
          break;
        }
      }
      if (!isFound) {
        cartItems.add({...item, "qty": 1}); // Add the item with quantity 1
      }
      widget.updateCart(cartItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 4),
              // Location Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/img/location.png", width: 16, height: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Dambulla",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xffF2F3F2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: txtSearch,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (query) =>
                        filterItems(query), // Apply filter on search
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Banner Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 115,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset("assets/img/banner_top1.png",
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
              // Available Vegetables Section
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Available Vegetables",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              // Filtered Items Grid View
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          borderRadius: BorderRadius.circular(15)),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(pObj["icon"], width: 100, height: 100),
                            const SizedBox(height: 8),
                            Text(
                              pObj["name"],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Available Stock: ${pObj["qty"]} ${pObj["unit"]}",
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 17, 48, 28)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Unit Price: ${pObj["price"]}",
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 17, 48, 28)),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () => addToCart(pObj),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 17, 48, 28),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
