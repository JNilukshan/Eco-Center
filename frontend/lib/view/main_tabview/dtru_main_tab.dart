import 'package:flutter/material.dart';
import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/home/TrackOrderLocationView.dart';
import 'package:center/view/home/dtru_noti_home.dart';
import 'package:center/view/user_profile_view/user_profile.dart';

class DTruMainTabView extends StatefulWidget {
  final String userId;
  final String role; // Added role as a required parameter

  const DTruMainTabView({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  State<DTruMainTabView> createState() => _DTruMainTabViewState();
}

class _DTruMainTabViewState extends State<DTruMainTabView>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  int selectTab = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: [
          DTruNotificationHome(userId: widget.userId, role: widget.role),
          TrackOrderLocationView(userId: widget.userId, role: widget.role),
          UserProfileView(
              userId: widget.userId,
              role: widget
                  .role), // Pass role as driver or wholeseller as required
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
            labelColor: TColor.primary,
            labelStyle: TextStyle(
              color: TColor.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelColor: TColor.primaryText,
            unselectedLabelStyle: TextStyle(
              color: TColor.primaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(
                text: "Notification",
                icon: Image.asset(
                  "assets/img/a_noitification.png",
                  width: 25,
                  height: 25,
                  color: selectTab == 0 ? TColor.primary : TColor.primaryText,
                ),
              ),
              Tab(
                text: "Track",
                icon: Image.asset(
                  "assets/img/track.png",
                  width: 25,
                  height: 25,
                  color: selectTab == 1 ? TColor.primary : TColor.primaryText,
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
