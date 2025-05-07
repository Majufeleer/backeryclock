import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backeryclock1/LoginScreen.dart'; // Asegúrate de usar la ruta correcta del archivo

void main() {
  group('LoginScreen Tests', () {
    testWidgets('Debería mostrar campos de usuario y contraseña',
        (WidgetTester tester) async {
      // Construye la pantalla LoginScreen
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));

      // Verifica que los campos de texto para "Usuario" y "Contraseña" estén presentes
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
    });

    testWidgets('Debería mostrar un botón de "Iniciar Sesión"',
        (WidgetTester tester) async {
      // Construye la pantalla LoginScreen
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));

      // Verifica que el botón "Iniciar Sesión" esté presente
      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });

    testWidgets(
        'Debería mostrar un mensaje si se intenta iniciar sesión con campos vacíos',
        (WidgetTester tester) async {
      // Construye la pantalla LoginScreen
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));

      // Encuentra el botón "Iniciar Sesión" y haz clic en él
      await tester.tap(find.text('Iniciar Sesión'));
      await tester.pump();

      // Verifica que se muestre el mensaje de error correspondiente
      expect(find.text('Por favor, completa todos los campos'), findsOneWidget);
    });

    // Puedes agregar más pruebas según los escenarios que deseas cubrir
  });
}
