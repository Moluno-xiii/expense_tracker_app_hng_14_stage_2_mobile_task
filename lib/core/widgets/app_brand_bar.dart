import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBrandBar extends StatelessWidget implements PreferredSizeWidget {
  const AppBrandBar({this.onNotifications, super.key});

  final VoidCallback? onNotifications;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
        child: Row(
          children: [
            const _Avatar(),
            const SizedBox(width: 12),
            Text(
              'Sovereign Ledger',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: tokens.brandDeep,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            _BellButton(onTap: onNotifications),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tokens.softLilacAlt,
        shape: BoxShape.circle,
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Icon(
        Icons.person_outline,
        size: 20,
        color: tokens.brandDeep,
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: tokens.cardSurface,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: tokens.bentoBorder),
          ),
          child: Icon(
            Icons.notifications_outlined,
            size: 20,
            color: tokens.brandDeep,
          ),
        ),
      ),
    );
  }
}
