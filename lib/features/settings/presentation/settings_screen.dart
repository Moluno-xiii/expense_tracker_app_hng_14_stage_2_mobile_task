import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme_controller.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_brand_bar.dart';
import '../../auth/data/auth_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _biometrics = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _biometrics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppBrandBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                _ProfileCard(
                  onTap: () => context.push(Routes.settingsProfile),
                ),
                const SizedBox(height: 12),
                const _DualTileRow(),
                const SizedBox(height: 20),
                const _SectionLabel(text: 'SECURITY & ACCESS'),
                const SizedBox(height: 10),
                _BiometricsRow(value: _biometrics),
                const SizedBox(height: 10),
                _PasswordRow(
                  onTap: () => context.push(Routes.settingsPassword),
                ),
                const SizedBox(height: 20),
                const _SectionLabel(text: 'PREFERENCES'),
                const SizedBox(height: 10),
                const _DarkModeRow(),
                const SizedBox(height: 10),
                _NavRow(
                  icon: Icons.attach_money,
                  title: 'Currency',
                  subtitle: 'USD (\$)',
                  onTap: () => context.push(Routes.settingsCurrency),
                ),
                const SizedBox(height: 10),
                _NavRow(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English (US)',
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _NavRow(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'FAQs and direct support',
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                const _SectionLabel(text: 'MANAGE'),
                const SizedBox(height: 10),
                _NavRow(
                  icon: Icons.autorenew,
                  title: 'Recurring Rules',
                  subtitle: 'Automate income and expenses',
                  onTap: () => context.push(Routes.settingsRecurring),
                ),
                const SizedBox(height: 10),
                _NavRow(
                  icon: Icons.folder_outlined,
                  title: 'Categories',
                  subtitle: 'Manage your buckets',
                  onTap: () => context.push(Routes.settingsCategories),
                ),
                const SizedBox(height: 10),
                _NavRow(
                  icon: Icons.ios_share,
                  title: 'Export',
                  subtitle: 'CSV or PDF',
                  onTap: () => context.push(Routes.settingsExport),
                ),
                const SizedBox(height: 20),
                _SignOutButton(
                  onTap: () async {
                    await AuthScope.of(context).signOut();
                    if (context.mounted) context.go(Routes.login);
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'SOVEREIGN LEDGER V2.4.0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.tokens.bodyText,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final auth = AuthScope.of(context);
    return ListenableBuilder(
      listenable: auth,
      builder: (_, _) {
        final name = auth.user?.displayName?.trim();
        final email = auth.user?.email ?? '';
        final label = (name == null || name.isEmpty) ? email : name;
        return Material(
          color: tokens.cardSurface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tokens.bentoBorder),
              ),
              child: Row(
                children: [
                  _AvatarWithCheck(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label.isEmpty ? 'Your profile' : label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: tokens.headingText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 12,
                            color: tokens.bodyText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: tokens.bodyText),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AvatarWithCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tokens.softLilacAlt,
              shape: BoxShape.circle,
              border: Border.all(color: tokens.bentoBorder),
            ),
            child: Icon(
              Icons.person,
              size: 28,
              color: tokens.brandDeep,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: tokens.incomeGreen,
                shape: BoxShape.circle,
                border: Border.all(color: tokens.cardSurface, width: 2),
              ),
              child: const Icon(
                Icons.check,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DualTileRow extends StatelessWidget {
  const _DualTileRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _LedgerTile()),
        SizedBox(width: 10),
        Expanded(child: _UpgradeTile()),
      ],
    );
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.credit_card_outlined,
              size: 22, color: tokens.brandDeep),
          const SizedBox(height: 18),
          Text(
            'Default Ledger',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: tokens.bodyText,
            ),
          ),
          Text(
            'Main Savings',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: tokens.headingText,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeTile extends StatelessWidget {
  const _UpgradeTile();

  @override
  Widget build(BuildContext context) {
    final navy = context.tokens.brandDeep;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [navy, const Color(0xFF0051D5)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, size: 22, color: Colors.white),
          const SizedBox(height: 18),
          const Text(
            'Upgrade to Sovereign\nExecutive',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: context.tokens.bodyText,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _BiometricsRow extends StatelessWidget {
  const _BiometricsRow({required this.value});

  final ValueNotifier<bool> value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return _TileShell(
      child: Row(
        children: [
          _IconBox(icon: Icons.fingerprint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometrics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: tokens.headingText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'FaceID or TouchID Enabled',
                  style: TextStyle(
                    fontSize: 12,
                    color: tokens.bodyText,
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: value,
            builder: (_, v, _) => Switch(
              value: v,
              onChanged: (x) => value.value = x,
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordRow extends StatelessWidget {
  const _PasswordRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _NavRow(
      icon: Icons.dialpad_outlined,
      title: 'User Password',
      onTap: onTap,
    );
  }
}

class _DarkModeRow extends StatelessWidget {
  const _DarkModeRow();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final controller = ThemeControllerScope.of(context);
    return _TileShell(
      child: Row(
        children: [
          _IconBox(icon: Icons.dark_mode_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: tokens.headingText,
              ),
            ),
          ),
          CupertinoSwitch(
            value: controller.isDark,
            onChanged: controller.setDark,
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return _TileShell(
      onTap: onTap,
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: tokens.headingText,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: tokens.bodyText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: tokens.bodyText),
        ],
      ),
    );
  }
}

class _TileShell extends StatelessWidget {
  const _TileShell({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: tokens.cardSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tokens.bentoBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tokens.softLilacAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: tokens.brandDeep),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final red = context.tokens.expenseRed;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.logout, color: red, size: 18),
        label: Text(
          'Sign Out',
          style: TextStyle(
            color: red,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: red.withValues(alpha: 0.12),
          foregroundColor: red,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
