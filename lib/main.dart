import 'package:crud_firestore/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  // Memastikan Flutter Udah Ngebinding Widget Widgetnya
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Firebase Inisialiasi Aplikasi Flutter
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
