import 'package:flutter/material.dart';

class WeightPage extends StatelessWidget {
  const WeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weight Page"),
        backgroundColor: const Color(0xFF1076FF),
      ),
      body: const Center(
        child: Text(
          "Weight Page Content",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
