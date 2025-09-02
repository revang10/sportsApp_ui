import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final List<Map<String, String>> schedule = [];

  final titleController = TextEditingController();
  final timeController = TextEditingController();
  final descController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    timeController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schedule",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Text(
          "Schedule Page Content Here",
          style: TextStyle(fontSize: 18),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Event'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: timeController,
                        decoration: const InputDecoration(
                          labelText: 'Time (e.g. 09:00 AM)',
                        ),
                      ),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // basic guard (optional)
                      if (titleController.text.trim().isEmpty) return;

                      setState(() {
                        schedule.add({
                          'time': timeController.text.trim(),
                          'title': titleController.text.trim(),
                          'description': descController.text.trim(),
                        });
                      });

                      // clear for next time
                      timeController.clear();
                      titleController.clear();
                      descController.clear();

                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },

        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
