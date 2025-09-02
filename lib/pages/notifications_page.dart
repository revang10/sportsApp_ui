import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications Page", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1076FF),
        iconTheme: IconThemeData(
          color: Colors.white, // <-- This changes the back arrow color
        ),
        
      ),
      body: const Center(
        child: Text(
          "Notifications Page Content",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
