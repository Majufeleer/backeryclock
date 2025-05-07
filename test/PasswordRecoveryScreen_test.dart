import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backeryclock1/PasswordRecoveryScreen.dart';

void main() {
  testWidgets('Verifica que se muestre el SnackBar en PasswordRecoveryScreen',
      (WidgetTester tester) async {
    // Construir la pantalla con un Scaffold
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordRecoveryScreen(),
        ),
      ),
    );

    // Encontrar el TextField
    final textFieldFinder = find.byType(TextField);

    // Verificar que el TextField está presente
    expect(textFieldFinder, findsOneWidget);

    // Caso 1: Campo vacío
    await tester.tap(find.byType(ElevatedButton)); // Tap en el botón
    await tester.pumpAndSettle(); // Procesar los cambios en la interfaz

    // Verificar que el SnackBar se muestra
    expect(find.byType(SnackBar), findsOneWidget);

    // Caso 2: Correo válido
    await tester.enterText(
        textFieldFinder, 'correo@ejemplo.com'); // Ingresar texto
    await tester.tap(find.byType(ElevatedButton)); // Tap en el botón
    await tester.pumpAndSettle(); // Procesar los cambios en la interfaz

    // Verificar que el SnackBar se muestra
    expect(find.byType(SnackBar), findsOneWidget);

    // Caso 3: Error inesperado con un correo malformado
    await tester.enterText(
        textFieldFinder, 'correo_invalido'); // Ingresar texto inválido
    await tester.tap(find.byType(ElevatedButton)); // Tap en el botón
    await tester.pumpAndSettle(); // Procesar los cambios en la interfaz

    // Verificar que el SnackBar se muestra
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
