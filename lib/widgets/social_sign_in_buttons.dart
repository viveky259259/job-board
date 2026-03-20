import 'package:flutter/material.dart';
import 'package:sub_zero_design_system/sub_zero_design_system.dart';

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
    return Column(
      children: [
        SubZeroButton(
          label: 'Continue with Google',
          variant: SubZeroButtonVariant.secondary,
          size: SubZeroButtonSize.large,
          fullWidth: true,
          onPressed: isLoading ? null : onGoogle,
          leadingIcon: Icons.g_mobiledata,
        ),
        SizedBox(height: SubZeroSpacing.sm),
        SubZeroButton(
          label: 'Continue with GitHub',
          variant: SubZeroButtonVariant.secondary,
          size: SubZeroButtonSize.large,
          fullWidth: true,
          onPressed: isLoading ? null : onGitHub,
          leadingIcon: Icons.code,
        ),
      ],
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SubZeroSpacing.lg),
      child: Row(
        children: [
          const Expanded(child: SubZeroDivider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SubZeroSpacing.md),
            child: Text(
              'or',
              style: theme.textTheme.bodySmall?.copyWith(
                color: SubZeroColors.textSecondary,
              ),
            ),
          ),
          const Expanded(child: SubZeroDivider()),
        ],
      ),
    );
  }
}
