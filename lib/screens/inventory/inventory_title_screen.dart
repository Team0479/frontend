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

  // 칭호와 미션 매핑 (badgeId는 실제 서버의 badgeId와 맞춰야 함)
  final List<Map<String, dynamic>> _titles = [
    {
      'badgeId': 1,
      'color': 'assets/images/title1.png',
      'gray': 'assets/images/title1_gray.png',
      'label': '레전더리 플레이어',
    },
    {
      'badgeId': 2,
      'color': 'assets/images/title2.png',
      'gray': 'assets/images/title2_gray.png',
      'label': '문화생활 아티스트',
      'missionMatch': '캘린더에 일정 등록',
    },
    {
      'badgeId': 3,
      'color': 'assets/images/title3.png',
      'gray': 'assets/images/title3_gray.png',
      'label': '좋아요 5개 누르기',
      'missionMatch': '좋아요 5개 누르기',
    },
    {
      'badgeId': 4,
      'color': 'assets/images/title4.png',
      'gray': 'assets/images/title4_gray.png',
      'label': '광장에서 리뷰 쓰기',
      'missionMatch': '리뷰 3개 작성',
    },
    {
      'badgeId': 5,
      'color': 'assets/images/title5.png',
      'gray': 'assets/images/title5_gray.png',
      'label': '댓글 5개 작성',
      'missionMatch': '댓글 5개 작성',
    },
  ];

  List<Map<String, dynamic>> _missions = [];
  List<int> _acquiredBadgeIds = [];

  @override
  void initState() {
    super.initState();
    _fetchMissions();
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
    final url = Uri.parse('http://3.37.103.25:8080/api/badges/me');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      });
      final decoded = json.decode(response.body);
      print('받아온 칭호 목록:');
      if (decoded is List) {
        for (final badge in decoded) {
          print('badgeId: \\${badge['badgeId']}, name: \\${badge['name']}, isAcquired: \\${badge['isAcquired']}');
        }
      } else if (decoded is Map && decoded['badges'] is List) {
        for (final badge in decoded['badges']) {
          print('badgeId: \\${badge['badgeId']}, name: \\${badge['name']}, isAcquired: \\${badge['isAcquired']}');
        }
      } else {
        print('칭호 응답 형식이 예상과 다릅니다: $decoded');
      }
      List<Map<String, dynamic>> badges = [];
      if (decoded is List) {
        badges = decoded.map((e) => e as Map<String, dynamic>).toList();
      } else if (decoded is Map && decoded['badges'] is List) {
        badges = (decoded['badges'] as List).map((e) => e as Map<String, dynamic>).toList();
      }
      setState(() {
        _acquiredBadgeIds = badges.where((b) => b['isAcquired'] == true).map((b) => b['badgeId'] as int).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '에러 발생: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null) return;
    final url = Uri.parse('http://3.37.103.25:8080/api/missions/me');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      });
      final decoded = json.decode(response.body);
      List<Map<String, dynamic>> missions = [];
      if (decoded is List) {
        missions = decoded.map((e) => e as Map<String, dynamic>).toList();
      } else if (decoded is Map && decoded['missions'] is List) {
        missions = (decoded['missions'] as List).map((e) => e as Map<String, dynamic>).toList();
      }
      setState(() {
        _missions = missions;
      });
    } catch (e) {
      // ignore
    }
  }

  bool _isBadgeAcquired(int badgeId) {
    return _acquiredBadgeIds.contains(badgeId);
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _titles.length; i++) ...[
                    Image.asset(
                      _isBadgeAcquired(_titles[i]['badgeId'])
                        ? _titles[i]['color']
                        : _titles[i]['gray'],
                      width: 280,
                      fit: BoxFit.contain,
                    ),
                    if (i != _titles.length - 1)
                      const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
