import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/ui/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  // Design Constants
  static const kBgColor = Color(0xFF0E0F13);
  static const kSurfaceColor = Color(0xFF151821);
  static const kAccentColor = Color(0xFF7C7FFF);
  static const kTextPrimary = Color(0xFFEDEDED);
  static const kTextSecondary = Color(0xFF9AA0AA);

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
      backgroundColor: ProfilePage.kBgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ProfilePage.kBgColor,
        centerTitle: true,
        leading: const BackButton(color: ProfilePage.kTextPrimary),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: ProfilePage.kTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _showEditDialog(context, user, companyName),
            child: const Text(
              'Edit',
              style: TextStyle(
                color: ProfilePage.kAccentColor,
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
                  style: TextStyle(
                    color: ProfilePage.kTextSecondary,
                    fontSize: 12,
                  ),
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
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(
                    color: Colors.redAccent.withValues(alpha: 0.5),
                  ),
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
                style: TextStyle(
                  color: ProfilePage.kTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... existing methods like _showSingleFieldEditDialog ...
  void _showSingleFieldEditDialog(
    BuildContext context, {
    required String title,
    required String label,
    required String initialValue,
    required Function(String) onSave,
  }) {
    // ... implementation
    // Truncated for brevity, assuming standard dialogs
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ProfilePage.kSurfaceColor,
        title: Text(
          title,
          style: const TextStyle(color: ProfilePage.kTextPrimary),
        ),
        content: SingleChildScrollView(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: ProfilePage.kTextPrimary),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: ProfilePage.kTextSecondary),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ProfilePage.kTextSecondary),
              ),
            ),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ProfilePage.kTextSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfilePage.kAccentColor,
              foregroundColor: Colors.white,
            ),
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
        backgroundColor: ProfilePage.kSurfaceColor,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: ProfilePage.kTextPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: ProfilePage.kTextPrimary),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: ProfilePage.kTextSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ProfilePage.kTextSecondary),
                  ),
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: deptController,
                  style: const TextStyle(color: ProfilePage.kTextPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    labelStyle: TextStyle(color: ProfilePage.kTextSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ProfilePage.kTextSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: managerController,
                  style: const TextStyle(color: ProfilePage.kTextPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Manager',
                    labelStyle: TextStyle(color: ProfilePage.kTextSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ProfilePage.kTextSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: companyController,
                  style: const TextStyle(color: ProfilePage.kTextPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    labelStyle: TextStyle(color: ProfilePage.kTextSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ProfilePage.kTextSecondary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ProfilePage.kTextSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfilePage.kAccentColor,
              foregroundColor: Colors.white,
            ),
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
                backgroundColor: ProfilePage.kAccentColor,
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
          name ?? 'User',
          style: const TextStyle(
            color: ProfilePage.kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          role?.toUpperCase() ?? 'EMPLOYEE',
          style: const TextStyle(color: ProfilePage.kTextSecondary),
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
    return Row(children: [_actionButton(Icons.badge_outlined, 'View ID Card')]);
  }

  Widget _actionButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: ProfilePage.kSurfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: ProfilePage.kAccentColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: ProfilePage.kTextPrimary,
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
        Text(
          title,
          style: const TextStyle(
            color: ProfilePage.kTextSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ProfilePage.kSurfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
      leading: Icon(icon, color: ProfilePage.kAccentColor),
      title: Text(
        title,
        style: const TextStyle(color: ProfilePage.kTextPrimary),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(color: ProfilePage.kTextSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: ProfilePage.kTextSecondary,
      ),
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
      title: Text(
        label,
        style: const TextStyle(color: ProfilePage.kTextSecondary),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: ProfilePage.kTextPrimary,
        ),
      ),
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
