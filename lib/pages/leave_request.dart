import 'package:flutter/material.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController leaveTypeController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  void openDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          
          title: Text("Leave Request"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    hintText: 'Select Date',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2002),
                      lastDate: DateTime(2050),
                      initialDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate; // ✅ update startDate
                        startDateController.text =
                            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                      });
                    }
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    hintText: 'Select Date',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2050),
                      initialDate: startDate ?? DateTime.now(),
                    );
                    if (pickedDate != null) {
                      if (startDate != null &&
                          pickedDate.isBefore(startDate!)) {
                        endDateController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("End date must be after Start date"),
                          ),
                        );
                      } else {
                        setState(() {
                          endDate = pickedDate;
                          endDateController.text =
                              "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                        });
                      }
                    }
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Enter Reason',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Leave Type",
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: ["Sick Leave", "Casual Leave", "Paid Leave"].map((
                    type,
                  ) {
                    return DropdownMenuItem(
                      value: type,
                      child: SizedBox(
                        width: 200,
                        child: Text(type, overflow: TextOverflow.ellipsis),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      // selectedLeave = value!;
                    }
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, 
            child: Text("Cancel")
            ),
            ElevatedButton(onPressed: (){
              // Handle form submission logic here
              
            
            }, child: Text("Submit"))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leave Request Page"),
        backgroundColor: const Color(0xFF1076FF),
      ),
      body: Center(
        child: Text("No Leave Requests"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openDialog,
        child: Icon(Icons.add),
        backgroundColor: const Color(0xFF1076FF),
      ),
    );
  }
}
