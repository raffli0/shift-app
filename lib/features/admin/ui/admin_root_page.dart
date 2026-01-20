import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'admin_home_page.dart';
import 'admin_attendance_page.dart';
import 'admin_leave_page.dart';
import 'admin_users_page.dart';
import 'admin_reports_page.dart';

// Placeholder pages for now
// import '../../attendance/ui/attendance_history_page.dart';

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
    const AdminReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0c202e),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _pages[_currentIndex]),
            FBottomNavigationBar(
              index: _currentIndex,
              onChange: (index) => setState(() => _currentIndex = index),
              children: [
                FBottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                ),
                FBottomNavigationBarItem(
                  icon: const Icon(Icons.access_time),
                  label: const Text('Attend'),
                ),
                FBottomNavigationBarItem(
                  icon: const Icon(Icons.event_note),
                  label: const Text('Leave'),
                ),
                FBottomNavigationBarItem(
                  icon: const Icon(Icons.people),
                  label: const Text('Users'),
                ),
                FBottomNavigationBarItem(
                  icon: const Icon(Icons.analytics),
                  label: const Text('Reports'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
