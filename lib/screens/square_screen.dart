import 'package:flutter/material.dart';

class SquareScreen extends StatelessWidget {
  const SquareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('광장'),
      ),
      body: const Center(
        child: Text('광장 화면'),
      ),
    );
  }
} 