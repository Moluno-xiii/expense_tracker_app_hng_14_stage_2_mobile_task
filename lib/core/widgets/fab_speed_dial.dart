import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FabAction {
  const FabAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
}

class FabSpeedDial extends StatefulWidget {
  const FabSpeedDial({required this.actions, super.key});

  final List<FabAction> actions;

  @override
  State<FabSpeedDial> createState() => _FabSpeedDialState();
}

class _FabSpeedDialState extends State<FabSpeedDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _open = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _open.dispose();
    super.dispose();
  }

  void _toggle() {
    final next = !_open.value;
    _open.value = next;
    next ? _ctrl.forward() : _ctrl.reverse();
  }

  void _closeThen(VoidCallback action) {
    _open.value = false;
    _ctrl.reverse();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _open,
      builder: (_, open, _) {
        return Stack(
          children: [
            if (open)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggle,
                  child: Container(color: Colors.black54),
                ),
              ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (final a in widget.actions)
                    _AnimatedMini(
                      ctrl: _ctrl,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _MiniFab(
                          icon: a.icon,
                          onTap: () => _closeThen(a.onTap),
                        ),
                      ),
                    ),
                  _MainFab(open: open, onTap: _toggle),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedMini extends StatelessWidget {
  const _AnimatedMini({required this.ctrl, required this.child});

  final AnimationController ctrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: Axis.horizontal,
      axisAlignment: 1,
      sizeFactor: CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic),
      child: FadeTransition(
        opacity: ctrl,
        child: child,
      ),
    );
  }
}

class _MainFab extends StatelessWidget {
  const _MainFab({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 6,
      shadowColor: primary.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 56,
          height: 56,
          child: AnimatedRotation(
            turns: open ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

class _MiniFab extends StatelessWidget {
  const _MiniFab({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: tokens.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 22, color: tokens.brandDeep),
        ),
      ),
    );
  }
}
