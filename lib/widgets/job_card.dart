import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sub_zero_design_system/sub_zero_design_system.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:job_board/core/theme/app_theme.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/widgets/match_score_indicator.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final bool isSaved;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onSave,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SubZeroCard(
      onTap: onTap,
      body: Padding(
        padding: EdgeInsets.all(SubZeroSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildLogo(),
                SizedBox(width: SubZeroSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: SubZeroSpacing.xs),
                      Text(
                        job.company,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: SubZeroColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                MatchScoreIndicator(score: job.matchScore, size: 44),
              ],
            ),
            SizedBox(height: SubZeroSpacing.sm),
            Wrap(
              spacing: SubZeroSpacing.sm,
              runSpacing: SubZeroSpacing.xs,
              children: [
                SubZeroTag(label: job.location, variant: SubZeroTagVariant.outlined),
                SubZeroTag(label: job.jobType, variant: SubZeroTagVariant.outlined),
                SubZeroTag(label: job.remote, variant: SubZeroTagVariant.outlined),
                if (job.salaryMin != null || job.salaryMax != null)
                  SubZeroTag(label: job.salaryRange, variant: SubZeroTagVariant.outlined),
              ],
            ),
            SizedBox(height: SubZeroSpacing.sm),
            Row(
              children: [
                if (job.postedAt != null)
                  Text(
                    timeago.format(job.postedAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: SubZeroColors.textSecondary,
                    ),
                  ),
                if (job.source != 'manual' && job.source != 'demo') ...[
                  SizedBox(width: SubZeroSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: SubZeroColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(SubZeroRadius.xs),
                    ),
                    child: Text(
                      _sourceLabel(job.source),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: SubZeroColors.primary,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (onSave != null)
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved
                          ? SubZeroColors.primary
                          : SubZeroColors.textSecondary,
                    ),
                    onPressed: onSave,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (job.companyLogo != null && job.companyLogo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(SubZeroRadius.sm),
        child: CachedNetworkImage(
          imageUrl: job.companyLogo!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          placeholder: (context, url) => _placeholderLogo(),
          errorWidget: (context, url, error) => _placeholderLogo(),
        ),
      );
    }
    return _placeholderLogo();
  }

  Widget _placeholderLogo() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.matchScoreColor(job.matchScore).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SubZeroRadius.sm),
      ),
      child: Center(
        child: Text(
          job.company.isNotEmpty ? job.company[0].toUpperCase() : '?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.matchScoreColor(job.matchScore),
          ),
        ),
      ),
    );
  }

  static String _sourceLabel(String source) {
    switch (source) {
      case 'linkedin':
        return 'LinkedIn';
      case 'ycombinator':
        return 'YC';
      case 'google':
        return 'Google';
      case 'remoteok':
        return 'RemoteOK';
      default:
        return source.toUpperCase();
    }
  }
}
