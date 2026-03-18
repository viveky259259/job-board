import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/models/application.dart';

void main() {
  group('ApplicationStatus', () {
    test('labels are correct', () {
      expect(ApplicationStatus.saved.label, 'Saved');
      expect(ApplicationStatus.applied.label, 'Applied');
      expect(ApplicationStatus.interviewing.label, 'Interviewing');
      expect(ApplicationStatus.offered.label, 'Offered');
      expect(ApplicationStatus.rejected.label, 'Rejected');
      expect(ApplicationStatus.ghosted.label, 'Ghosted');
    });

    test('isTerminal identifies final states', () {
      expect(ApplicationStatus.saved.isTerminal, false);
      expect(ApplicationStatus.applied.isTerminal, false);
      expect(ApplicationStatus.interviewing.isTerminal, false);
      expect(ApplicationStatus.offered.isTerminal, true);
      expect(ApplicationStatus.rejected.isTerminal, true);
      expect(ApplicationStatus.ghosted.isTerminal, true);
    });
  });

  group('Application', () {
    test('fromJson/toJson round-trip', () {
      final app = Application(
        id: 'a1',
        userId: 'u1',
        jobId: 'j1',
        jobTitle: 'Developer',
        company: 'TestCo',
        status: ApplicationStatus.applied,
        matchScore: 85,
        createdAt: DateTime(2024, 3, 1),
        appliedAt: DateTime(2024, 3, 2),
        statusUpdates: [
          StatusUpdate(
            status: ApplicationStatus.saved,
            at: DateTime(2024, 3, 1),
          ),
          StatusUpdate(
            status: ApplicationStatus.applied,
            at: DateTime(2024, 3, 2),
            note: 'Applied via website',
          ),
        ],
      );

      final json = app.toJson();
      final restored = Application.fromJson(json);

      expect(restored.id, app.id);
      expect(restored.status, ApplicationStatus.applied);
      expect(restored.matchScore, 85);
      expect(restored.statusUpdates.length, 2);
      expect(restored.statusUpdates[1].note, 'Applied via website');
    });

    test('isPossiblyGhosted detects stale applications', () {
      final recent = Application(
        id: 'a1', userId: 'u1', jobId: 'j1',
        jobTitle: 't', company: 'c',
        status: ApplicationStatus.applied,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        statusUpdates: [
          StatusUpdate(
            status: ApplicationStatus.applied,
            at: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
      );
      expect(recent.isPossiblyGhosted, false);

      final stale = Application(
        id: 'a2', userId: 'u1', jobId: 'j2',
        jobTitle: 't', company: 'c',
        status: ApplicationStatus.applied,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        statusUpdates: [
          StatusUpdate(
            status: ApplicationStatus.applied,
            at: DateTime.now().subtract(const Duration(days: 45)),
          ),
        ],
      );
      expect(stale.isPossiblyGhosted, true);

      final interviewing = Application(
        id: 'a3', userId: 'u1', jobId: 'j3',
        jobTitle: 't', company: 'c',
        status: ApplicationStatus.interviewing,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      );
      expect(interviewing.isPossiblyGhosted, false);
    });
  });
}
