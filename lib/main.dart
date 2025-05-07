import 'package:firebase_core/firebase_core.dart'; // Importar Firebase
import 'package:flutter/material.dart';
import 'SplashScreen.dart'; // Importa tu pantalla SplashScreen

void main() async {
  // Asegúrate de inicializar Flutter antes de Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAp_qeyyicuJWsexlnJDVPI4JwpDGownQ8",
      authDomain: "backery-clock-b15c3.firebaseapp.com",
      projectId: "backery-clock-b15c3",
      storageBucket: "backery-clock-b15c3.appspot.com",
      messagingSenderId: "346621611536",
      appId: "1:346621611536:web:828b9c755540174f874495",
      databaseURL: "https://backery-clock-b15c3-default-rtdb.firebaseio.com/",
    ),
  );

  // Ejecuta la app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la bandera de depuración
      title: 'Backery Clock', // Título de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.pink, // Tema de color principal
      ),
      home: SplashScreen(), // Pantalla de inicio
    );
  }
}
