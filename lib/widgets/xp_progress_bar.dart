import 'package:flutter/material.dart';
import 'package:sub_zero_design_system/sub_zero_design_system.dart';
import 'package:job_board/models/user_profile.dart';

class XpProgressBar extends StatelessWidget {
  final GamificationData data;
  final bool showLabel;
  final double height;

  const XpProgressBar({
    super.key,
    required this.data,
    this.showLabel = true,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: EdgeInsets.only(bottom: SubZeroSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level ${data.level} — ${data.levelName}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: SubZeroColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: SubZeroColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(SubZeroRadius.xs),
                  ),
                  child: Text(
                    '${data.xp} XP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SubZeroColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: data.levelProgress,
            minHeight: height,
            backgroundColor: SubZeroColors.primary.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(SubZeroColors.primary),
          ),
        ),
        if (showLabel && data.xpForNextLevel > 0)
          Padding(
            padding: EdgeInsets.only(top: SubZeroSpacing.xs),
            child: Text(
              '${data.xpForNextLevel} XP to next level',
              style: theme.textTheme.bodySmall?.copyWith(
                color: SubZeroColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
