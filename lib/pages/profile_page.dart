import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  // final String currentName;
  // final Function(String) onSave;

  // const ProfilePage({Key? key, required this.currentName, required this.onSave}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // _nameController = TextEditingController(text: widget.currentName); // ✅ preload with current name
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    if (_nameController.text.trim().isNotEmpty) {
      // widget.onSave(_nameController.text.trim()); // ✅ send new name back to HomePage
      Navigator.pop(context); // go back to HomePage
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a name")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Color(0xFF1076FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage('assets/images/profile.jpeg'),
                ),
              ),
            Text("Enter your name:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Your Name",
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1076FF),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(fontSize: 16, color: Colors.white)
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: _saveName,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Color(0xFF1076FF),
            //     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            //   ),
            //   child: Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
            // ),
          ],
        ),
      ),
    );
  }
}
