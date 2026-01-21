import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';

void showAvatarMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // IMPORTANT
    barrierColor: Colors.black.withValues(alpha: 0.35), // optional dim
    builder: (_) {
      final user = context.read<AuthBloc>().state.user;
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            color: Color(0xFF151821),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              FAvatar(
                size: 70,
                image: NetworkImage(
                  'https://i.pravatar.cc/150?u=${user?.fullName ?? "User"}',
                ),
                fallback: Text(
                  (user?.fullName ?? "User").substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    color: Color(0xFFEDEDED),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                user?.fullName ?? "User",
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFFEDEDED),
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                user?.role.toUpperCase() ?? "EMPLOYEE",
                style: const TextStyle(fontSize: 14, color: Color(0xFF9AA0AA)),
              ),

              const SizedBox(height: 20),

              _menuItem(
                icon: FIcons.user,
                text: "View Profile",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/profile");
                },
              ),

              if (context.read<AuthBloc>().state.user?.role != 'admin')
                _menuItem(
                  icon: FIcons.fileText,
                  text: "My Reports",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/user-reports");
                  },
                ),

              _menuItem(
                icon: FIcons.settings,
                text: "Settings",
                onTap: () {
                  Navigator.pop(context);
                  final user = context.read<AuthBloc>().state.user;
                  if (user?.role == 'admin') {
                    Navigator.pushNamed(context, "/admin-settings");
                  } else {
                    Navigator.pushNamed(context, "/settings");
                  }
                },
              ),

              const SizedBox(height: 15),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 15),

              _menuItem(
                icon: FIcons.logOut,
                text: "Sign Out",
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                  // Assuming AuthBloc is provided at the root
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),

              // const SizedBox(height: 10),
              const SizedBox(height: 15),
            ],
          ),
        ),
      );
    },
  );
}

Widget _menuItem({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
  Color color = Colors.white,
}) {
  return ListTile(
    leading: Icon(icon, color: color, size: 24),
    title: Text(
      text,
      style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500),
    ),
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
  );
}
