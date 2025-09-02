import 'package:flutter/material.dart';

class ExercisesPage extends StatelessWidget {
  const ExercisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercises Page"),
        backgroundColor: const Color(0xFF1076FF),
      ),
      body: const Center(
        child: Text(
          "Exercises Page Content",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
