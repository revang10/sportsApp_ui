import 'dart:io';

void main() {
  final pages = [
    "Profile",
    "Notifications",
    "Schedule",
    "Exercises",
    "TrainingPlan",
    "Progress",
    "Weight",
    "Sleep",
    "Settings",
  ];

  final directory = Directory('lib/pages');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  for (var page in pages) {
    final fileName = '${page.toLowerCase()}_page.dart';
    final file = File('lib/pages/$fileName');

    final content = '''
import 'package:flutter/material.dart';

class ${page}Page extends StatelessWidget {
  const ${page}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$page Page"),
        backgroundColor: const Color(0xFF1076FF),
      ),
      body: const Center(
        child: Text(
          "$page Page Content",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
''';

    file.writeAsStringSync(content);
    print('✅ Created: lib/pages/$fileName');
  }
}
