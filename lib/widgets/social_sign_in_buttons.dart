import 'package:flutter/material.dart';

class SocialSignInButtons extends StatelessWidget {
  final VoidCallback? onGoogle;
  final VoidCallback? onGitHub;
  final bool isLoading;

  const SocialSignInButtons({
    super.key,
    this.onGoogle,
    this.onGitHub,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _SocialButton(
          onPressed: isLoading ? null : onGoogle,
          icon: _googleIcon(),
          label: 'Continue with Google',
          theme: theme,
        ),
        const SizedBox(height: 10),
        _SocialButton(
          onPressed: isLoading ? null : onGitHub,
          icon: _githubIcon(theme),
          label: 'Continue with GitHub',
          theme: theme,
        ),
      ],
    );
  }

  Widget _googleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }

  Widget _githubIcon(ThemeData theme) {
    return Icon(
      Icons.code,
      size: 20,
      color: theme.colorScheme.onSurface,
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final ThemeData theme;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint blue = Paint()..color = const Color(0xFF4285F4);
    final Paint red = Paint()..color = const Color(0xFFEA4335);
    final Paint yellow = Paint()..color = const Color(0xFFFBBC05);
    final Paint green = Paint()..color = const Color(0xFF34A853);

    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Blue (top-right arc)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      1.2,
      true,
      blue,
    );
    // Red (top-left arc)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.7,
      1.2,
      true,
      red,
    );
    // Yellow (bottom-left arc)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.9,
      1.2,
      true,
      yellow,
    );
    // Green (bottom-right arc)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.7,
      1.2,
      true,
      green,
    );

    // White inner circle
    canvas.drawCircle(
      center,
      radius * 0.55,
      Paint()..color = Colors.white,
    );

    // Blue bar (right side of G)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.48, h * 0.38, w * 0.52, h * 0.24),
      blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'or',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
        ],
      ),
    );
  }
}
