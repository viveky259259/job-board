import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('displays title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.work_off,
              title: 'No jobs found',
              subtitle: 'Try adjusting your filters',
            ),
          ),
        ),
      );

      expect(find.text('No jobs found'), findsOneWidget);
      expect(find.text('Try adjusting your filters'), findsOneWidget);
    });

    testWidgets('shows action button when provided', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.work_off,
              title: 'Empty',
              actionLabel: 'Refresh',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Refresh'), findsOneWidget);
      await tester.tap(find.text('Refresh'));
      expect(tapped, true);
    });

    testWidgets('hides action button when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.work_off,
              title: 'Empty',
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
