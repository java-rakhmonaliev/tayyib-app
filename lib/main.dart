import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TayyibApp());
}

class TayyibApp extends StatelessWidget {
  const TayyibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tayyib',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFFFFDF5),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}