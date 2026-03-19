import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLogo(),
                  const SizedBox(width: 12),
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
                        const SizedBox(height: 2),
                        Text(
                          job.company,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MatchScoreIndicator(score: job.matchScore, size: 44),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _chip(context, Icons.location_on_outlined, job.location),
                  _chip(context, Icons.work_outline, job.jobType),
                  _chip(context, Icons.laptop_mac, job.remote),
                  if (job.salaryMin != null || job.salaryMax != null)
                    _chip(context, Icons.attach_money, job.salaryRange),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (job.postedAt != null)
                    Text(
                      timeago.format(job.postedAt!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (job.source != 'manual' && job.source != 'demo') ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _sourceColor(job.source),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _sourceLabel(job.source),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: onSave,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (job.companyLogo != null && job.companyLogo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
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
        borderRadius: BorderRadius.circular(10),
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

  Widget _chip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static Color _sourceColor(String source) {
    switch (source) {
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'ycombinator':
        return const Color(0xFFFF6600);
      case 'google':
        return const Color(0xFF4285F4);
      case 'remoteok':
        return const Color(0xFF00C853);
      case 'adzuna':
        return const Color(0xFF2962FF);
      default:
        return Colors.grey;
    }
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
      case 'adzuna':
        return 'Adzuna';
      default:
        return source.toUpperCase();
    }
  }
}
