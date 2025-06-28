import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryMissionScreen extends StatefulWidget {
  const InventoryMissionScreen({super.key});

  @override
  State<InventoryMissionScreen> createState() => _InventoryMissionScreenState();
}

class _InventoryMissionScreenState extends State<InventoryMissionScreen> {
  List<Map<String, dynamic>> _missions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMissions();
  }

  Future<void> _fetchMissions() async {
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
    final url = Uri.parse('http://3.37.103.25:8080/api/missions/me');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      });
      print('미션 응답: \n${response.body}');
      final decoded = json.decode(response.body);
      if (decoded is List) {
        setState(() {
          _missions = decoded.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else if (decoded is Map && decoded['missions'] is List) {
        setState(() {
          _missions = (decoded['missions'] as List).map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else if (decoded is Map) {
        setState(() {
          _error = decoded['message'] ?? '알 수 없는 에러';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '알 수 없는 응답 형식';
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

  Widget _buildMissionItem(Map<String, dynamic> mission) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission['missionTitle'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'Spoqa Han Sans Neo',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mission['missionDescription'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'Spoqa Han Sans Neo',
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${mission['currentProgress'] ?? 0} / ${mission['targetCount'] ?? 0}',
              style: const TextStyle(
                fontFamily: 'Spoqa Han Sans Neo',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
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
        title: Text('미션 목록', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : _missions.isEmpty
                  ? const Center(child: Text('진행 중인 미션이 없습니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _missions.length,
                      itemBuilder: (context, idx) => _buildMissionItem(_missions[idx]),
                    ),
        ),
      ),
    );
  }
}

class UserMissionScreen extends StatefulWidget {
  final int userId;
  const UserMissionScreen({super.key, required this.userId});

  @override
  State<UserMissionScreen> createState() => _UserMissionScreenState();
}

class _UserMissionScreenState extends State<UserMissionScreen> {
  List<Map<String, dynamic>> _missions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMissions();
  }

  Future<void> _fetchMissions() async {
    setState(() { _isLoading = true; _error = null; });
    final url = Uri.parse('http://3.37.103.25:8080/api/missions/user/${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _missions = data.map((e) => e as Map<String, dynamic>).toList();
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

  Future<void> assignMission() async {
    final url = Uri.parse('http://3.37.103.25:8080/api/missions/assign/${widget.userId}');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? '미션 할당 성공')),
        );
        _fetchMissions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('미션 할당 실패: \\${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    }
  }

  Widget _buildMissionItem(Map<String, dynamic> mission) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission['missionTitle'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'Spoqa Han Sans Neo',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mission['missionDescription'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'Spoqa Han Sans Neo',
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${mission['currentProgress'] ?? 0} / ${mission['targetCount'] ?? 0}',
              style: const TextStyle(
                fontFamily: 'Spoqa Han Sans Neo',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
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
        title: Text('사용자 미션 목록', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: assignMission,
                  child: const Text('미션 할당'),
                ),
              ),
              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    : _missions.isEmpty
                      ? const Center(child: Text('진행 중인 미션이 없습니다.', style: TextStyle(fontFamily: 'Spoqa Han Sans Neo', color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _missions.length,
                          itemBuilder: (context, idx) => _buildMissionItem(_missions[idx]),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
