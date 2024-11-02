import 'package:flutter/material.dart';
import 'package:center/view/home/home_view.dart';
import 'package:center/view/my_cart/my_cart_view.dart';
import 'package:center/view/user_profile_view/user_profile.dart';

class MainTabView extends StatefulWidget {
  final String userId;
  final String role; // Add role to differentiate between wholeseller or driver

  const MainTabView({super.key, required this.userId, required this.role});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  int selectTab = 0;
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller?.addListener(() {
      setState(() {
        selectTab = controller?.index ?? 0;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void updateCart(List<Map<String, dynamic>> updatedCart) {
    setState(() {
      cartItems = updatedCart;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: [
          HomeView(
            updateCart: updateCart,
            userId: widget.userId,
            role: widget.role,
          ),
          MyCartView(
            cartItems: cartItems,
            userId: widget.userId,
            role: 'wholeseller',
          ),
          UserProfileView(
            userId: widget.userId,
            role: 'wholeseller',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: TabBar(
            controller: controller,
            indicatorColor: Colors.transparent,
            indicatorWeight: 1,
            labelColor: const Color.fromARGB(255, 17, 48, 28),
            labelStyle: const TextStyle(
              color: Color.fromARGB(255, 17, 48, 28),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelColor: Colors.grey,
            unselectedLabelStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(
                text: "Home",
                icon: Image.asset(
                  "assets/img/store_tab.png",
                  width: 25,
                  height: 25,
                  color: selectTab == 0
                      ? const Color.fromARGB(255, 17, 48, 28)
                      : Colors.grey,
                ),
              ),
              Tab(
                text: "Cart",
                icon: Image.asset(
                  "assets/img/cart_tab.png",
                  width: 25,
                  height: 25,
                  color: selectTab == 1
                      ? const Color.fromARGB(255, 17, 48, 28)
                      : Colors.grey,
                ),
              ),
              Tab(
                text: "Account",
                icon: Image.asset(
                  "assets/img/account_tab.png",
                  width: 25,
                  height: 25,
                  color: selectTab == 2
                      ? const Color.fromARGB(255, 17, 48, 28)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
