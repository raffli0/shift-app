import 'package:flutter/material.dart';
import 'package:forui/forui.dart' hide Icon;
import 'avatar_menu.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showAvatar;
  final bool showBell;
  final VoidCallback? onBellTap;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.title,
    this.showAvatar = true,
    this.showBell = true,
    this.onBellTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // CENTER TITLE
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            // LEFT ACTION (Avatar or Back)
            if (onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                ),
              )
            else if (showAvatar)
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => showAvatarMenu(context),
                  child: FAvatar(
                    size: 36,
                    image: const NetworkImage(
                      'https://raw.githubusercontent.com/forus-labs/forui/main/samples/assets/avatar.png',
                    ),
                    fallback: const Text('JN'),
                  ),
                ),
              ),

            // RIGHT BELL ICON
            if (showBell)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      Colors.white.withAlpha(20),
                    ),
                  ),
                  icon: Icon(FIcons.bell, size: 26, color: Colors.white),
                  onPressed:
                      onBellTap ??
                      () {
                        Navigator.pushNamed(context, '/notif');
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(content: Text("No notifications")),
                        // );
                      },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
