// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/main.dart';

void main() {
  testWidgets('Navigates to Orders Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FoodDeliveryApp());

    // Verify that the initial screen is the Home Screen.
    expect(find.text('الرئيسية'), findsOneWidget); // 'Home' in Arabic

    // Tap the 'Orders' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Verify that the Orders screen is displayed.
    expect(find.text('My Orders'), findsOneWidget);
  });
}
