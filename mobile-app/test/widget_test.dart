import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockscope/main.dart';

void main() {
  testWidgets('StockScope app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const StockScopeApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
