import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../profile/profile_home_screen.dart';
import '../centers/medical_centers_list_screen.dart';
import '../coverage/coverage_screen.dart';

// Placeholder screens for the other 3 tabs - replace each with the
// real screen once it's built. Keeping them here for now so the
// navigation shell is fully wired and testable today.
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: Text('$title - coming soon', style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // IndexedStack keeps all 4 screens alive in memory simultaneously -
  // switching tabs just changes which one is visible, so scroll
  // position / loaded data on each tab survives switching away and back.
  final List<Widget> _screens = const [
    HomeScreen(),
    CoverageScreen(),
    MedicalCentersListScreen(),
    ProfileHomeScreen()
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3FE0),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: 'Coverage'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), activeIcon: Icon(Icons.add_box), label: 'Centers'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}