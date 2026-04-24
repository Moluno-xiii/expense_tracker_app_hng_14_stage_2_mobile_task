import 'dart:async';

import 'package:camera/camera.dart';
import 'package:expense_tracker_app_hng_14_stage_2_mobile_task/core/router/routes.dart';
import 'package:expense_tracker_app_hng_14_stage_2_mobile_task/features/auth/data/liveness_controller.dart';
import 'package:facial_liveness_verification/facial_liveness_verification.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'
    show FaceDetectorMode;

import '../../../../core/theme/app_colors.dart';
import 'widgets/enrollment_scaffold.dart';

const customConfig = LivenessConfig(
  challenges: [ChallengeType.blink, ChallengeType.nod, ChallengeType.turnRight],
  shuffleChallenges: false,
  enableAntiSpoofing: false,
  challengeTimeout: Duration(seconds: 30),
  sessionTimeout: Duration(minutes: 5),
  eyeOpenThreshold: 0.55,
  smileThreshold: 0.3,
  headAngleThreshold: 10.0,
  maxHeadAngle: 60.0,
  centerTolerance: 0.6,
  minFaceSize: 0.03,
  maxFaceSize: 0.99,
  requireNeutralPosition: false,
  enableStabilityBuffer: false,
  stabilityGoodFrameCount: 1,
  detectorMode: FaceDetectorMode.fast,
  cameraResolution: ResolutionPreset.low,
  frameSkipRate: 1,
);

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  LivenessDetector _detector = LivenessDetector(customConfig);
  StreamSubscription<LivenessState>? _subscription;
  LivenessState? _state;
  Rect? _faceBox;
  bool _running = false;

  @override
  void dispose() {
    _subscription?.cancel();
    _detector.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    await _subscription?.cancel();
    await _detector.dispose();

    final detector = LivenessDetector(customConfig);
    _detector = detector;
    _subscription = detector.stateStream.listen((s) {
      if (!mounted) return;
      setState(() {
        _state = s;
        _faceBox = detector.faceBoundingBox;
      });
      if (s.type == LivenessStateType.completed) {
        _onCompleted();
      }
    });
    await detector.initialize();
    await detector.start();
    if (!mounted) return;
    setState(() => _running = true);
  }

  Future<void> _stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _detector.stop();
    await _detector.dispose();
    if (!mounted) return;
    setState(() {
      _state = null;
      _faceBox = null;
      _running = false;
    });
  }

  Future<void> _onCompleted() async {
    if (mounted) {
      setState(() {
        _running = false;
        _faceBox = null;
      });
    }
    await _subscription?.cancel();
    _subscription = null;
    await _detector.stop();
    await _detector.dispose();
    if (!mounted) return;
    await LivenessScope.of(context).markVerified();
    if (!mounted) return;
    context.go(Routes.enrollDone);
  }

  @override
  Widget build(BuildContext context) {
    return EnrollmentScaffold(
      centerBrand: true,
      child: Column(
        children: [
          const SizedBox(height: 16),
          const _FaceBadge(),
          const SizedBox(height: 20),
          const _Heading(),
          const SizedBox(height: 20),
          _TopPill(state: _state, running: _running),
          const SizedBox(height: 24),
          _CameraFrame(
            detector: _detector,
            faceBox: _faceBox,
            running: _running,
          ),
          const SizedBox(height: 20),
          const _EncryptedPill(),
          const SizedBox(height: 16),
          _StateIndicator(state: _state, faceBox: _faceBox),
          const SizedBox(height: 16),
          _Actions(
            running: _running,
            onStart: _start,
            onStop: _stop,
            onOverride: () async {
              await LivenessScope.of(context).markVerified();
              if (!context.mounted) return;
              context.go(Routes.overview);
            },
          ),
        ],
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
        Text(
          'Identity Verification',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: tokens.headingText,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We need to perform a quick liveness check',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: tokens.bodyText),
        ),
      ],
    );
  }
}

class _FaceBadge extends StatelessWidget {
  const _FaceBadge();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: tokens.softLilacAlt,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.face_outlined, size: 28, color: tokens.headingText),
    );
  }
}

class _TopPill extends StatelessWidget {
  const _TopPill({required this.state, required this.running});

  final LivenessState? state;
  final bool running;

  @override
  Widget build(BuildContext context) {
    final challenge = state?.currentChallenge;
    final isChallenge =
        running &&
        challenge != null &&
        state?.type == LivenessStateType.challengeInProgress;
    if (isChallenge) {
      return _YellowChallengePill(challenge: challenge);
    }
    return _HintPill(text: _hintFor(state, running));
  }

  static String _hintFor(LivenessState? s, bool running) {
    if (!running) return 'Center your face in the frame';
    switch (s?.type) {
      case LivenessStateType.noFace:
        return s?.message ?? 'Position your face';
      case LivenessStateType.positioning:
        return s?.message ?? 'Hold steady';
      case LivenessStateType.positioned:
        return 'Great, stay still';
      case LivenessStateType.challengeCompleted:
        return 'Nice!';
      case LivenessStateType.completed:
        return 'Verified';
      case LivenessStateType.error:
        return s?.error?.message ?? 'Something went wrong';
      case LivenessStateType.faceDetected:
        return 'Face detected';
      case LivenessStateType.detecting:
      case LivenessStateType.initialized:
      default:
        return 'Center your face in the frame';
    }
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.softLilacAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: tokens.headingText,
            ),
          ),
        ],
      ),
    );
  }
}

class _YellowChallengePill extends StatelessWidget {
  const _YellowChallengePill({required this.challenge});

  final ChallengeType challenge;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: ValueKey(challenge),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5D36A),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          _instructionFor(challenge),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B1C30),
          ),
        ),
      ),
    );
  }

  static String _instructionFor(ChallengeType c) {
    switch (c) {
      case ChallengeType.smile:
        return 'Smile for the camera';
      case ChallengeType.blink:
        return 'Blink twice';
      case ChallengeType.turnLeft:
        return 'Turn your head left';
      case ChallengeType.turnRight:
        return 'Turn your head right';
      case ChallengeType.nod:
        return 'Nod your head';
      case ChallengeType.headShake:
        return 'Shake your head';
    }
  }
}

class _CameraFrame extends StatelessWidget {
  const _CameraFrame({
    required this.detector,
    required this.faceBox,
    required this.running,
  });

  final LivenessDetector detector;
  final Rect? faceBox;
  final bool running;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    final controller = detector.cameraController;
    final ready = controller != null && controller.value.isInitialized;
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tokens.softLilacAlt,
        border: Border.all(color: primary, width: 6),
      ),
      child: ClipOval(
        child: ready && running
            ? _LivePreview(controller: controller, faceBox: faceBox)
            : Icon(
                Icons.videocam_outlined,
                size: 56,
                color: tokens.inputBorder,
              ),
      ),
    );
  }
}

class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.controller, required this.faceBox});

  final CameraController controller;
  final Rect? faceBox;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final frameSize = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: previewSize?.height ?? frameSize.width,
                height: previewSize?.width ?? frameSize.height,
                child: CameraPreview(controller),
              ),
            ),
            if (faceBox != null && previewSize != null)
              CustomPaint(
                painter: _FaceBoxPainter(
                  rect: CoordinateUtils.convertImageRectToScreenRect(
                    faceBox!,
                    previewSize,
                    frameSize,
                  ),
                  color: Theme.of(ctx).colorScheme.primary,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FaceBoxPainter extends CustomPainter {
  _FaceBoxPainter({required this.rect, required this.color});

  final Rect rect;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = color;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceBoxPainter old) =>
      old.rect != rect || old.color != color;
}

class _EncryptedPill extends StatelessWidget {
  const _EncryptedPill();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: tokens.brandDeep.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 14, color: tokens.headingText),
          const SizedBox(width: 6),
          Text(
            'End-to-end encrypted',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tokens.headingText,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateIndicator extends StatelessWidget {
  const _StateIndicator({required this.state, required this.faceBox});

  final LivenessState? state;
  final Rect? faceBox;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final s = state;
    final idx = s == null ? '—' : '${s.challengeIndex}/${s.totalChallenges}';
    final stateName = s?.type.name ?? '—';
    final face = faceBox != null ? '✓' : '—';
    final error = s?.error?.message ?? s?.message ?? '—';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.softLilacAlt.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          color: tokens.headingText,
          height: 1.4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('idx: $idx')),
                Expanded(child: Text('face: $face')),
              ],
            ),
            const SizedBox(height: 2),
            Text('state: $stateName'),
            const SizedBox(height: 2),
            Text('error: $error', maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.running,
    required this.onStart,
    required this.onStop,
    required this.onOverride,
  });

  final bool running;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onOverride;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: running ? null : onStart,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start Verification'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: running ? onStop : null,
          style: TextButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size.fromHeight(44),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onOverride,
          style: TextButton.styleFrom(foregroundColor: Colors.orange),
          child: const Text('Override → Overview (dev only)'),
        ),
      ],
    );
  }
}
