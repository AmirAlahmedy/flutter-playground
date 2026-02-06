import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/quiz_screen.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://rkttdebkjsmqkqsgbdpp.supabase.co',
    anonKey: 'sb_publishable_cJY9KDaWsOf5-N_fdH976A_SgfiTJRA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const QuizScreen(),
    );
  }
}

