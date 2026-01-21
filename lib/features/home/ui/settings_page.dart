import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  // Design Constants matches AdminSettingsPage
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotif = false;
  bool locationTracking = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsPage.kBgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: SettingsPage.kBgColor,
        centerTitle: true,
        leading: const BackButton(color: SettingsPage.kTextPrimary),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: SettingsPage.kTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              title: 'NOTIFICATIONS',
              child: Column(
                children: [
                  SwitchListTile(
                    value: pushNotif,
                    onChanged: (v) => setState(() => pushNotif = v),
                    title: const Text(
                      'Push Notifications',
                      style: TextStyle(color: SettingsPage.kTextPrimary),
                    ),
                    activeThumbColor: SettingsPage.kAccentColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  const _Divider(),
                  SwitchListTile(
                    value: locationTracking,
                    onChanged: (v) => setState(() => locationTracking = v),
                    title: const Text(
                      'Location Tracking',
                      style: TextStyle(color: SettingsPage.kTextPrimary),
                    ),
                    activeThumbColor: SettingsPage.kAccentColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _section(
              title: 'SECURITY',
              child: Column(
                children: [
                  _NavTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {},
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
              color: SettingsPage.kTextSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: SettingsPage.kSurfaceColor,
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
      leading: Icon(icon, color: SettingsPage.kAccentColor, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: SettingsPage.kTextPrimary, fontSize: 15),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: SettingsPage.kTextSecondary,
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
        style: const TextStyle(color: SettingsPage.kTextPrimary, fontSize: 15),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: SettingsPage.kTextSecondary,
          fontSize: 14,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
