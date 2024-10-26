import 'package:flutter/material.dart';
import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/login/splash_view.dart';
import 'package:center/view/login/loginView.dart'; 
import 'package:center/view/home/home_view.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco-Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Gilroy",
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
        useMaterial3: false,
      ),
      initialRoute: '/splash', // Define initial route
      routes: {
        '/splash': (context) => const SplashView(),
        '/login': (context) => const LoginView(userId: '',), // Define the login route
        '/home': (context) =>
            HomeView(updateCart: (updatedCart) {}), 
      },
      onGenerateRoute: (settings) {
        // Handle unknown routes here if necessary
        return MaterialPageRoute(builder: (context) => const SplashView());
      },
    );
  }
}
