import 'package:flutter/material.dart';
import 'package:sub_zero_design_system/sub_zero_design_system.dart';
import 'package:job_board/models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final double size;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.size = 64,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? SubZeroColors.primary.withValues(alpha: 0.12)
                  : SubZeroColors.border.withValues(alpha: 0.3),
              border: Border.all(
                color: isUnlocked
                    ? SubZeroColors.primary
                    : SubZeroColors.border,
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: SubZeroColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              achievement.icon,
              size: size * 0.45,
              color: isUnlocked
                  ? SubZeroColors.primary
                  : SubZeroColors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(height: SubZeroSpacing.xs),
          SizedBox(
            width: size + 16,
            child: Text(
              achievement.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isUnlocked
                    ? SubZeroColors.textPrimary
                    : SubZeroColors.textSecondary.withValues(alpha: 0.5),
                fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
