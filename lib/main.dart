import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ChessGameApp());
}

class ChessGameApp extends StatelessWidget {
  const ChessGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}