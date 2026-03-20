import 'package:job_board/models/application.dart';

class ExportService {
  static String applicationsToCsv(List<Application> applications) {
    final buffer = StringBuffer();
    buffer.writeln('Job Title,Company,Status,Match Score,Applied Date,Created Date,Days Since Update,Notes');

    for (final app in applications) {
      final title = _escapeCsv(app.jobTitle);
      final company = _escapeCsv(app.company);
      final status = app.status.label;
      final match = app.matchScore;
      final applied = app.appliedAt?.toIso8601String() ?? '';
      final created = app.createdAt.toIso8601String();
      final daysSince = app.daysSinceLastUpdate;
      final notes = _escapeCsv(app.notes ?? '');

      buffer.writeln('$title,$company,$status,$match,$applied,$created,$daysSince,$notes');
    }

    return buffer.toString();
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
