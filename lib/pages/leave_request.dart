import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController leaveIDController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String? selectedLeave;

  final Map<String, int> leavetypeMap = {
    "Sick Leave": 0,
    "Casual Leave": 1,
    "Paid Leave": 2,
  };

  Future<void> submitLeaveRequest(BuildContext dialogContext) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("✅ Token in SharedPreferences: $token");

    final body = {
      "LeaveRequestId": int.tryParse(leaveIDController.text) ?? 0,                    // int
      "EmployeeId": 0,                       // your employee id
      "LeaveTypeId": leavetypeMap[selectedLeave] ?? 0,
      "StartDate": startDate?.toUtc().toIso8601String(),
      "EndDate": endDate?.toUtc().toIso8601String(),
      "StartDateType": 0,
      "EndDateType": 0,
      "Reason": reasonController.text,
      "CreatedDate": DateTime.now().toUtc().toIso8601String(),
      "CreatedBy": 123,                        // same as EmployeeId
      "ModifiedDate": DateTime.now().toUtc().toIso8601String(),
      "ModifiedBy": 123,
      "IsDeleted": false,
      "DeletedDate": DateTime.now().toUtc().toIso8601String(),
      "DeletedBy": ""
    };


    print("🟡 Preparing to send leave request...");
    print("📤 Sending Payload: $body");

    try {
      final response = await http.post(
        Uri.parse("https://api.repro360.in/api/LeaveRequest/AddNew"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Leave request submitted successfully!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Leave request submitted successfully")),
        );
        Navigator.pop(dialogContext); // ✅ Close dialog after success
      } else {
        print("❌ Failed to submit leave request!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${response.body}")),
        );
      }
    } catch (e) {
      print("🔥 Exception while submitting leave request: $e");
    }
  }

  void openDialog() {
    print("🟢 Opening Leave Request Dialog...");
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Leave Request"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: leaveIDController,
                  decoration: InputDecoration(
                    labelText: 'Leave Request ID',
                    hintText: 'Enter Leave Request ID',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    print("✏️ Reason typed: $value");
                  },
                ),
                // Start Date
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
                    print("🟡 User tapped on Start Date...");
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2002),
                      lastDate: DateTime(2050),
                      initialDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                        startDateController.text =
                            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                      });
                      print("✅ Start Date selected: $startDate");
                    } else {
                      print("⚠️ Start Date not selected.");
                    }
                  },
                ),
                SizedBox(height: 12),

                // End Date
                TextField(
                  controller: endDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    hintText: 'Select Date',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onTap: () async {
                    print("🟡 User tapped on End Date...");
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
                        print(
                            "❌ End date $pickedDate is before Start date $startDate");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text("⚠️ End date must be after Start date")),
                        );
                      } else {
                        setState(() {
                          endDate = pickedDate;
                          endDateController.text =
                              "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                        });
                        print("✅ End Date selected: $endDate");
                      }
                    } else {
                      print("⚠️ End Date not selected.");
                    }
                  },
                ),
                SizedBox(height: 12),

                // Reason
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Enter Reason',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    print("✏️ Reason typed: $value");
                  },
                ),
                SizedBox(height: 12),

                // Leave Type Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Leave Type",
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  value: selectedLeave,
                  items:
                      ["Sick Leave", "Casual Leave", "Paid Leave"].map((type) {
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
                      selectedLeave = value!;
                    });
                    print("📌 Leave Type selected: $selectedLeave");
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("❌ Cancel button clicked. Closing dialog.");
                Navigator.pop(dialogContext);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                print("🟢 Submit button clicked!");
                if (startDate == null ||
                    endDate == null ||
                    reasonController.text.isEmpty ||
                    selectedLeave == null) {
                  print("⚠️ Validation failed! Fields missing.");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("⚠️ Please fill all fields")),
                  );
                } else {
                  submitLeaveRequest(dialogContext);
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("🔄 Building LeavePage UI...");
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
