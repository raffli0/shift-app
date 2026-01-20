import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../../home/ui/home_page.dart';
import '../../attendance/ui/attendance_page.dart';
import '../../attendance/ui/attendance_history_page.dart';
import '../../home/ui/profile_page.dart';
import '../../request/ui/my_requests_list_page.dart';
import 'package:flutter/services.dart';

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
    MyRequestsListPage(),
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
        borderRadius: BorderRadius.only(
          // topLeft: Radius.circular(24),
          // topRight: Radius.circular(24),
          // bottomLeft: Radius.circular(24),
          // bottomRight: Radius.circular(24),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.white, // bisa disesuaikan agar sama dengan theme ForUI
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
              label: Text("Attendance"),
            ),
            FBottomNavigationBarItem(
              icon: Icon(FIcons.plus),
              label: Text("Request"),
            ),
            FBottomNavigationBarItem(
              icon: Icon(FIcons.history),
              label: Text("History"),
            ),
            // FBottomNavigationBarItem(
            //   icon: Icon(FIcons.user),
            //   label: Text("Profile"),
            // ),
          ],
        ),
      ),
    );
  }
}
