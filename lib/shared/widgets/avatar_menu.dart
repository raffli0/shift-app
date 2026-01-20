import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

void showAvatarMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // IMPORTANT
    barrierColor: Colors.black.withValues(alpha: 0.35), // optional dim
    builder: (_) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // BLUR LAYER BAWAH
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            color: Color(0xFF16212D), // warna asli bottom sheet kamu
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              FAvatar(
                size: 70,
                image: const NetworkImage(
                  'https://raw.githubusercontent.com/forus-labs/forui/main/samples/assets/avatar.png',
                ),
                fallback: const Text(
                  'JN',
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "John Nathan",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Software Engineer",
                style: TextStyle(fontSize: 14, color: Colors.white70),
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

              _menuItem(
                icon: FIcons.settings,
                text: "Settings",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/settings");
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
