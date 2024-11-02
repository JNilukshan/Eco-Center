import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:io' show Platform;
import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/login/splash_view.dart';
import 'package:center/view/login/loginView.dart';
import 'package:center/view/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Conditionally set up Stripe for mobile platforms only
  if (Platform.isAndroid || Platform.isIOS) {
    Stripe.publishableKey =
        'pk_test_51QFpqSF5Av59QJJj9nl3sOB5FCIn56jvjVzFEZxiceMA4P9fDfcsWLD5T5HqyW3rzkQLc4cqGwKHcOkteYx1zfdw00wxz3OhS5'; // Replace with your actual Stripe publishable key
  } else {
    print("Stripe is not supported on this platform.");
  }

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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashView(),
        '/login': (context) => const LoginView(userId: 'userId'),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => HomeView(
              updateCart: (updatedCart) {},
              userId: args['userId'],
              role: args['role'],
            ),
          );
        }
        return MaterialPageRoute(builder: (context) => const SplashView());
      },
    );
  }
}
