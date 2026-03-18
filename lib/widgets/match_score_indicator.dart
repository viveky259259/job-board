import 'package:flutter/material.dart';
import 'package:job_board/core/theme/app_theme.dart';

class MatchScoreIndicator extends StatelessWidget {
  final int score;
  final double size;
  final double strokeWidth;

  const MatchScoreIndicator({
    super.key,
    required this.score,
    this.size = 48,
    this.strokeWidth = 3.5,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.matchScoreColor(score);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: strokeWidth,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Text(
            '$score%',
            style: TextStyle(
              fontSize: size * 0.28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
