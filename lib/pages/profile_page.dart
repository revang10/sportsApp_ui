import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? data;

  const ProfilePage({Key? key, required this.data}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final employee = widget.data;

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Profile", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(child: Text("No data available")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: employee.entries.map((entry) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(
                "${entry.key}: ${entry.value}",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              // subtitle: Text(
              //   entry.value == null || entry.value.toString().isEmpty
              //       ? "N/A"
              //       : entry.value.toString(),
              // ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
