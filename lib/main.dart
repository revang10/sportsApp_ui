import 'package:flutter/material.dart';
import 'package:sports_ui/pages/login_page.dart';
import 'home_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
          color: Colors.white, // 👈 title color
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        ),
      ),
      home: LoginPage(), // ✅ start with HomePage
    );
  }
}
