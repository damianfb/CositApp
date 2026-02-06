import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cositapp/app.dart';

void main() {
  testWidgets('App should build and display bottom navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Verify navigation items are present
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Calendario'), findsOneWidget);
    expect(find.text('Nuevo'), findsOneWidget);
    expect(find.text('Galería'), findsOneWidget);
  });

  testWidgets('Home screen should display welcome message', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    
    // Verify home screen content
    expect(find.text('🏠 Inicio'), findsOneWidget);
    expect(find.text('Bienvenida a Cositas de la Abuela'), findsOneWidget);
  });

  testWidgets('Navigation should work between screens', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    
    // Tap on Calendar tab
    await tester.tap(find.text('Calendario'));
    await tester.pumpAndSettle();
    
    // Verify calendar screen is displayed
    expect(find.text('📅 Calendario'), findsOneWidget);
    
    // Tap on Gallery tab
    await tester.tap(find.text('Galería'));
    await tester.pumpAndSettle();
    
    // Verify gallery screen is displayed
    expect(find.text('📸 Galería'), findsOneWidget);
  });
}
