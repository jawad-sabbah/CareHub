// Smoke test for CareHub: the app should boot into the welcome screen and
// present the two entry actions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:carehub_app/main.dart';

void main() {
  testWidgets('Welcome screen renders headline and actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CareHubApp());

    expect(find.textContaining('Insurance'), findsOneWidget);
    expect(find.text('New Account'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}