import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class InventoryTitleScreen extends StatelessWidget {
  const InventoryTitleScreen({super.key});

  Widget _buildTitleItem(String title) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontFamily: 'DungGeunMo'),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildTitleItem('칭호 이름'),
              _buildTitleItem('칭호 이름'),
              _buildTitleItem('칭호 이름'),
              _buildTitleItem('칭호 이름'),
              _buildTitleItem('칭호 이름'),
            ],
          ),
        ),
      ),
    );
  }
}
