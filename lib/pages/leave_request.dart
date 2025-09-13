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
  TextEditingController employeeIDController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String? selectedLeave;

  List<dynamic> leaveRequests = [];
  bool isLoading = true;

  final Map<String, int> leavetypeMap = {
    "Sick Leave": 0,
    "Casual Leave": 1,
    "Paid Leave": 2,
  };

  final Map<int, String> leaveTypeName = {
    0: "Sick Leave",
    1: "Casual Leave",
    2: "Paid Leave",
  };

  @override
  void initState() {
    super.initState();
    fetchLeaveRequests();
  }

  /// Fetch all leave requests
  Future<void> fetchLeaveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("https://api.repro360.in/api/LeaveRequest"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📥 GET Response Status: ${response.statusCode}");
      print("📥 GET Response Body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          leaveRequests = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to load leave requests")),
        );
      }
    } catch (e) {
      print("🔥 Exception in fetchLeaveRequests: $e");
      setState(() => isLoading = false);
    }
  }

  /// Submit leave request
  Future<void> submitLeaveRequest(BuildContext dialogContext) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("✅ Token in SharedPreferences: $token");

    final empId = int.tryParse(employeeIDController.text) ?? 0;

    final body = {
      "EmployeeId": empId,
      "LeaveTypeId": leavetypeMap[selectedLeave] ?? 0,
      "StartDate": startDate?.toUtc().toIso8601String(),
      "EndDate": endDate?.toUtc().toIso8601String(),
      "StartDateType": 0,
      "EndDateType": 0,
      "Reason": reasonController.text,
      "CreatedDate": DateTime.now().toUtc().toIso8601String(),
      "CreatedBy": empId,
      "ModifiedDate": DateTime.now().toUtc().toIso8601String(),
      "ModifiedBy": empId,
      "IsDeleted": false,
      "DeletedDate": null,
      "DeletedBy": null
    };

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

      print("📥 POST Response Status: ${response.statusCode}");
      print("📥 POST Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Leave request submitted successfully")),
        );
        Navigator.pop(dialogContext);
        fetchLeaveRequests(); // 🔄 Refresh list after submit
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${response.body}")),
        );
      }
    } catch (e) {
      print("🔥 Exception while submitting leave request: $e");
    }
  }

  /// Open Dialog to add new leave request
  void openDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Leave Request"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Employee ID
                TextField(
                  controller: employeeIDController,
                  decoration: InputDecoration(
                    labelText: 'Employee ID',
                    hintText: 'Enter Employee ID',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),

                // Start Date
                TextField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    hintText: 'Select Date',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2050),
                      initialDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                        startDateController.text =
                            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                      });
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
                    border: OutlineInputBorder(),
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
                          SnackBar(content: Text("⚠️ End date must be after Start date")),
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

                // Reason
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Enter Reason',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
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
                  items: ["Sick Leave", "Casual Leave", "Paid Leave"]
                      .map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLeave = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (startDate == null ||
                    endDate == null ||
                    reasonController.text.isEmpty ||
                    selectedLeave == null ||
                    employeeIDController.text.isEmpty) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Leave Request Page"),
        backgroundColor: const Color(0xFF1076FF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : leaveRequests.isEmpty
              ? Center(child: Text("No Leave Requests"))
              : ListView.builder(
                  itemCount: leaveRequests.length,
                  itemBuilder: (context, index) {
                    final req = leaveRequests[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Reason: ${req['Reason'] ?? 'N/A'} ${req['EmployeeId']}"),
                        subtitle: Text(
                          "Type: ${leaveTypeName[req['LeaveTypeId']] ?? 'Unknown'}\n"
                          "From: ${req['StartDate']} → To: ${req['EndDate']}",
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: openDialog,
        child: Icon(Icons.add),
        backgroundColor: const Color(0xFF1076FF),
      ),
    );
  }
}
