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
      body: schedule.isEmpty
          ? const Center(
              child: Text(
                "No events yet. Tap + to add one!",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: schedule.length,
              itemBuilder: (context, index) {
                final item = schedule[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.schedule, color: Colors.blueAccent),
                    title: Text(
                      item['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${item['time'] ?? ''}\n${item['description'] ?? ''}",
                    ),
                    isThreeLine: true, // lets subtitle wrap nicely
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
                    children:[
                      // TextField(
                      //   controller: timeController,
                      //   decoration: const InputDecoration(
                      //     labelText: "Time (e.g. 09:00 AM)",
                      //     ),
                      // ),
                      TextField(
                        controller: timeController,
                        readOnly: true, // Prevents keyboard from appearing
                        onTap: () async {
                          // Show the time picker dialog
                          final TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(), // Sets the initial time
                          );

                          // If the user selected a time
                          if (selectedTime != null) {
                            // Format the time as a string and update the TextField
                            final String formattedTime = selectedTime.format(context);
                            timeController.text = formattedTime;
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: "Time",
                          suffixIcon: Icon(Icons.access_time), // Adds a clock icon
                        ),
                      ),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: "Title"),
                      ),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: "Description"),
                      )
                    ]
                  )
                ),
                actions: [
                  TextButton(
                    onPressed:() => Navigator.pop(context) , 
                    child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Change background color to blue
                      foregroundColor: Colors.white, // Change text color to white
                      ),
                      onPressed: (){
                      if (titleController.text.trim().isEmpty) return;

                      setState(() {
                        schedule.add({
                          'time': timeController.text.trim(),
                          'title':titleController.text.trim(),
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
      child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
