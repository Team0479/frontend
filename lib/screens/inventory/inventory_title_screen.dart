import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class InventoryTitleScreen extends StatelessWidget {
  const InventoryTitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleImages = [
      'assets/images/title1.png',
      'assets/images/title2.png',
      'assets/images/title3.png',
      'assets/images/title4.png',
      'assets/images/title5.png',
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('마이 칭호', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/title_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    for (final img in titleImages)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.asset(img, width: 320),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
