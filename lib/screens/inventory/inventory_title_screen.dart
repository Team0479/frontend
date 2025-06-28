import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryTitleScreen extends StatefulWidget {
  const InventoryTitleScreen({super.key});

  @override
  State<InventoryTitleScreen> createState() => _InventoryTitleScreenState();
}

class _InventoryTitleScreenState extends State<InventoryTitleScreen> {
  List<Map<String, dynamic>> _badges = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _badgeIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBadges();
  }

  Future<void> _fetchBadges() async {
    setState(() { _isLoading = true; _error = null; });
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null) {
      setState(() {
        _error = '로그인이 필요합니다.';
        _isLoading = false;
      });
      return;
    }
    final url = Uri.parse('http://3.37.103.25:8080/api/badges/me/acquired');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _badges = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '조회 실패: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '에러 발생: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> awardBadge() async {
    final userId = int.tryParse(_userIdController.text.trim());
    final badgeId = int.tryParse(_badgeIdController.text.trim());
    if (userId == null || badgeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('userId와 badgeId를 올바르게 입력하세요.')),
      );
      return;
    }
    final url = Uri.parse('http://3.37.103.25:8080/api/badges/award');
    final body = jsonEncode({'userId': userId, 'badgeId': badgeId});
    try {
      final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? '칭호 부여 성공')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('칭호 부여 실패: \\${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    }
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _userIdController,
                            decoration: const InputDecoration(hintText: 'userId'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _badgeIdController,
                            decoration: const InputDecoration(hintText: 'badgeId'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: awardBadge,
                          child: const Text('칭호 부여'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                        ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                        : _badges.isEmpty
                          ? const Center(child: Text('획득한 칭호가 없습니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Colors.grey)))
                          : SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 32),
                                  for (final badge in _badges)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 24.0),
                                      child: Column(
                                        children: [
                                          if (badge['badgeImage'] != null)
                                            Image.network(badge['badgeImage'], width: 120, height: 120, fit: BoxFit.contain),
                                          const SizedBox(height: 8),
                                          Text(badge['badgeName'] ?? '', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontWeight: FontWeight.bold, fontSize: 18)),
                                          const SizedBox(height: 4),
                                          Text(badge['badgeDescription'] ?? '', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 14)),
                                          if (badge['acquiredAt'] != null)
                                            Text('획득일: ${badge['acquiredAt'].toString().substring(0, 10)}', style: const TextStyle(fontFamily: 'Spoqa Han Sans Neo', fontSize: 12, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
