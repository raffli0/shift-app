import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'admin_home_page.dart';
import 'admin_attendance_page.dart';
import 'admin_leave_page.dart';
import 'admin_users_page.dart';
import 'admin_settings_page.dart';

class AdminRootPage extends StatelessWidget {
  const AdminRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AdminRootView();
  }
}

class _AdminRootView extends StatefulWidget {
  const _AdminRootView();

  @override
  State<_AdminRootView> createState() => _AdminRootViewState();
}

class _AdminRootViewState extends State<_AdminRootView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminHomePage(),
    const AdminAttendancePage(),
    const AdminLeavePage(),
    const AdminUsersPage(),
    const AdminSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F13), // Match new dark theme
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          // Optional decoration
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: FBottomNavigationBar(
            index: _currentIndex,
            onChange: (index) => setState(() => _currentIndex = index),
            children: [
              FBottomNavigationBarItem(
                icon: const Icon(FIcons.house),
                label: const Text('Home'),
              ),
              FBottomNavigationBarItem(
                icon: const Icon(FIcons.eye),
                label: const Text('Monitor'),
              ),
              FBottomNavigationBarItem(
                icon: const Icon(FIcons.mail),
                label: const Text('Leaves'),
              ),
              FBottomNavigationBarItem(
                icon: const Icon(FIcons.users),
                label: const Text('Users'),
              ),
              FBottomNavigationBarItem(
                icon: const Icon(FIcons.settings),
                label: const Text('Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
