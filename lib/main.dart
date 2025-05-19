import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/calendar/calendar_main_screen.dart';
import 'screens/square/square_main_screen.dart';
import 'screens/inventory/inventory_main_screen.dart';
import 'screens/inventory/inventory_mission_screen.dart';
import 'screens/inventory/inventory_title_screen.dart';

// Global variable to store reviews (in a real app, this would be a state management solution)
final List<Map<String, dynamic>> globalReviews = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyPlay',
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', ''),
        Locale('en', ''),
      ],
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarMainScreen(),
    const SquareMainScreen(),
    const InventoryMainScreen(),
  ];

  void _onItemTapped(int index) {
    // If navigating to the square screen, rebuild it with any new reviews
    if (index == 2) {
      setState(() {
        _screens[2] = SquareMainScreen();
      });
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '광장',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: '인벤토리',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
} 