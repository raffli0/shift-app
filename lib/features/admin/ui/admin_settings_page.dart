import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import 'admin_office_location_page.dart';
import 'admin_working_hours_page.dart';
import '../../../shared/widgets/app_header.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  // Design Constants
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool pushNotif = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminSettingsPage.kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: "Settings",
              showAvatar: true,
              showBell: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section(
                      title: 'GENERAL',
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: pushNotif,
                            onChanged: (v) => setState(() => pushNotif = v),
                            title: const Text(
                              'Push Notifications',
                              style: TextStyle(
                                color: AdminSettingsPage.kTextPrimary,
                              ),
                            ),
                            activeThumbColor: AdminSettingsPage.kAccentColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                          ),
                          const _Divider(),
                          _NavTile(
                            icon: Icons.map,
                            title: 'Office Location Setup',
                            onTap: () {
                              final adminBloc = context.read<AdminBloc>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: adminBloc,
                                    child: const AdminOfficeLocationPage(),
                                  ),
                                ),
                              );
                            },
                          ),
                          const _Divider(),
                          _NavTile(
                            icon: Icons.access_time,
                            title: 'Working Hours',
                            onTap: () {
                              final adminBloc = context.read<AdminBloc>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: adminBloc,
                                    child: const AdminWorkingHoursPage(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _section(
                      title: 'APPLICATION',
                      child: Column(
                        children: const [
                          _InfoTile(label: 'App Version', value: '1.0.0'),
                          _Divider(),
                          _InfoTile(label: 'Build Number', value: '1'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AdminSettingsPage.kTextSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AdminSettingsPage.kSurfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: Colors.white.withValues(alpha: 0.05));
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AdminSettingsPage.kAccentColor, size: 20),
      title: Text(
        title,
        style: const TextStyle(
          color: AdminSettingsPage.kTextPrimary,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AdminSettingsPage.kTextSecondary,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          color: AdminSettingsPage.kTextPrimary,
          fontSize: 15,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AdminSettingsPage.kTextSecondary,
          fontSize: 14,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
