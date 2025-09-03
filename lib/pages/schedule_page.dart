import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  final List<Map<String, String>> schedule;
  final Function(Map<String, String>) onAdd;

  const SchedulePage({Key? key, required this.schedule, required this.onAdd})
    : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
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
        title: const Text(
          "Schedule",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ✅ Use widget.schedule (parent data)
      body: widget.schedule.isEmpty
          ? const Center(
              child: Text(
                "No events yet. Tap + to add one!",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.schedule.length,
              itemBuilder: (context, index) {
                final item = widget.schedule[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.schedule,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      item['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${item['time'] ?? ''}\n${item['description'] ?? ''}",
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Add Event"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Time Picker
                      TextField(
                        controller: timeController,
                        readOnly: true,
                        onTap: () async {
                          final TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            timeController.text = selectedTime.format(context);
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: "Time",
                          suffixIcon: Icon(Icons.access_time),
                        ),
                      ),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: "Title"),
                      ),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: "Description",
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;

                      // ✅ Call parent function instead of local state
                      setState(() {
                        widget.onAdd({
                          'time': timeController.text.trim(),
                          'title': titleController.text.trim(),
                          'description': descController.text.trim(),
                        });
                      });

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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
