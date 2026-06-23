import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/home_screen.dart';
import 'screens/market_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/pro_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const StockScopeApp());
}

class StockScopeApp extends StatelessWidget {
  const StockScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockScope',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4CC9F0),
        scaffoldBackgroundColor: const Color(0xFF08111F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CC9F0),
          secondary: Color(0xFF4CC9F0),
          surface: Color(0xFF142238),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF08111F),
          foregroundColor: Color(0xFFF8FAFC),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF101C2F),
          selectedItemColor: Color(0xFF4CC9F0),
          unselectedItemColor: Color(0xFFAAB6C8),
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (_) {}
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    MarketScreen(),
    PortfolioScreen(),
    ProScreen(),
    LoginScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Pro'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Login'),
        ],
      ),
    );
  }
}

