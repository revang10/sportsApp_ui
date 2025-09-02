import 'package:flutter/material.dart';

class SleepPage extends StatelessWidget {
  const SleepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sleep Page"),
        backgroundColor: const Color(0xFF1076FF),
      ),
      body: const Center(
        child: Text(
          "Sleep Page Content",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
