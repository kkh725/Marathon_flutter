import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marathon_flutter/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MarathonApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('K-RUN GLOBAL'), findsOneWidget);
  });
}
