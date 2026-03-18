import 'package:flutter/material.dart';
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
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level ${data.level} — ${data.levelName}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${data.xp} XP',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
            backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.12),
            valueColor:
                AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
        ),
        if (showLabel && data.xpForNextLevel > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${data.xpForNextLevel} XP to next level',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
