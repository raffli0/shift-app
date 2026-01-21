import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter/services.dart';

import '../../home/ui/home_page.dart';
import '../../attendance/ui/attendance_page.dart';
import '../../attendance/ui/attendance_history_page.dart';
import '../../request/ui/request_page.dart';
import '../../home/ui/profile_page.dart';

class MainRootPage extends StatefulWidget {
  const MainRootPage({super.key});

  @override
  State<MainRootPage> createState() => _MainRootPageState();
}

class _MainRootPageState extends State<MainRootPage> {
  int index = 0;

  final pages = const [
    HomePage(),
    AttendancePage(),
    RequestsPage(),
    AttendanceHistoryPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _setLightStatusBar();
  }

  void _setLightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // ANDROID → icon putih
        statusBarBrightness: Brightness.dark, // iOS → icon putih
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _setLightStatusBar(); // panggil setiap rebuild

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0c202e),
        body: pages[index],
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
          index: index,
          onChange: (index) => setState(() => this.index = index),
          children: const [
            FBottomNavigationBarItem(
              icon: Icon(FIcons.house),
              label: Text("Home"),
            ),
            FBottomNavigationBarItem(
              icon: Icon(FIcons.calendar),
              label: Text("Attendance"), // Points to History/Calendar now
            ),
            FBottomNavigationBarItem(
              icon: Icon(FIcons.plus),
              label: Text("Request"),
            ),
            FBottomNavigationBarItem(
              icon: Icon(FIcons.clock),
              label: Text("History"),
            ),
            FBottomNavigationBarItem(
              icon: Icon(FIcons.user),
              label: Text("Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
