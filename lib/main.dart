import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'theme/colors.dart';
import 'screens/home_screen.dart';
import 'screens/calendar/calendar_main_screen.dart';
import 'screens/square/square_main_screen.dart';
import 'screens/inventory/inventory_main_screen.dart';
import 'screens/login_screen.dart';

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
      home: const LoginScreen(),
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
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: AppColors.navBarBackground,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/nav_home_unselected.png', width: 50, height: 50),
            activeIcon: Image.asset('assets/images/nav_home.png', width: 50, height: 50),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/nav_calendar_unselected.png', width: 50, height: 50),
            activeIcon: Image.asset('assets/images/nav_calendar.png', width: 50, height: 50),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/nav_square_unselected.png', width: 50, height: 50),
            activeIcon: Image.asset('assets/images/nav_square.png', width: 50, height: 50),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/nav_inventory_unselected.png', width: 50, height: 50),
            activeIcon: Image.asset('assets/images/nav_inventory.png', width: 50, height: 50),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
} 