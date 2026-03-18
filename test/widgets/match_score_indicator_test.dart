import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/widgets/match_score_indicator.dart';

void main() {
  group('MatchScoreIndicator', () {
    testWidgets('displays score text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchScoreIndicator(score: 85),
          ),
        ),
      );

      expect(find.text('85%'), findsOneWidget);
    });

    testWidgets('displays 0% score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchScoreIndicator(score: 0),
          ),
        ),
      );

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('displays 100% score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchScoreIndicator(score: 100),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('renders at custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchScoreIndicator(score: 50, size: 80),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 80);
      expect(sizedBox.height, 80);
    });
  });
}
