import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/ui/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authState = context.select((AuthBloc bloc) => bloc.state);
    final user = authState.user;
    final companyName = authState.companyName;

    return Scaffold(
      backgroundColor: const Color(0xFF0c202e),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0c202e),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => _showEditDialog(context, user, companyName),
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _profileHeader(user?.fullName, user?.role),
              const SizedBox(height: 20),
              _quickActions(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                child: const Text(
                  "Your face data is used for secure and quick attendance verification.",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 24),
              _section(
                title: 'CONTACT INFORMATION',
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.email,
                      title: 'Email',
                      value: user?.email ?? 'Unknown',
                      onTap: () => _showSingleFieldEditDialog(
                        context,
                        title: 'Edit Email',
                        label: 'Email',
                        initialValue: user?.email ?? '',
                        onSave: (value) {
                          context.read<AuthBloc>().add(
                            AuthProfileUpdateRequested(
                              fullName: user!.fullName,
                              email: value,
                              phone: user.phone,
                              department: user.department,
                              manager: user.manager,
                              companyName: companyName,
                            ),
                          );
                        },
                      ),
                    ),
                    const _Divider(),
                    _InfoTile(
                      icon: Icons.phone,
                      title: 'Phone',
                      value: user?.phone ?? 'Not set',
                      onTap: () => _showSingleFieldEditDialog(
                        context,
                        title: 'Edit Phone',
                        label: 'Phone Number',
                        initialValue: user?.phone ?? '',
                        onSave: (value) {
                          context.read<AuthBloc>().add(
                            AuthProfileUpdateRequested(
                              fullName: user!.fullName,
                              email: user.email,
                              phone: value,
                              department: user.department,
                              manager: user.manager,
                              companyName: companyName,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _section(
                title: 'EMPLOYMENT DETAILS',
                child: Column(
                  children: [
                    _RowTile(
                      label: 'Department',
                      value: user?.department ?? 'Not set',
                    ),
                    const _Divider(),
                    _RowTile(label: 'Company', value: companyName ?? 'Not set'),
                    const _Divider(),
                    _RowTile(
                      label: 'Employee ID',
                      value: user?.employeeId ?? 'Not set',
                    ),
                    const _Divider(),
                    _RowTile(
                      label: 'Manager',
                      value: user?.manager ?? 'Not set',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'App Version 1.1 (Build 2)',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSingleFieldEditDialog(
    BuildContext context, {
    required String title,
    required String label,
    required String initialValue,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    dynamic user,
    String? currentCompanyName,
  ) {
    if (user == null) return;

    final nameController = TextEditingController(text: user.fullName);
    final deptController = TextEditingController(text: user.department ?? '');
    final managerController = TextEditingController(text: user.manager ?? '');
    final companyController = TextEditingController(
      text: currentCompanyName ?? '',
    );
    final isAdmin = user.role == 'admin';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: managerController,
                  decoration: const InputDecoration(labelText: 'Manager'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                AuthProfileUpdateRequested(
                  fullName: nameController.text,
                  email: user.email,
                  phone: user.phone,
                  department: isAdmin ? deptController.text : user.department,
                  manager: isAdmin ? managerController.text : user.manager,
                  companyName: isAdmin ? companyController.text : null,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader(String? name, String? role) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/300?u=${name ?? "User"}',
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name ?? 'John Nathan',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          role?.toUpperCase() ?? 'Software Engineer',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '● ACTIVE • Bandung, Indonesia',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickActions() {
    return Row(children: [_actionButton(Icons.badge, 'View ID Card')]);
  }

  Widget _actionButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

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

/* ===== SMALL COMPONENTS ===== */

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _RowTile extends StatelessWidget {
  final String label;
  final String value;

  const _RowTile({required this.label, required this.value});

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
