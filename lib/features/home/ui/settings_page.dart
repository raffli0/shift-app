import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotif = false;
  bool locationTracking = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0c202e),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0c202e),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                    title: const Text('Push Notifications'),
                  ),
                  const _Divider(),
                  SwitchListTile(
                    value: locationTracking,
                    onChanged: (v) => setState(() => locationTracking = v),
                    title: const Text('Location Tracking'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

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

            const SizedBox(height: 24),

            _section(
              title: 'APPLICATION',
              child: Column(
                children: const [
                  _InfoTile(label: 'App Version', value: '2.4.1'),
                  _Divider(),
                  _InfoTile(label: 'Build Number', value: '204'),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ===== SECTION WRAPPER (SAMA KAYAK PROFILE) =====
  Widget _section({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: child,
        ),
      ],
    );
  }
}

/* ================= SMALL COMPONENTS ================= */

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
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
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
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1);
  }
}
