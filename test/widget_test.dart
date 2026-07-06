// Basic smoke test for the E-Ticketing Helpdesk app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_ticketing_helpdesk/main.dart';

void main() {
  testWidgets('App boots into the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
