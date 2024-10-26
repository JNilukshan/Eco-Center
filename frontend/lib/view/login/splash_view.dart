import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/login/wlcome_view.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState(){
    // TODO implement initState
    super.initState();
    fireOpenApp();
  }

  void fireOpenApp() async{
    await Future.delayed(const Duration(seconds: 2));
    startApp();
  }

  void startApp(){
    Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder:(context) => const WelcomeView()),(route) => false);

  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.primary,
      body: Center(
       child: 
        Image.asset("assets/img/e1.png" , width:media.width * 0.6 ,)
      ),

    );
  }
}