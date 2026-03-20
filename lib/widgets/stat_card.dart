import 'package:flutter/material.dart';
import 'package:sub_zero_design_system/sub_zero_design_system.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? SubZeroColors.primary;

    return SubZeroCard(
      onTap: onTap,
      body: Padding(
        padding: EdgeInsets.all(SubZeroSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SubZeroSpacing.sm),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(SubZeroRadius.sm),
              ),
              child: Icon(icon, color: cardColor, size: 20),
            ),
            SizedBox(height: SubZeroSpacing.sm),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: cardColor,
              ),
            ),
            SizedBox(height: SubZeroSpacing.xs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: SubZeroColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
