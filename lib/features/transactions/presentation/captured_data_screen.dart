import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'add_transaction_screen.dart' show DottedBox;

class CapturedDataScreen extends StatelessWidget {
  const CapturedDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('Captured Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: DottedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Result of captured data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: tokens.headingText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Coming soon',
                style: TextStyle(fontSize: 14, color: tokens.bodyText),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: null,
              child: const Text('Save Up!'),
            ),
          ),
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
