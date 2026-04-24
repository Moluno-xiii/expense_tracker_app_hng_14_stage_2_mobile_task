import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_controller.dart';

class _Requirement {
  const _Requirement(this.label, this.check);

  final String label;
  final bool Function(String password) check;
}

final _requirements = <_Requirement>[
  _Requirement('At least 8 characters long', (p) => p.length >= 8),
  _Requirement(
    'Contains uppercase & lowercase letters',
    (p) => p.contains(RegExp(r'[a-z]')) && p.contains(RegExp(r'[A-Z]')),
  ),
  _Requirement(
    'Contains numbers or symbols',
    (p) => p.contains(RegExp(r'[0-9]')) || p.contains(RegExp(r'[^A-Za-z0-9]')),
  ),
];

bool _allRequirementsMet(String password) {
  for (final r in _requirements) {
    if (!r.check(password)) return false;
  }
  return true;
}

int _strengthScore(String password) {
  var score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (password.contains(RegExp(r'[a-z]')) &&
      password.contains(RegExp(r'[A-Z]'))) {
    score++;
  }
  if (password.contains(RegExp(r'[0-9]')) ||
      password.contains(RegExp(r'[^A-Za-z0-9]'))) {
    score++;
  }
  return score;
}

String _strengthLabel(int score) {
  switch (score) {
    case 0:
      return '—';
    case 1:
      return 'Weak';
    case 2:
      return 'Fair';
    case 3:
      return 'Good';
    case 4:
      return 'Strong';
    default:
      return '';
  }
}

Color _strengthColor(int score, MyColors tokens, Color primary) {
  switch (score) {
    case 0:
      return tokens.bodyText;
    case 1:
      return tokens.expenseRed;
    case 2:
      return tokens.warningAmber;
    case 3:
      return primary;
    case 4:
      return tokens.incomeGreen;
    default:
      return primary;
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  final _hideCurrent = ValueNotifier<bool>(true);
  final _hideNext = ValueNotifier<bool>(true);
  final _hideConfirm = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    _hideCurrent.dispose();
    _hideNext.dispose();
    _hideConfirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = AuthScope.of(context);
    auth.clearError();
    final ok = await auth.changePassword(
      currentPassword: _current.text,
      newPassword: _next.text,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password updated')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final auth = AuthScope.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('Change Password'),
      ),
      body: ListenableBuilder(
        listenable: auth,
        builder: (_, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const _Heading(),
            const SizedBox(height: 20),
            _FormCard(
              current: _current,
              next: _next,
              confirm: _confirm,
              hideCurrent: _hideCurrent,
              hideNext: _hideNext,
              hideConfirm: _hideConfirm,
              busy: auth.busy,
              error: auth.error,
              onSubmit: _submit,
              onCancel: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 14, color: tokens.bodyText),
                const SizedBox(width: 6),
                Text(
                  'Your connection is securely encrypted.',
                  style: TextStyle(fontSize: 12, color: tokens.bodyText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackPill extends StatelessWidget {
  const _BackPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Material(
        color: tokens.cardSurface,
        shape: const CircleBorder(),
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
            child: Icon(Icons.arrow_back, size: 18, color: tokens.brandDeep),
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: tokens.softLilacAlt,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_reset, size: 26, color: tokens.brandDeep),
        ),
        const SizedBox(height: 16),
        Text(
          'Change Password',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: tokens.headingText,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Update your credentials to maintain strict '
          'account security and data protection.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: tokens.bodyText, height: 1.5),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.current,
    required this.next,
    required this.confirm,
    required this.hideCurrent,
    required this.hideNext,
    required this.hideConfirm,
    required this.busy,
    required this.error,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController current;
  final TextEditingController next;
  final TextEditingController confirm;
  final ValueNotifier<bool> hideCurrent;
  final ValueNotifier<bool> hideNext;
  final ValueNotifier<bool> hideConfirm;
  final bool busy;
  final String? error;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.cardSurface,
          border: Border.all(color: tokens.bentoBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(height: 4, color: Theme.of(context).colorScheme.primary),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Field(
                    label: 'Current Password',
                    hint: 'Enter current password',
                    controller: current,
                    hidden: hideCurrent,
                  ),
                  const SizedBox(height: 20),
                  Divider(color: tokens.dividerSoft, height: 1),
                  const SizedBox(height: 20),
                  _Field(
                    label: 'New Password',
                    hint: '',
                    controller: next,
                    hidden: hideNext,
                  ),
                  const SizedBox(height: 12),
                  _StrengthMeter(controller: next),
                  const SizedBox(height: 16),
                  _RequirementsCard(controller: next),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'Confirm New Password',
                    hint: '',
                    controller: confirm,
                    hidden: hideConfirm,
                  ),
                  _ConfirmMatchHint(next: next, confirm: confirm),
                  if (error != null) ...[
                    const SizedBox(height: 16),
                    _ErrorBanner(message: error!),
                  ],
                  const SizedBox(height: 20),
                  ListenableBuilder(
                    listenable: Listenable.merge([current, next, confirm]),
                    builder: (_, _) {
                      final canSubmit =
                          !busy &&
                          current.text.isNotEmpty &&
                          _allRequirementsMet(next.text) &&
                          next.text == confirm.text &&
                          confirm.text.isNotEmpty;
                      return SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: canSubmit ? onSubmit : null,
                          icon: busy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.autorenew, size: 18),
                          label: const Text(
                            'Update Password',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: busy ? null : onCancel,
                      style: TextButton.styleFrom(
                        backgroundColor: tokens.softLilacAlt,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: tokens.brandDeep,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmMatchHint extends StatelessWidget {
  const _ConfirmMatchHint({required this.next, required this.confirm});

  final TextEditingController next;
  final TextEditingController confirm;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final red = tokens.expenseRed;
    final green = tokens.incomeGreen;
    return ListenableBuilder(
      listenable: Listenable.merge([next, confirm]),
      builder: (_, _) {
        if (confirm.text.isEmpty) {
          return const SizedBox(height: 0);
        }
        final matches = next.text == confirm.text;
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                matches ? Icons.check_circle : Icons.error_outline,
                size: 14,
                color: matches ? green : red,
              ),
              const SizedBox(width: 6),
              Text(
                matches ? 'Passwords match' : "Passwords don't match",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: matches ? green : red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final red = context.tokens.expenseRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 13, color: red)),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.hidden,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueNotifier<bool> hidden;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: tokens.headingText,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: hidden,
          builder: (_, h, _) => TextField(
            controller: controller,
            obscureText: h,
            autocorrect: false,
            enableSuggestions: false,
            autofillHints: const [],
            contextMenuBuilder: (_, _) => const SizedBox.shrink(),
            enableInteractiveSelection: false,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: tokens.inputBorder),
              suffixIcon: IconButton(
                onPressed: () => hidden.value = !h,
                icon: Icon(
                  h ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: tokens.bodyText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    return ListenableBuilder(
      listenable: controller,
      builder: (_, _) {
        final score = _strengthScore(controller.text);
        final color = _strengthColor(score, tokens, primary);
        final label = _strengthLabel(score);
        return Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              Expanded(
                child: _Bar(color: i < score ? color : tokens.softLilacAlt),
              ),
              if (i < 3) const SizedBox(width: 6),
            ],
            const SizedBox(width: 12),
            Text(
              'Strength: ',
              style: TextStyle(fontSize: 12, color: tokens.bodyText),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ListenableBuilder(
      listenable: controller,
      builder: (_, _) {
        final password = controller.text;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.softLilacAlt.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SECURITY REQUIREMENTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: tokens.headingText,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              for (final r in _requirements) ...[
                _RequirementRow(label: r.label, met: r.check(password)),
                const SizedBox(height: 6),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final green = tokens.incomeGreen;
    final inactive = tokens.inputBorder;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            key: ValueKey(met),
            size: 16,
            color: met ? green : inactive,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
              color: met ? tokens.headingText : tokens.bodyText,
            ),
          ),
        ),
      ],
    );
  }
}
