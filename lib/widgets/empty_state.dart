import 'package:flutter/material.dart';
import 'package:sub_zero_design_system/sub_zero_design_system.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SubZeroSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SubZeroSpacing.lg),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SubZeroColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                icon,
                size: 48,
                color: SubZeroColors.primary.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: SubZeroSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: SubZeroSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SubZeroColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: SubZeroSpacing.lg),
              SubZeroButton(
                label: actionLabel!,
                variant: SubZeroButtonVariant.primary,
                size: SubZeroButtonSize.medium,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
